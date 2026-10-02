#include "cmoc_os9.h"
#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
static int legacy(int e) {
  if (e) {
    errno = e;
    return -1;
  }
  return 0;
}
int cmoc_open(const char *n, int m) {
  int p;
  return cmoc_os_open(n, m, &p) ? -1 : p;
}
int cmoc_access(const char *n, int m) {
  int p = cmoc_open(n, m ? m : 1);
  if (p < 0)
    return -1;
  return legacy(cmoc_os_close(p));
}
int cmoc_mknod(const char *n, int m) { return legacy(cmoc_os_makdir(n, m)); }
int cmoc_unlinkx(const char *n, int m) { return legacy(cmoc_os_delete(n, m)); }
int chxdir(const char *n) {
  registers_6809 r = {0};
  r.a = 4;
  r.x = (uint16_t)(uintptr_t)n;
  return legacy(cmoc_os_syscall(I$ChgDir, &r));
}
int create(const char *n, int m, int a) {
  int p, e = cmoc_os_create(n, m, &p, a);
  if (e == E$CEF) {
    e = cmoc_os_delete(n, 0);
    if (!e)
      e = cmoc_os_create(n, m, &p, a);
  }
  return e ? -1 : p;
}
int ocreat(const char *n, int m, int a) { return create(n, m, a); }
int cmoc_creat(const char *n, int m) {
  int p, e = cmoc_os_create(n, m, &p, (m & 0x24) | 11);
  if (e == E$CEF && !(m & 128)) {
    p = cmoc_open(n, m & 7);
    if (p < 0)
      return -1;
    e = cmoc_os_setstat(SS_Size, p, 0, 0, 0);
    if (e) {
      cmoc_os_close(p);
      errno = e;
    }
  }
  return e ? -1 : p;
}
int writeln(int p, const char *b, int n) {
  char *copy;
  int i, result, saved;
  if (n <= 0)
    return cmoc_os_writeln(p, b, &n) ? -1 : n;
  if (!b) {
    errno = E$BPAddr;
    return -1;
  }
  copy = malloc(n);
  if (!copy)
    return -1;
  memcpy(copy, b, n);
  for (i = 0; i < n; i++)
    if (copy[i] == '\n')
      copy[i] = '\r';
  result = cmoc_os_writeln(p, copy, &n) ? -1 : n;
  saved = errno;
  free(copy);
  errno = saved;
  return result;
}
static int descriptor(const char *n, int attr, unsigned owner,
                      int change_owner) {
  unsigned char b[256];
  int p, e, saved;
  p = cmoc_open(n, 2);
  if (p < 0)
    p = cmoc_open(n, 130);
  if (p < 0)
    return errno;
  e = cmoc_os_getstat(SS_FD, p, b, (void *)(uintptr_t)256);
  if (!e) {
    if (change_owner) {
      b[1] = owner >> 8;
      b[2] = owner;
    } else
      b[0] = attr;
    e = cmoc_os_setstat(SS_FD, p, b, 0, 0);
  }
  saved = e;
  e = cmoc_os_close(p);
  if (saved)
    return saved;
  return e;
}
int cmoc_os_ss_attr(const char *n, int a) { return descriptor(n, a, 0, 0); }
int cmoc_chmod(const char *n, int a) { return legacy(cmoc_os_ss_attr(n, a)); }
int cmoc_chown(const char *n, int uid) {
  return legacy(descriptor(n, 0, uid, 1));
}
int devtyp(int p) {
  unsigned char b[32];
  return cmoc_os_gs_popt(p, b) ? -1 : b[0];
}
CMOC_DIR *cmoc_opendir(const char *n) {
  CMOC_DIR *d = malloc(sizeof *d);
  if (!d)
    return 0;
  d->dd_fd = cmoc_open(n, 129);
  if (d->dd_fd < 0) {
    free(d);
    return 0;
  }
  return d;
}
struct direct *cmoc_readdir(CMOC_DIR *d) {
  int n;
  unsigned char *b = d->dd_buf;
  for (;;) {
    n = 32;
    if (cmoc_os_read(d->dd_fd, b, &n) || !n)
      return 0;
    if (n != 32) {
      errno = E$Read;
      return 0;
    }
    if (!b[0])
      continue;
    {
      int i;
      for (i = 0; i < 29; i++) {
        d->entry.d_name[i] = b[i] & 127;
        if (b[i] & 128)
          break;
      }
      d->entry.d_name[i < 29 ? i + 1 : 29] = 0;
    }
    d->entry.d_addr = ((uint32_t)b[29] << 16) | ((uint32_t)b[30] << 8) | b[31];
    return &d->entry;
  }
}
void cmoc_closedir(CMOC_DIR *d) {
  if (d) {
    cmoc_os_close(d->dd_fd);
    free(d);
  }
}
void cmoc_seekdir(CMOC_DIR *d, long pos) { cmoc_os_seek(d->dd_fd, pos); }
long cmoc_telldir(CMOC_DIR *d) {
  long pos;
  return cmoc_os_gs_pos(d->dd_fd, &pos) ? -1 : pos;
}
char *_prgname(void) {
  extern char __os9_progname[];
  return __os9_progname;
}
int _errmsg(int status, const char *fmt, ...) {
  va_list a;
  fprintf(stderr, "%s: ", _prgname());
  va_start(a, fmt);
  vfprintf(stderr, fmt, a);
  va_end(a);
  return status;
}
int dup(int p) {
  registers_6809 r = {0};
  r.a = p;
  return cmoc_os_syscall(I$Dup, &r) ? -1 : r.a;
}
int getw(FILE *f) {
  int hi = getc(f), lo;
  if (hi == EOF)
    return EOF;
  lo = getc(f);
  return lo == EOF ? EOF : (int16_t)((hi << 8) | lo);
}
int putw(int w, FILE *f) {
  if (putc(((unsigned)w >> 8) & 255, f) == EOF || putc(w & 255, f) == EOF)
    return EOF;
  return 0;
}
