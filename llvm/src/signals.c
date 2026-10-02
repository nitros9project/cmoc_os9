#include "cmoc_os9.h"
#include <errno.h>
#include <stdint.h>
void __cmoc_signal_receiver(void);
void *__cmoc_data_base(void);
static cmoc_sighandler_t interceptor;
static struct {
  unsigned char number;
  cmoc_sighandler_t handler;
} traps[20];
static int installed;
static int install(void) {
  registers_6809 r = {0};
  int e;
  if (installed)
    return 0;
  r.x = (uint16_t)(uintptr_t)__cmoc_signal_receiver;
  r.u = (uint16_t)(uintptr_t)__cmoc_data_base();
  e = cmoc_os_syscall(F$Icpt, &r);
  if (!e)
    installed = 1;
  return e;
}
int intercept(cmoc_sighandler_t handler) {
  int e = install();
  if (e)
    return -1;
  interceptor = handler;
  memset(traps, 0, sizeof traps);
  return 0;
}
cmoc_sighandler_t cmoc_signal(int n, cmoc_sighandler_t h) {
  int i, free_slot = -1;
  cmoc_sighandler_t old;
  if (n <= 0 || n > 255) {
    errno = E$USigP;
    return CMOC_SIG_ERR;
  }
  for (i = 0; i < 20; i++) {
    if (traps[i].number == n)
      break;
    if (!traps[i].number && free_slot < 0)
      free_slot = i;
  }
  if (i == 20)
    i = free_slot;
  if (i < 0) {
    errno = E$MemFul;
    return CMOC_SIG_ERR;
  }
  if (install())
    return CMOC_SIG_ERR;
  old = traps[i].handler;
  interceptor = 0;
  traps[i].number = h ? n : 0;
  traps[i].handler = h;
  return old;
}
void __cmoc_dispatch_signal(int n) {
  int i;
  cmoc_sighandler_t h;
  if (interceptor) {
    interceptor(n);
    return;
  }
  for (i = 0; i < 20; i++)
    if (traps[i].number == n) {
      h = traps[i].handler;
      if (h == CMOC_SIG_IGN)
        return;
      traps[i].number = 0;
      traps[i].handler = 0;
      if (h) {
        h(n);
        return;
      }
    }
  _exit(n);
}
