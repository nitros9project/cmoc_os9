/* Optional floating stdio profile, equivalent to CMOC's libcf choice. */
#include <stdarg.h>
#include <stdio.h>
int __d_vfprintf(FILE *, const char *, va_list);
int vfprintf(FILE *stream, const char *format, va_list args) {
  return __d_vfprintf(stream, format, args);
}
