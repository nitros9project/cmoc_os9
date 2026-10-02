#include "cmoc_os9.h"
#include <errno.h>
#include <stdint.h>
extern char *__os9_heap_cur, *__os9_heap_end;
static char *floor;
static void bounds(void) {
  if (!floor)
    floor = __os9_heap_cur;
}
void *cmoc_sbrk(int n) {
  char *old;
  void *p;
  bounds();
  old = __os9_heap_cur;
  if (n < 0) {
    if ((uintptr_t)old - (uintptr_t)floor < (unsigned)(-(long)n)) {
      errno = E$NoRAM;
      return 0;
    }
    __os9_heap_cur += n;
    return old;
  }
  p = sbrk(n);
  if (p == (void *)-1)
    return 0;
  if (n)
    memset(p, 0, n);
  return p;
}
void *cmoc_brk(void *p) {
  uintptr_t target = (uintptr_t)p, current;
  bounds();
  current = (uintptr_t)__os9_heap_cur;
  if (target < (uintptr_t)floor || target > (uintptr_t)__os9_heap_end) {
    errno = E$NoRAM;
    return 0;
  }
  __os9_heap_cur = p;
  return (void *)current;
}
void *ibrk(int n) { return cmoc_sbrk(n); }
void *unbrk(int n) {
  if (n < 0) {
    errno = E$IBA;
    return 0;
  }
  return cmoc_sbrk(-n);
}
