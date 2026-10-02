/* Bug #230: MC6839 BINDEC-backed __dtoa_engine. (See ftoa_engine_mc6809.c
 * for narrative; this is the f64 sibling.) */

#define _NEED_IO_FLOAT64
#include <stdint.h>
#include <stdbool.h>
#include "dtoa.h"

extern void __mc6839_bindec_f64(uint8_t *bcd, int k, FLOAT64 val);

static inline int decode_E(const uint8_t *bcd) {
    int eMag = bcd[1] * 1000 + bcd[2] * 100 + bcd[3] * 10 + bcd[4];
    return (bcd[0] == 0x0F) ? -eMag : eMag;
}

int
__dtoa_engine(uint64_t val, struct dtoa *dtoa, int maxDigits, bool fmode, int maxDecimals)
{
    uint8_t flags = 0;

    if (maxDigits > DTOA_MAX_DIG)
        maxDigits = DTOA_MAX_DIG;
    if (maxDigits < 1)
        maxDigits = 1;

    if (val & ((uint64_t)1 << 63))
        flags = DTOA_MINUS;

    uint16_t exp = (uint16_t)((val >> 52) & 0x7FFU);
    uint64_t frac = val & 0x000FFFFFFFFFFFFFULL;

    dtoa->exp = 0;

    if (exp == 0 && frac == 0) {
        flags |= DTOA_ZERO;
        dtoa->digits[0] = '0';
        dtoa->flags = flags;
        return 1;
    }
    if (exp == 0x7FF) {
        flags |= (frac == 0) ? DTOA_INF : DTOA_NAN;
        dtoa->flags = flags;
        return 0;
    }

    union { uint64_t u; FLOAT64 f; } u;
    u.u = val;
    FLOAT64 fv = u.f;
    if (flags & DTOA_MINUS)
        fv = -fv;

    uint8_t bcd[26];

    int exp10_first = 0;
    if (fmode) {
        __mc6839_bindec_f64(bcd, DTOA_MAX_DIG, fv);
        int E = decode_E(bcd);
        int exp10 = E + DTOA_MAX_DIG - 1;
        exp10_first = exp10;

        /* See ftoa_engine_mc6809.c for narrative: matches the existing
         * C engine's `max(maxDecimals < 0, maxDecimals + exp10 + 1)`. */
        int adj = maxDecimals + exp10 + 1;
        int floor = (maxDecimals < 0) ? 1 : 0;
        if (adj < floor) adj = floor;
        if (adj > maxDigits) adj = maxDigits;
        maxDigits = adj;
    }
    if (maxDigits == 0) {
        /* Rounds-to-zero: pass through actual exp10 so fcvt_r's
         * rounds-to-zero branch triggers correctly. */
        dtoa->exp = exp10_first;
        dtoa->flags = flags;
        return 0;
    }

    /* k>=2 always: BINDEC is unusable at k=1 for 0 < x < 1, and gets
     * 5.0e-4 wrong by a whole decade rather than obviously wrong.
     * ftoa_engine_mc6809.c carries the analysis. */
    int call_k = (maxDigits < 2) ? 2 : maxDigits;
    __mc6839_bindec_f64(bcd, call_k, fv);
    int E = decode_E(bcd);

    int start = 6 + (19 - call_k);
    for (int i = 0; i < maxDigits; i++)
        dtoa->digits[i] = (char)(bcd[start + i] + '0');

    int exp10 = E + call_k - 1;

    if (call_k > maxDigits) {
        if ((bcd[start + maxDigits] & 0x0F) >= 5) {
            int j = maxDigits - 1;
            while (j >= 0) {
                if (++dtoa->digits[j] <= '9') break;
                dtoa->digits[j] = '0';
                j--;
            }
            if (j < 0) {
                dtoa->digits[0] = '1';
                exp10++;
            }
        }
    }

    dtoa->exp = exp10;
    dtoa->flags = flags;
    return maxDigits;
}
