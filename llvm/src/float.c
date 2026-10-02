#include <errno.h>
#include <math.h>
/* LLVM uses IEEE floating point. Preserve the callable frexp/ldexp API,
 * without copying the CMOC-specific accumulator or MC6839 byte layout. */
double frexp(double x, int *exponent) {
  int e = 0;
  double magnitude;
  if (!exponent) {
    errno = EINVAL;
    return 0;
  }
  *exponent = 0;
  if (x == 0 || !isfinite(x))
    return x;
  magnitude = x < 0 ? -x : x;
  while (magnitude < 0.5) {
    x *= 2;
    magnitude *= 2;
    e--;
  }
  while (magnitude >= 1) {
    x *= 0.5;
    magnitude *= 0.5;
    e++;
  }
  *exponent = e;
  return x;
}
