#include <assert.h>
#include <errno.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
static void near(float actual, double expected) {
  assert(isfinite(actual));
  assert(fabs(actual - expected) <= 8e-6 * (fabs(expected) + 1));
}
int main(void) {
  const float values[] = {-100,   -3,   -1, -0.5f, -0.001f, 0,
                          0.001f, 0.5f, 1,  3,     100};
  for (unsigned i = 0; i < sizeof values / sizeof *values; ++i) {
    double x = values[i];
    near(sinf(x), sin(x));
    near(cosf(x), cos(x));
    near(tanf(x), tan(x));
    near(atanf(x), atan(x));
    near(asinhf(x), asinh(x));
    near(tanhf(x), tanh(x));
    near(truncf(x), trunc(x));
    if (fabs(x) <= 1) {
      near(asinf(x), asin(x));
      near(acosf(x), acos(x));
    }
    if (fabs(x) < 1)
      near(atanhf(x), atanh(x));
    if (fabs(x) < 80) {
      near(expf(x), exp(x));
      near(sinhf(x), sinh(x));
      near(coshf(x), cosh(x));
    }
    if (x > 0) {
      near(logf(x), log(x));
      near(log10f(x), log10(x));
      near(sqrtf(x), sqrt(x));
      near(powf(x, 1.25f), pow(x, 1.25));
    }
    if (x >= 1)
      near(acoshf(x), acosh(x));
  }
  const uint32_t words[] = {1,          0x7f7fffff, 0x4f123456,
                            0x5f654321, 0x6f234567, 0x7f123456};
  for (unsigned i = 0; i < sizeof words / sizeof *words; ++i) {
    float x;
    memcpy(&x, &words[i], 4);
    near(sinf(x), sin((double)x));
    near(cosf(x), cos((double)x));
    near(logf(x), log((double)x));
    near(sqrtf(x), sqrt((double)x));
  }
  assert(isnan(sqrtf(-1)));
  assert(isnan(acosf(2)));
  assert(isnan(logf(-1)));
  assert(isinf(logf(0)) && signbit(logf(0)));
  assert(isinf(expf(100)));
  assert(expf(-120) == 0);
  assert(signbit(sinf(-0.0f)));
  assert(sqrtf(INFINITY) == INFINITY);
  assert(isnan(sinf(INFINITY)));
  assert(isnan(powf(-1, 0.5f)));
  assert(antilg(2) == 100 && sqr(-3) == 9 && inv(4) == 0.25 && dabs(-4) == 4);
  assert(dexp(0.75, 4) == 12);
  deg();
  assert(fabs(cmoc_sin(30) - 0.5) < 1e-6 && fabs(cmoc_acos(0) - 90) < 1e-6);
  rad();
  assert(fabs(cmoc_sin(0.5) - sin(0.5)) < 1e-6);
  puts("math tests passed");
  return 0;
}
