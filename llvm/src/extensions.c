#include "cmoc_os9.h"
#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>
char *strhcpy(char *d, const char *s) {
  char *start = d;
  unsigned char c;
  do {
    c = *s++;
    if (!c)
      break;
    *d++ = c & 127;
  } while (!(c & 128));
  *d = 0;
  return start;
}
char *strclr(char *s, int n) {
  if (n > 0)
    memset(s, 0, n);
  return s;
}
char *strend(const char *s) { return (char *)s + strlen(s); }
char *strucpy(char *d, const char *s) {
  char *start = d;
  while ((*d++ = toupper((unsigned char)*s++))) {
  }
  return start;
}
char *strucat(char *d, const char *s) {
  strucpy(strend(d), s);
  return d;
}
int strucmp(const char *a, const char *b) {
  unsigned char x, y;
  do {
    x = toupper((unsigned char)*a++);
    y = toupper((unsigned char)*b++);
    if (x != y)
      return (int)x - y;
  } while (x);
  return 0;
}
int strnucmp(const char *a, const char *b, size_t n) {
  while (n--) {
    unsigned char x = toupper((unsigned char)*a++),
                  y = toupper((unsigned char)*b++);
    if (x != y)
      return (int)x - y;
    if (!x)
      break;
  }
  return 0;
}
int memncmp(const char *a, const char *b, size_t n) { return memcmp(a, b, n); }
char *reverse(char *s) {
  size_t i, n = strlen(s);
  for (i = 0; i < n / 2; i++) {
    char c = s[i];
    s[i] = s[n - i - 1];
    s[n - i - 1] = c;
  }
  return s;
}
char *findstr(const char *h, const char *n) { return strstr(h, n); }
char *findnstr(const char *h, const char *n, int limit) {
  int i;
  size_t len = strlen(n);
  if (!len)
    return (char *)h;
  for (i = 0; i < limit && h[i]; i++)
    if (!strncmp(h + i, n, len))
      return (char *)h + i;
  return 0;
}
void _strass(char *d, char *s, int n) {
  if (n > 0)
    memcpy(d, s, n);
}
int cmoc_swab(int v) {
  return (uint16_t)(((uint16_t)v << 8) | ((uint16_t)v >> 8));
}
char *skipbl(char *s) {
  while (*s == ' ' || *s == '\t')
    s++;
  return (char *)s;
}
char *skipwd(char *s) {
  while (*s && *s != ' ' && *s != '\t')
    s++;
  return (char *)s;
}
char *strtohstr(char *d, const char *s) {
  char *start;
  if (!s)
    return 0;
  if (!d)
    d = (char *)s;
  start = d;
  while (*s)
    *d++ = *s++;
  if (d != start)
    d[-1] |= 128;
  else
    *d = 0;
  return start;
}
char *hstrtostr(char *d, char *s) {
  if (!s)
    return 0;
  if (!d)
    d = s;
  return strhcpy(d, s);
}
int hputs(const char *s) {
  unsigned char c;
  do {
    c = *s++;
    if (!c)
      break;
    if (putchar(c & 127) == EOF)
      return EOF;
  } while (!(c & 128));
  return 0;
}
int min(int a, int b) { return a < b ? a : b; }
int max(int a, int b) { return a > b ? a : b; }
unsigned umin(unsigned a, unsigned b) { return a < b ? a : b; }
unsigned umax(unsigned a, unsigned b) { return a > b ? a : b; }
int htoi(const char *s) { return (int)strtoul(s, 0, 16); }
long htol(const char *s) { return (long)strtoul(s, 0, 16); }
char *ltoa(long v, char *b) {
  sprintf(b, "%ld", v);
  return b;
}
char *cmoc_itoa(int v, char *b) {
  sprintf(b, "%d", v);
  return b;
}
char *cmoc_utoa(unsigned v, char *b) {
  sprintf(b, "%u", v);
  return b;
}
char *itoa10(int v, char *b) { return cmoc_itoa(v, b); }
char *utoa10(unsigned v, char *b) { return cmoc_utoa(v, b); }
void c3tol(long *v, const char *p) {
  *v = ((uint32_t)(unsigned char)p[0] << 16) |
       ((uint32_t)(unsigned char)p[1] << 8) | (unsigned char)p[2];
}
void ltoc3(char *p, long v) {
  p[0] = (uint32_t)v >> 16;
  p[1] = (uint32_t)v >> 8;
  p[2] = v;
}
void l3tol(long *v, const char *p, int n) {
  while (n-- > 0) {
    c3tol(v++, p);
    p += 3;
  }
}
void ltol3(char *p, const long *v, int n) {
  while (n-- > 0) {
    ltoc3(p, *v++);
    p += 3;
  }
}
int crc(void *buffer, size_t n, void *accum) {
  unsigned char *a = accum;
  const unsigned char *p = buffer;
  uint32_t v = ((uint32_t)a[0] << 16) | ((uint32_t)a[1] << 8) | a[2];
  while (n--) {
    int i;
    v ^= (uint32_t)*p++ << 16;
    for (i = 0; i < 8; i++) {
      v <<= 1;
      if (v & 0x1000000UL)
        v ^= 0x800063UL;
      v &= 0xffffffUL;
    }
  }
  a[0] = v >> 16;
  a[1] = v >> 8;
  a[2] = v;
  return 0;
}
char *pwcryp(char *s) {
  unsigned char a[3] = {255, 255, 255};
  static const char hex[] = "0123456789ABCDEF";
  int i;
  crc(s, strlen(s), a);
  for (i = 0; i < 3; i++) {
    s[i * 2] = hex[a[i] >> 4];
    s[i * 2 + 1] = hex[a[i] & 15];
  }
  s[6] = 0;
  return s;
}
char *allocset(void) { return calloc(32, 1); }
char *addc2set(char *s, int c) {
  unsigned char v = c;
  s[v >> 3] |= (1u << (v & 7));
  return s;
}
char *rmfmset(char *s, int c) {
  unsigned char v = c;
  s[v >> 3] &= ~(1u << (v & 7));
  return s;
}
int smember(char *s, int c) {
  unsigned char v = c;
  return (unsigned char)s[v >> 3] & (1u << (v & 7));
}
char *adds2set(char *s, const char *p) {
  while (*p)
    addc2set(s, (unsigned char)*p++);
  return s;
}
char *copyset(char *d, char *s) {
  memcpy(d, s, 32);
  return d;
}
char *dupset(char *s) {
  char *d = malloc(32);
  return d ? copyset(d, s) : 0;
}
char *sunion(char *d, char *s) {
  int i;
  for (i = 0; i < 32; i++)
    d[i] |= s[i];
  return d;
}
char *sintersect(char *d, char *s) {
  int i;
  for (i = 0; i < 32; i++)
    d[i] &= s[i];
  return d;
}
char *sdifference(char *d, char *s) {
  int i;
  for (i = 0; i < 32; i++)
    d[i] &= ~s[i];
  return d;
}
