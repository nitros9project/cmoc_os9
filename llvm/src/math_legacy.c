#include <errno.h>
#include <math.h>
static int degrees;
static const double radians_per_degree = 0.017453292519943295;
int rad(void) {
  degrees = 0;
  return 0;
}
int deg(void) {
  degrees = 1;
  return 0;
}
double cmoc_sin(double x) { return sin(degrees ? x * radians_per_degree : x); }
double cmoc_cos(double x) { return cos(degrees ? x * radians_per_degree : x); }
double cmoc_tan(double x) { return tan(degrees ? x * radians_per_degree : x); }
double cmoc_asin(double x) {
  double y = asin(x);
  return degrees ? y / radians_per_degree : y;
}
double cmoc_acos(double x) {
  double y = acos(x);
  return degrees ? y / radians_per_degree : y;
}
double cmoc_atan(double x) {
  double y = atan(x);
  return degrees ? y / radians_per_degree : y;
}
double antilg(double x) { return pow(10, x); }
double sqr(double x) { return x * x; }
double inv(double x) {
  if (x == 0)
    errno = ERANGE;
  return 1 / x;
}
double dabs(double x) { return fabs(x); }
double dexp(double x, int exponent) { return ldexp(x, exponent); }
