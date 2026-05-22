#ifndef EPYX_FORMAT_H
#define EPYX_FORMAT_H

#include <stdarg.h>

char *epyx_format_buffer();
int epyx_vformat(char *dest, int max, const char *fmt, va_list ap);
int epyx_format(char *dest, int max, const char *fmt, ...);
void epyx_printf(const char *fmt, ...);
void epyx_message(const char *fmt, ...);

#endif
