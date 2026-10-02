#include <stdlib.h>
/* Resolve strtod while this archive is searched, before picolibc's atof. */
double atof(const char *text) { return strtod(text, 0); }
