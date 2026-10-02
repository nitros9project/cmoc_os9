#ifndef CMOC_LLVM_MATH_H
#define CMOC_LLVM_MATH_H
#include_next <math.h>
/* IEEE standard math stays in radians. Legacy angle mode is opt-in. */
double antilg(double);
double sqr(double);
double inv(double);
double dabs(double);
double dexp(double, int);
int rad(void);
int deg(void);
double cmoc_acos(double);
double cmoc_asin(double);
double cmoc_atan(double);
double cmoc_cos(double);
double cmoc_sin(double);
double cmoc_tan(double);
#endif
