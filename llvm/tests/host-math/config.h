#include <math.h>
#include "machine/ieeefp.h"
#define __OBSOLETE_MATH_FLOAT 1
#define __OBSOLETE_MATH 1
int isnanf(float);

#define __OBSOLETE_MATH_DOUBLE 1
int __isnan(double);

#define __DOUBLE_TYPE double
#define _LDBL_EQ_DBL 1
#define __noinline __attribute__((__noinline__))
