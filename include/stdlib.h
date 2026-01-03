#ifndef _STDLIB_H
#define _STDLIB_H

#include <sys/types.h>

int rand(void);
void srand(unsigned seed);

#ifndef _CMOC_VERSION_
float    atof(char *str);
#endif
int      atoi(char *str);
long     atol(char *str);
char     *itoa();
char     *ltoa();
char     *utoa();
int      htoi();
long     htol();
int      max(int v1, int v2);
int      min();
unsigned umin();
unsigned umax();

void     *calloc(size_t count, size_t size);
void     free(void *ptr);
void     *malloc(size_t size);
void     *realloc(void *ptr, size_t size);

#endif