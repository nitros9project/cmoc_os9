#include "cmoc_os9.h"
#include <errno.h>
#include <stdint.h>
void __cmoc_snapshot(registers_6809 *);
void LPX(long v) {
  printf("%x:%xL\n", (unsigned)((uint32_t)v >> 16),
         (unsigned)((uint32_t)v & 65535));
}
void PAUSE(void) {
  char buffer[5];
  int n = sizeof buffer;
  puts("Press Enter to continue...");
  fflush(stdout);
  cmoc_os_readln(0, buffer, &n);
}
void DEBUG(void) {
  registers_6809 r;
  __cmoc_snapshot(&r);
  printf("D=%x X=%x Y=%x S=%x U=%x\n", ((unsigned)r.a << 8) | r.b, r.x, r.y,
         r.s, r.u);
  PAUSE();
}
void _dump(char *label, char *p, int count) {
  int i, j;
  if (label)
    fprintf(stderr, "%s\n", label);
  for (i = 0; i < count; i += 16) {
    fprintf(stderr, "%p: ", (void *)(p + i));
    for (j = 0; j < 16 && i + j < count; j++)
      fprintf(stderr, "%02x ", (unsigned char)p[i + j]);
    fputc('\n', stderr);
  }
}
void tidyup(void) {
  fflush(stdout);
  fflush(stderr);
}
void sync(void) {
  fflush(stdout);
  fflush(stderr);
}
void rpterr(int error) {
  int pid;
  errno = error;
  if (!cmoc_os_getpid(&pid))
    cmoc_os_send(pid, error);
}
/* Explicit instrumentation entry points: LLVM has its own compiler profiling,
 * but old source can still call these tally hooks directly. */
static struct {
  int (*function)(void);
  const char *name;
  unsigned long count;
} profiles[63];
static unsigned used;
void _prof(int (*f)(void), const char *name) {
  unsigned i;
  for (i = 0; i < used; i++)
    if (profiles[i].function == f) {
      profiles[i].count++;
      return;
    }
  if (used == 63)
    return;
  profiles[used].function = f;
  profiles[used].name = name;
  profiles[used++].count = 1;
}
void _dumprof(void) {
  unsigned i;
  fflush(stdout);
  for (i = 0; i < used; i++)
    fprintf(stderr, " %8s() %lu\n", profiles[i].name, profiles[i].count);
}
