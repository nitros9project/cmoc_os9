/* Bug #230: MC6839 BINDEC-backed __ftoa_engine.
 *
 * Replaces picolibc's iterative software multi-precision path with a
 * single ROM call. BINDEC ($1C) takes (k, value, FPCB) and writes a
 * 26-byte BCD string holding `k` significant digits + signed decimal
 * exponent. We translate the BCD into picolibc's `struct dtoa`.
 *
 * Picolibc's `dtoa->exp` is the decimal exponent of the LEFTMOST
 * digit. The BCD's `E` (in se+exp-field) is such that
 * value = (digits as 19-digit integer) * 10^E. Right-aligning k
 * digits into the last k positions of the fraction gives a 19-digit
 * integer = (k-digit integer) * 10^0, so value = digits * 10^E and
 * the leftmost-digit exponent is E + (k-1).
 *
 * fmode handling: when fmode is true, the caller (vfprintf for `%f`,
 * fcvt_r/ecvt_r for similar) wants exactly `maxDecimals` digits to
 * the right of the decimal point. The total digit count is then
 * `decpt + maxDecimals` where decpt = exp10 + 1 (digits-before-decimal).
 * We compute exp10 with a first BINDEC call at full precision, adjust
 * maxDigits, then re-call BINDEC for the correctly-rounded result.
 */

#define _NEED_IO_FLOAT32
#include <stdint.h>
#include <stdbool.h>
#include "dtoa.h"

extern void __mc6839_bindec_f32(uint8_t *bcd, int k, float val);

static inline int decode_E(const uint8_t *bcd) {
    int eMag = bcd[1] * 1000 + bcd[2] * 100 + bcd[3] * 10 + bcd[4];
    return (bcd[0] == 0x0F) ? -eMag : eMag;
}

int
__ftoa_engine(uint32_t val, struct dtoa *ftoa, int maxDigits, bool fmode, int maxDecimals)
{
    uint8_t flags = 0;

    if (maxDigits > FTOA_MAX_DIG)
        maxDigits = FTOA_MAX_DIG;
    if (maxDigits < 1)
        maxDigits = 1;

    /* Sign + special-value detection from IEEE bits */
    if (val & ((uint32_t)1 << 31))
        flags = DTOA_MINUS;

    uint8_t exp = (uint8_t)(val >> 23);
    uint32_t frac = val & 0x007FFFFFU;

    ftoa->exp = 0;

    if (exp == 0 && frac == 0) {
        flags |= DTOA_ZERO;
        ftoa->digits[0] = '0';
        ftoa->flags = flags;
        return 1;
    }
    if (exp == 0xFF) {
        flags |= (frac == 0) ? DTOA_INF : DTOA_NAN;
        ftoa->flags = flags;
        return 0;
    }

    union { uint32_t u; float f; } u;
    u.u = val;
    float fv = u.f;
    if (flags & DTOA_MINUS)
        fv = -fv;

    uint8_t bcd[26];

    int exp10_first = 0;  /* used for the rounds-to-zero exit below */
    if (fmode) {
        /* First pass: get exp10 at full precision */
        __mc6839_bindec_f32(bcd, FTOA_MAX_DIG, fv);
        int E = decode_E(bcd);
        int exp10 = E + FTOA_MAX_DIG - 1;
        exp10_first = exp10;

        /* Match the existing C engine's logic (ftoa_engine.c:157):
         *   maxDigits = min(maxDigits,
         *                   max(maxDecimals < 0, maxDecimals + exp10 + 1));
         *
         * When maxDecimals < 0, the boolean evaluates to 1, ensuring at
         * least 1 digit (used by fcvt with negative ndigit to mean
         * "show the integer part"). When maxDecimals >= 0, the floor is 0
         * — the engine may legitimately produce zero digits when the
         * value rounds entirely below the requested precision; the caller
         * formats that as "0.000…". */
        int adj = maxDecimals + exp10 + 1;
        int floor = (maxDecimals < 0) ? 1 : 0;
        if (adj < floor) adj = floor;
        if (adj > maxDigits) adj = maxDigits;
        maxDigits = adj;
    }
    if (maxDigits == 0) {
        /* Engine produces no digits — value rounds to all zeros at the
         * requested precision. Return ftoa->exp = the actual leftmost-
         * digit position so the caller (fcvt_r:96-105) computes a
         * negative `ntrailing` and hits its rounds-to-zero branch
         * (which sets *decpt = -dtoa_decimal). */
        ftoa->exp = exp10_first;
        ftoa->flags = flags;
        return 0;
    }

    /* Final pass: BINDEC with adjusted digit count yields the rounded
     * result.  BINDEC is unusable at k=1 for 0 < x < 1, so always call
     * with k>=2 and trim + re-round here when the caller wanted fewer.
     *
     * The cause is in the ROM (romsrc/outs.s, BDCNVT): it starts from
     * V := IFIX(log10(x)) + 1 - k, and IFIX truncates toward zero, so
     * for a value below 1 whose log10 is not a whole number V comes out
     * one too large.  CHEKW exists to catch that -- its case 3 retries
     * when W <= 10^(k-1) - 1 -- but at k=1 that threshold is 0, so the
     * only value that can trip it is zero itself, which the same test
     * then rejects as not normalized.  At k=1 the correction is
     * structurally unable to fire.
     *
     * Two shapes come out of it, and the second is the reason this
     * clamp must stay: 1.23e-4 returns all-zero digits (visibly wrong),
     * but 5.0e-4 returns 1 x 10^-3 -- a plausible-looking answer that is
     * a decade out, because rounding 0.5 up to 1 hid the exponent error.
     * k=1 is correct only for x >= 1 and for exact powers of ten. */
    int call_k = (maxDigits < 2) ? 2 : maxDigits;
    __mc6839_bindec_f32(bcd, call_k, fv);
    int E = decode_E(bcd);

    /* Read the first `maxDigits` of the call_k-digit BINDEC output. */
    int start = 6 + (19 - call_k);
    for (int i = 0; i < maxDigits; i++)
        ftoa->digits[i] = (char)(bcd[start + i] + '0');

    int exp10 = E + call_k - 1;

    /* Manual round-up if we asked for fewer digits than we got and
     * the first dropped digit is >= 5. */
    if (call_k > maxDigits) {
        if ((bcd[start + maxDigits] & 0x0F) >= 5) {
            int j = maxDigits - 1;
            while (j >= 0) {
                if (++ftoa->digits[j] <= '9') break;
                ftoa->digits[j] = '0';
                j--;
            }
            if (j < 0) {
                /* Carried past the leftmost digit: shift to "1" with
                 * exp+1 (e.g. "99" rounded to 1 digit -> "1" with
                 * exp10 += 1). */
                ftoa->digits[0] = '1';
                exp10++;
            }
        }
    }

    ftoa->exp = exp10;
    ftoa->flags = flags;
    return maxDigits;
}
