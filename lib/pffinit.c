#include <ctype.h>
#include <string.h>

extern char *ftoa(char out[38], float f);

static char buf[48];
static char tmp[48];

static int
parse_exp(const char *s)
{
    int sign = 1;
    int value = 0;

    if (*s == '+')
        ++s;
    else if (*s == '-')
    {
        sign = -1;
        ++s;
    }

    while (*s >= '0' && *s <= '9')
    {
        value = value * 10 + (*s - '0');
        ++s;
    }

    return sign * value;
}

static int
parse_number(const char *src, char *digits, int *point, int *negative)
{
    int len = 0;
    int digits_before_dot = -1;
    char *exp_ptr;

    *negative = 0;
    if (*src == '-')
    {
        *negative = 1;
        ++src;
    }

    exp_ptr = strchr((char *) src, 'E');
    if (exp_ptr == 0)
        exp_ptr = strchr((char *) src, 'e');

    while (*src && src != exp_ptr)
    {
        if (*src == '.')
        {
            digits_before_dot = len;
        }
        else if (*src >= '0' && *src <= '9')
        {
            digits[len++] = *src;
        }
        ++src;
    }

    if (digits_before_dot < 0)
        digits_before_dot = len;

    digits[len] = '\0';
    *point = digits_before_dot;

    if (exp_ptr != 0)
        *point += parse_exp(exp_ptr + 1);

    return len;
}

static void
ensure_zero_string(char *digits, int *len, int *point)
{
    if (*len == 0)
    {
        digits[0] = '0';
        digits[1] = '\0';
        *len = 1;
        *point = 1;
    }
}

static void
format_fixed(const char *digits, int len, int point, int negative, int prec, char *out)
{
    char *w = out;
    int i;
    int frac_len;

    if (negative && !(len == 1 && digits[0] == '0'))
        *w++ = '-';

    if (point <= 0)
    {
        *w++ = '0';
    }
    else
    {
        for (i = 0; i < point; ++i)
            *w++ = (i < len ? digits[i] : '0');
    }

    if (prec > 0)
        *w++ = '.';

    frac_len = 0;
    if (point < len)
        frac_len = len - point;
    else if (point < 0)
        frac_len = len;

    if (prec > 0)
    {
        if (point < 0)
        {
            for (i = 0; i < -point && prec > 0; ++i, --prec)
                *w++ = '0';
            for (i = 0; i < len && prec > 0; ++i, --prec)
                *w++ = digits[i];
        }
        else if (point < len)
        {
            for (i = point; i < len && prec > 0; ++i, --prec)
                *w++ = digits[i];
        }

        while (prec-- > 0)
            *w++ = '0';
    }

    *w = '\0';
}

static void
format_scientific(const char *digits, int len, int point, int negative, int prec, int upper, char *out)
{
    char *w = out;
    int first = 0;
    int exp;
    int i;
    int remaining;

    while (first < len && digits[first] == '0')
        ++first;

    if (first == len)
    {
        if (negative)
            *w++ = '-';
        *w++ = '0';
        if (prec > 0)
            *w++ = '.';
        while (prec-- > 0)
            *w++ = '0';
        *w++ = upper ? 'E' : 'e';
        *w++ = '+';
        *w++ = '0';
        *w++ = '0';
        *w = '\0';
        return;
    }

    if (negative)
        *w++ = '-';

    exp = point - first - 1;
    *w++ = digits[first++];

    if (prec > 0)
        *w++ = '.';

    remaining = prec;
    while (remaining-- > 0)
    {
        *w++ = (first < len ? digits[first++] : '0');
    }

    *w++ = upper ? 'E' : 'e';
    if (exp < 0)
    {
        *w++ = '-';
        exp = -exp;
    }
    else
    {
        *w++ = '+';
    }

    if (exp >= 100)
    {
        i = exp / 100;
            *w++ = (char) (i + '0');
            exp %= 100;
    }
    *w++ = (char) ((exp / 10) + '0');
    *w++ = (char) ((exp % 10) + '0');
    *w = '\0';
}

static void
trim_general(char *s)
{
    char *e = strchr(s, 'E');
    char *p;
    char *end;

    if (e == 0)
        e = strchr(s, 'e');

    if (e != 0)
        end = e - 1;
    else
        end = s + strlen(s) - 1;

    p = strchr(s, '.');
    if (p == 0)
        return;

    while (end > p && *end == '0')
        --end;
    if (end == p)
        --end;

    if (e != 0)
    {
        char *dst = end + 1;
        while ((*dst++ = *e++) != '\0')
            ;
    }
    else
        end[1] = '\0';
}

static void
format_general(const char *digits, int len, int point, int negative, int prec, int upper, char *out)
{
    int first = 0;
    int exp;
    int int_digits;

    if (prec == 0)
        prec = 1;

    while (first < len && digits[first] == '0')
        ++first;

    if (first == len)
    {
        strcpy(out, "0");
        return;
    }

    exp = point - first - 1;
    if (exp < -4 || exp >= prec)
    {
        format_scientific(digits, len, point, negative, prec - 1, upper, out);
    }
    else
    {
        int_digits = point - first;
        if (int_digits < 0)
            int_digits = 0;
        format_fixed(digits + first, len - first, point - first, negative, prec - int_digits, out);
    }

    trim_general(out);
    if (upper)
    {
        char *p = strchr(out, 'e');
        if (p != 0)
            *p = 'E';
    }
}

int
pffinit(void)
{
    return 0;
}

char *
pffloat(int c, int prec, float **args)
{
    float *value_ptr;
    int point;
    int negative;
    int len;

    value_ptr = *args;
    *args = (float *) ((char *) value_ptr + sizeof(float));

    if (ftoa(tmp, *value_ptr) == 0)
        return 0;

    len = parse_number(tmp, buf, &point, &negative);
    ensure_zero_string(buf, &len, &point);

    switch (c)
    {
        case 'e':
            format_scientific(buf, len, point, negative, prec, 0, tmp);
            break;
        case 'E':
            format_scientific(buf, len, point, negative, prec, 1, tmp);
            break;
        case 'g':
            format_general(buf, len, point, negative, prec, 0, tmp);
            break;
        case 'G':
            format_general(buf, len, point, negative, prec, 1, tmp);
            break;
        default:
            format_fixed(buf, len, point, negative, prec, tmp);
            break;
    }

    return tmp;
}
