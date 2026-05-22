#include <ctype.h>

static int
digit_value(int ch)
{
    if (ch >= '0' && ch <= '9')
        return ch - '0';
    if (ch >= 'a' && ch <= 'z')
        return ch - 'a' + 10;
    if (ch >= 'A' && ch <= 'Z')
        return ch - 'A' + 10;
    return -1;
}

unsigned long
strtoul(const char *nptr, char **endptr, int base)
{
    const char *s = nptr;
    const char *start;
    unsigned long value = 0;
    unsigned long cutoff;
    int cutlim;
    int digit;
    int any = 0;
    int neg = 0;

    while (*s && isspace((unsigned char) *s))
        s++;

    if (*s == '+' || *s == '-') {
        neg = (*s == '-');
        s++;
    }

    if ((base == 0 || base == 16) && s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) {
        s += 2;
        base = 16;
    } else if (base == 0) {
        base = (s[0] == '0') ? 8 : 10;
    }

    if (base < 2 || base > 36) {
        if (endptr)
            *endptr = (char *) nptr;
        return 0;
    }

    start = s;
    cutoff = ~0UL / (unsigned long) base;
    cutlim = (int) (~0UL % (unsigned long) base);

    while ((digit = digit_value((unsigned char) *s)) >= 0 && digit < base) {
        if (value > cutoff || (value == cutoff && digit > cutlim)) {
            value = ~0UL;
            any = 1;
            while ((digit = digit_value((unsigned char) *++s)) >= 0 && digit < base)
                ;
            break;
        }
        value = value * (unsigned long) base + (unsigned long) digit;
        any = 1;
        s++;
    }

    if (endptr)
        *endptr = (char *) (any ? s : nptr);

    if (!any)
        return 0;

    if (neg)
        return (unsigned long) (0UL - value);

    return value;
}

long
strtol(const char *nptr, char **endptr, int base)
{
    const char *s = nptr;
    unsigned long value;
    unsigned long max_positive = ((unsigned long) ~0UL) >> 1;
    unsigned long max_negative = max_positive + 1UL;
    int neg = 0;
    char *parsed_end;

    while (*s && isspace((unsigned char) *s))
        s++;
    if (*s == '+' || *s == '-') {
        neg = (*s == '-');
    }

    value = strtoul(nptr, &parsed_end, base);
    if (parsed_end == nptr) {
        if (endptr)
            *endptr = (char *) nptr;
        return 0;
    }

    if (endptr)
        *endptr = parsed_end;

    if (neg) {
        if (value > max_negative)
            return (long) max_negative;
        if (value == max_negative)
            return (long) (0UL - max_negative);
        return -(long) value;
    }

    if (value > max_positive)
        return (long) max_positive;

    return (long) value;
}
