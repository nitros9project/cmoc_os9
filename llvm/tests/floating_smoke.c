#include "cmoc_os9.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(void) {
  char buffer[64], raw[38], *end;
  float value = 18.44f, *argument = &value;
  if (atof("6.25E1") != 62.5)
    return 1;
  if (strtod("-0x1.8p+2tail", &end) != -6 || strcmp(end, "tail"))
    return 2;
  if (strtod("invalid", &end) != 0 || strcmp(end, "invalid"))
    return 3;
  if (!isinf(strtod("inf", 0)) || !isnan(strtod("nan", 0)))
    return 4;
  if (strcmp(ftoa(raw, value), "18.44"))
    return 5;
  snprintf(buffer, sizeof buffer, "%.6f", (double)value);
  if (strcmp(buffer, "18.440001"))
    return 6; /* Native IEEE float rounded as double. */
  if (strcmp(pffloat('e', 6, &argument), "1.844000e+01"))
    return 7;
  puts("LLVM floating conversion/stdio smoke passed");
  return 0;
}
