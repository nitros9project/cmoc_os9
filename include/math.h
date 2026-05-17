#ifndef _CMOC_OS9_MATH_H
#define _CMOC_OS9_MATH_H

/**
 * @file math.h
 * @brief Floating-point and trigonometric functions for CMOC OS-9.
 */

#if defined(_CMOC_MC6839_)
/**
 * @brief Trigonometric, exponential, logarithmic, and utility functions
 * backed by the MC6839 floating-point runtime.
 */
float acos(float), asin(float), atan(float), sin(float), cos(float), tan(float);
float pow(float, float), sinh(float), cosh(float), tanh(float), asinh(float), acosh(float), atanh(float);
float exp(float), antilg(float), log10(float), log(float);
float trunc(float), sqrt(float), sqr(float), inv(float);
float frexp(float, int *), ldexp(float, int);
float dexp(float), dabs(float);
#elif defined(_CMOC_NATIVE_FLOAT_)
/**
 * @brief Trigonometric, exponential, logarithmic, and utility functions
 * backed by CMOC native floating-point support.
 */
double acos(double), asin(double), atan(double), sin(double), cos(double), tan(double);
double pow(double, double), sinh(double), cosh(double), tanh(double), asinh(double), acosh(double), atanh(double);
double exp(double), antilg(double), log10(double), log(double);
double trunc(double), sqrt(double), sqr(double), inv(double);
double frexp(double, int *), ldexp(double, int);
double dexp(double), dabs(double);
#endif

/**
 * @brief Convert degrees to the angle unit used by the integer helpers.
 *
 * @param degrees Angle in degrees.
 * @return Converted angle value.
 */
int    rad(int degrees), deg(int radians);

#endif
