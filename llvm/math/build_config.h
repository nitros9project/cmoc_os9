/* Choose the self-contained fdlibm algorithms in the vendored sources. */
#include <math.h>
#undef __OBSOLETE_MATH_DOUBLE
#define __OBSOLETE_MATH_DOUBLE 1
#undef __OBSOLETE_MATH_FLOAT
#define __OBSOLETE_MATH_FLOAT 1
