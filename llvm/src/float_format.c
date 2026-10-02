#include "../stdio/local-stdio.h"
#include "cmoc_os9.h"
#include <errno.h>
#include <stdarg.h>
int __d_vfprintf(FILE *, const char *, va_list);
static int format_double(char *dest, size_t size, const char *format, ...) {
  struct __file_str stream =
      FDEV_SETUP_STRING_WRITE(dest, FDEV_STRING_WRITE_END(dest, size));
  va_list args;
  int result;
  va_start(args, format);
  result = __d_vfprintf(&stream.file, format, args);
  va_end(args);
  if (size)
    *stream.pos = 0;
  return result;
}
char *ftoa(char out[38], float value) {
  if (!out) {
    errno = EINVAL;
    return 0;
  }
  if (format_double(out, 38, "%.7g", (double)value) < 0)
    return 0;
  if (out[0] == '0' && out[1] == '.')
    memmove(out, out + 1, strlen(out));
  else if (out[0] == '-' && out[1] == '0' && out[2] == '.')
    memmove(out + 1, out + 2, strlen(out + 1));
  return out;
}
char *pffloat(int conversion, int precision, float **arguments) {
  static char out[384];
  char format[6] = {'%', '.', '*', 0, 0, 0};
  double value;
  char digits[38];
  int result;
  if (!arguments || !*arguments || !strchr("eEfgG", conversion) ||
      !conversion || precision > 32) {
    errno = EINVAL;
    return 0;
  }
  if (precision < 0)
    precision = 6;
  if (!ftoa(digits, **arguments))
    return 0;
  value = strtod(digits, 0);
  (*arguments)++;
  format[3] = conversion;
  result = format_double(out, sizeof out, format, precision, (double)value);
  if (result < 0 || (unsigned)result >= sizeof out) {
    errno = ERANGE;
    return 0;
  }
  return out;
}
