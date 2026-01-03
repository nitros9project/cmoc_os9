#include <sys/types.h>

#ifndef _STRING_H
#define _STRING_H

char  *strcat(char *s1, const char *s2);
char  *strncat(char *s1, const char *s2, size_t n);
char  *strhcpy(char *dst, const char *src);
char  *strcpy(char *dst, const char *src);
char  *strncpy(char *dst, const char *src, size_t len);
char  *strclr(char *str, int cnt);
char  *strucat(char *s1, const char *s2);
char  *strucpy(char *dst, const char *src);
char  *index(const char *str, int c);
char  *rindex(const char *str, int c);
char  *reverse(char *str);
const char  *strend(const char *str);
int   strcmp(const char *s1, const char *s2);
int   strncmp(const char *s1, const char *s2, size_t len);
int   strlen(const char *s);
int   strucmp(const char *s1, const char *s2);
int   strnucmp(const char *s1, const char *s2, size_t len);
int   patmatch(const char *pattern, const char *str, char forceCase);
const char  *strchr(const char *str, int c);
const char  *strrchr(const char *str, int c);
size_t strspn(const char *s1, const char *s2);
size_t strcspn(const char *s1, const char *s2);
char  *strtok(char *str, const char *step);
const char  *strpbrk(const char *s1, const char *s2);

void _strass(char *to, char *from, int count);

void *memcpy(void *dst, const void *src, size_t len);
void *memset(void *dst, int c, size_t len);
void *memchr(void *data, int c, size_t len);
int memcmp(const char *dst, const char *src);
int memncmp(const char *dst, const char *src, size_t len);

/* Convert string to hstring. */
char *strtohstr(char *dst, const char *src);
/* Convert hstring to string. */
char *hstrtostr(char *dst, const char *src);
/* Print a hstr */
int hputs(char *);

#endif
