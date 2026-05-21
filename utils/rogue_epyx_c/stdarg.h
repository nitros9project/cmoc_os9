/* Minimal CMOC stdarg support for this standalone reconstruction. */
#ifndef EPYX_STDARG_H
#define EPYX_STDARG_H

typedef char *va_list;

char *__va_arg(va_list *app, unsigned int sizeInBytes);

#define va_start(ap, lastFixed) do { (ap) = (char *) &(lastFixed) + sizeof(lastFixed); } while (0)
#define va_arg(ap, type) (* (type *) __va_arg(&(ap), sizeof(type)))
#define va_end(ap) do {} while (0)

#endif
