#include <math.h>

float
ldexp(float x, int exp)
{
    unsigned char *cx = (unsigned char *) &x;
    int biased;

    if (x == 0.0f)
        return 0.0f;

    biased = (int) ((((unsigned) cx[0] & 0x7F) << 1) | ((unsigned) cx[1] >> 7));
    biased += exp;

    if (biased <= 0)
        return 0.0f;

    if (biased > 255)
        biased = 255;

    cx[0] = (cx[0] & 0x80) | (unsigned char) (biased >> 1);
    cx[1] = (cx[1] & 0x7F) | (unsigned char) ((biased & 1) << 7);

    return x;
}
