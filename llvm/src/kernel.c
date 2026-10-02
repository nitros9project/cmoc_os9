#include "cmoc_os9.h"
#include <errno.h>
#include <stddef.h>
#include <stdint.h>
struct syscall_request {
  unsigned code;
  registers_6809 *regs;
};
int __cmoc_syscall(struct syscall_request *);
#ifndef CMOC_HOST_TEST
_Static_assert(sizeof(registers_6809) == 12 && offsetof(registers_6809, u) == 8,
               "register ABI");
_Static_assert(offsetof(struct syscall_request, regs) == 2, "request ABI");
_Static_assert(sizeof(struct fildes) == 256 &&
                   offsetof(struct fildes, fd_fsize) == 9,
               "RBF ABI");
_Static_assert(sizeof(mod_exec) == 13 && sizeof(mod_config) == 20,
               "module ABI");
#endif
static uint16_t ptr(const void *p) { return (uint16_t)(uintptr_t)p; }
static int fail(int code) {
  errno = code;
  return code;
}
static int legacy(int code) { return code ? (errno = code, -1) : 0; }
int cmoc_os_syscall(int code, registers_6809 *regs) {
  struct syscall_request q;
  int e;
  if (!regs || code < 0 || code > 255)
    return fail(E$UnkSvc);
  q.code = code;
  q.regs = regs;
  e = __cmoc_syscall(&q);
  return e ? fail(e) : 0;
}
static int call(int c, registers_6809 *r) { return cmoc_os_syscall(c, r); }
int cmoc_os_open(const char *name, int mode, int *path) {
  registers_6809 r = {0};
  int e;
  r.a = mode;
  r.x = ptr(name);
  e = call(I$Open, &r);
  if (!e && path)
    *path = r.a;
  return e;
}
int cmoc_os_create(const char *name, int mode, int *path, int perm) {
  registers_6809 r = {0};
  int e;
  r.a = mode;
  r.b = perm;
  r.x = ptr(name);
  e = call(I$Create, &r);
  if (!e && path)
    *path = r.a;
  return e;
}
int cmoc_os_close(int path) {
  registers_6809 r = {0};
  r.a = path;
  return call(I$Close, &r);
}
int cmoc_os_delete(const char *name, int mode) {
  registers_6809 r = {0};
  r.a = mode;
  r.x = ptr(name);
  return call(I$DeletX, &r);
}
int cmoc_os_makdir(const char *name, int perm) {
  registers_6809 r = {0};
  r.b = perm;
  r.x = ptr(name);
  return call(I$MakDir, &r);
}
static int transfer(int service, int path, void *buffer, int *count) {
  registers_6809 r = {0};
  int e;
  if (!count || *count < 0 || (!buffer && *count))
    return fail(E$BPAddr);
  if (!*count)
    return 0;
  r.a = path;
  r.x = ptr(buffer);
  r.y = *count;
  e = call(service, &r);
  if (e == E$EOF && (service == I$Read || service == I$ReadLn)) {
    *count = 0;
    return 0;
  }
  if (!e)
    *count = r.y;
  return e;
}
int cmoc_os_read(int p, void *b, int *n) { return transfer(I$Read, p, b, n); }
int cmoc_os_readln(int p, void *b, int *n) {
  return transfer(I$ReadLn, p, b, n);
}
int cmoc_os_write(int p, const void *b, int *n) {
  return transfer(I$Write, p, (void *)b, n);
}
int cmoc_os_writeln(int p, const void *b, int *n) {
  return transfer(I$WritLn, p, (void *)b, n);
}
int cmoc_os_seek(int p, long offset) {
  registers_6809 r = {0};
  r.a = p;
  r.x = (uint32_t)offset >> 16;
  r.u = offset;
  return call(I$Seek, &r);
}
static int statcall(int service, int code, int path, void *p1, void *p2,
                    void *p3, registers_6809 *r) {
  memset(r, 0, sizeof *r);
  r->a = path;
  r->b = code;
  r->x = ptr(p1);
  r->u = ptr(p2);
  r->y = ptr(p3);
  return call(service, r);
}
int cmoc_os_getstat(int code, int path, void *p1, void *p2) {
  registers_6809 r;
  int e;
  e = statcall(I$GetStt, code, path, p1, 0, p2, &r);
  if (!e && (code == SS_Size || code == SS_Pos) && p1)
    *(long *)p1 = ((uint32_t)r.x << 16) | r.u;
  return e;
}
int cmoc_os_setstat(int code, int path, void *p1, void *p2, void *p3) {
  registers_6809 r;
  return statcall(I$SetStt, code, path, p1, p2, p3, &r);
}
int getstat(int c, int p, void *a, void *b) {
  return legacy(cmoc_os_getstat(c, p, a, b));
}
int setstat(int c, int p, void *a, void *b, void *d) {
  return legacy(cmoc_os_setstat(c, p, a, b, d));
}
int cmoc_os_gs_size(int p, long *v) {
  return cmoc_os_getstat(SS_Size, p, v, 0);
}
int cmoc_os_gs_pos(int p, long *v) { return cmoc_os_getstat(SS_Pos, p, v, 0); }
int cmoc_os_gs_ready(int p, int *v) {
  registers_6809 r;
  int e = statcall(I$GetStt, SS_Ready, p, 0, 0, 0, &r);
  if (!e && v)
    *v = r.b;
  return e;
}
int cmoc_os_gs_eof(int p, int *v) {
  registers_6809 r;
  int e = statcall(I$GetStt, SS_EOF, p, 0, 0, 0, &r);
  if (e == E$EOF) {
    if (v)
      *v = -1;
    return 0;
  }
  if (!e && v)
    *v = 0;
  return e;
}
int cmoc_os_gs_popt(int p, void *v) { return cmoc_os_getstat(SS_Opt, p, v, 0); }
int cmoc_os_gs_devnm(int p, char *v) {
  int e = cmoc_os_getstat(SS_DevNm, p, v, 0);
  if (!e) {
    int n;
    for (n = 0; n < 32; n++) {
      unsigned char c = v[n];
      v[n] = c & 127;
      if (c & 128) {
        v[n + 1] = 0;
        break;
      }
      if (!c)
        break;
    }
  }
  return e;
}
int cmoc_os_gs_fd(int p, void *v, int *n) {
  return n ? cmoc_os_getstat(SS_FD, p, v, (void *)(uintptr_t)(unsigned)*n)
           : fail(E$BPAddr);
}
int cmoc_os_gs_scsiz(int p, int *w, int *h) {
  registers_6809 r;
  int e = statcall(I$GetStt, SS_ScSiz, p, 0, 0, 0, &r);
  if (!e) {
    if (w)
      *w = r.x;
    if (h)
      *h = r.y;
  }
  return e;
}
int cmoc_os_ss_popt(int p, void *v) {
  return cmoc_os_setstat(SS_Opt, p, v, 0, 0);
}
int cmoc_os_ss_pfd(int p, void *v) {
  return cmoc_os_setstat(SS_FD, p, v, 0, 0);
}
int cmoc_os_ss_sendsig(int p, int s) {
  return cmoc_os_setstat(SS_SSig, p, (void *)(uintptr_t)(unsigned)s, 0, 0);
}
int cmoc_os_ss_ticks(int p, void *v) {
  return cmoc_os_setstat(SS_Ticks, p, v, 0, 0);
}
int cmoc_os_ss_reset(int p) { return cmoc_os_setstat(SS_Reset, p, 0, 0, 0); }
int cmoc_os_ss_relea(int p) { return cmoc_os_setstat(SS_Relea, p, 0, 0, 0); }
int cmoc_os_getime(cmoc_os_time *t) {
  registers_6809 r = {0};
  r.x = ptr(t);
  return call(F$Time, &r);
}
int cmoc_os_setime(cmoc_os_time *t) {
  registers_6809 r = {0};
  r.x = ptr(t);
  return call(F$STime, &r);
}
int cmoc_os_getpid(int *p) {
  registers_6809 r = {0};
  int e = call(F$ID, &r);
  if (!e && p)
    *p = r.a;
  return e;
}
int cmoc_os_getuid(int *p) {
  registers_6809 r = {0};
  int e = call(F$ID, &r);
  if (!e && p)
    *p = r.y;
  return e;
}
int cmoc_os_asetuid(int uid) {
  registers_6809 r = {0};
  r.y = uid;
  return call(F$SUser, &r);
}
int cmoc_os_setuid(int uid) {
  int current, e = cmoc_os_getuid(&current);
  if (e)
    return e;
  if (current)
    return fail(E$FNA);
  return cmoc_os_asetuid(uid);
}
int cmoc_legacy_getuid(void) {
  int v;
  return cmoc_os_getuid(&v) ? -1 : v;
}
int cmoc_legacy_getpid(void) {
  int v;
  return cmoc_os_getpid(&v) ? -1 : v;
}
int cmoc_setuid(int uid) { return legacy(cmoc_os_setuid(uid)); }
int cmoc_os_send(int p, int s) {
  registers_6809 r = {0};
  r.a = p;
  r.b = s;
  return call(F$Send, &r);
}
int cmoc_os_setpr(int p, int v) {
  registers_6809 r = {0};
  r.a = p;
  r.b = v;
  return call(F$SPrior, &r);
}
int cmoc_os_wait(int *s) {
  registers_6809 r = {0};
  if (call(F$Wait, &r))
    return -1;
  if (s)
    *s = r.b;
  return r.a;
}
int cmoc_wait(int *s) { return cmoc_os_wait(s); }
int setpr(int p, int v) { return legacy(cmoc_os_setpr(p, v)); }
int cmoc_kill(int p, int s) { return legacy(cmoc_os_send(p, s)); }
static int process(int service, const char *n, int len, void *a, int lang,
                   int type, int pages, int *pid) {
  registers_6809 r = {0};
  int e;
  if (len < 0 || pages < 0 || pages > 255)
    return fail(E$IForkP);
  r.x = ptr(n);
  r.y = len;
  r.u = ptr(a);
  r.a = (type << 4) | lang;
  r.b = pages;
  e = call(service, &r);
  if (!e && pid)
    *pid = r.a;
  return e;
}
int cmoc_os_fork(const char *n, int l, void *a, int lang, int type, int pages,
                 int *pid) {
  return process(F$Fork, n, l, a, lang, type, pages, pid);
}
int cmoc_os_chain(const char *n, int l, void *a, int lang, int type,
                  int pages) {
  return process(F$Chain, n, l, a, lang, type, pages, 0);
}
int os9fork(const char *n, int l, void *a, int lang, int type, int pages) {
  int p;
  return cmoc_os_fork(n, l, a, lang, type, pages, &p) ? -1 : p;
}
int chain(const char *n, int l, void *a, int lang, int type, int pages) {
  return legacy(cmoc_os_chain(n, l, a, lang, type, pages));
}
static int module(int service, const char *n, int lang, int type, void **m) {
  registers_6809 r = {0};
  int e;
  r.x = ptr(n);
  r.a = (type << 4) | lang;
  e = call(service, &r);
  if (!e && m)
    *m = (void *)(uintptr_t)r.u;
  return e;
}
int cmoc_os_modlink(const char *n, int l, int t, void **m) {
  return module(F$Link, n, l, t, m);
}
int cmoc_os_modload(const char *n, int l, int t, void **m) {
  return module(F$Load, n, l, t, m);
}
int cmoc_os_modunlink(void *m) {
  registers_6809 r = {0};
  r.u = ptr(m);
  return call(F$UnLink, &r);
}
int cmoc_os9_sleep(int *ticks) {
  registers_6809 r = {0};
  int e;
  if (!ticks)
    return fail(E$BPAddr);
  r.x = *ticks;
  e = call(F$Sleep, &r);
  if (!e)
    *ticks = r.x;
  return e;
}
clock_t tsleep(clock_t t) {
  int n = (uint16_t)t;
  return cmoc_os9_sleep(&n) ? (clock_t)-1 : (unsigned)n;
}
int cmoc_sleep(int seconds) {
  unsigned t = (unsigned)seconds * 60;
  clock_t left = tsleep(t);
  return left == (clock_t)-1 ? -1 : (int)((left + 59) / 60);
}
int cmoc_pause(void) {
  int t = 0;
  return legacy(cmoc_os9_sleep(&t));
}
int prerr(int p, int e) {
  registers_6809 r = {0};
  r.a = p;
  r.b = e;
  return legacy(call(F$PErr, &r));
}
long _gs_size(int p) {
  long v;
  return cmoc_os_getstat(SS_Size, p, &v, 0) ? -1 : v;
}
long _gs_pos(int p) {
  long v;
  return cmoc_os_getstat(SS_Pos, p, &v, 0) ? -1 : v;
}
int _gs_rdy(int p) {
  int v;
  return cmoc_os_gs_ready(p, &v) ? -1 : v;
}
int _gs_eof(int p) {
  int v;
  return cmoc_os_gs_eof(p, &v) ? -1 : v;
}
int _gs_opt(int p, void *v) { return cmoc_os_getstat(SS_Opt, p, v, 0); }
int _gs_devn(int p, char *v) { return cmoc_os_getstat(SS_DevNm, p, v, 0); }
int _gs_gfd(int p, void *v, int n) {
  return cmoc_os_getstat(SS_FD, p, v, (void *)(uintptr_t)(unsigned)n);
}
int _ss_opt(int p, void *v) { return cmoc_os_setstat(SS_Opt, p, v, 0, 0); }
int _ss_pfd(int p, void *v) { return cmoc_os_setstat(SS_FD, p, v, 0, 0); }
int _ss_ssig(int p, void *v) { return cmoc_os_setstat(SS_SSig, p, v, 0, 0); }
int _ss_tiks(int p, void *v) { return cmoc_os_setstat(SS_Ticks, p, v, 0, 0); }
int _ss_rest(int p, void *v) { return cmoc_os_setstat(SS_Reset, p, v, 0, 0); }
int _ss_lock(int p, void *v) { return cmoc_os_setstat(SS_Lock, p, v, 0, 0); }
int _ss_attr(int p, void *v) { return cmoc_os_setstat(SS_Attr, p, v, 0, 0); }
int _ss_rel(int p) { return cmoc_os_ss_relea(p); }
int _ss_size(int p, void *hi, void *lo) {
  return cmoc_os_setstat(SS_Size, p, hi, lo, 0);
}
