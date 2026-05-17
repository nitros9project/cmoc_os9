#include <math.h>

float
frexp(float x, int *exp)
{
    unsigned char *cx = (unsigned char *) &x;
    unsigned biased;

    if (exp == 0)
        return 0.0f;

    if (x == 0.0f)
    {
        *exp = 0;
        return 0.0f;
    }

    biased = (((unsigned) cx[0] & 0x7F) << 1) | ((unsigned) cx[1] >> 7);

    if (biased == 0)
    {
        *exp = 0;
        return 0.0f;
    }

    *exp = (int) biased - 126;

    cx[0] = (cx[0] & 0x80) | 0x3F;
    cx[1] &= 0x7F;

    return x;
}
