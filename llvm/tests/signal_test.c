#include "cmoc_os9.h"
#include <assert.h>
#include <errno.h>
#include <setjmp.h>
static int installs, fail, seen, exited;
static jmp_buf exit_jump;
void __cmoc_dispatch_signal(int);
void __cmoc_signal_receiver(void) {}
void *__cmoc_data_base(void) {
  static char data;
  return &data;
}
int cmoc_os_syscall(int code, registers_6809 *r) {
  assert(code == F$Icpt && r);
  installs++;
  if (fail) {
    errno = E$BPAddr;
    return E$BPAddr;
  }
  return 0;
}
void _exit(int status) {
  exited = status;
  longjmp(exit_jump, 1);
}
static void handler(int n) { seen = n; }
int main(void) {
  fail = 1;
  assert(cmoc_signal(3, handler) == CMOC_SIG_ERR && errno == E$BPAddr);
  fail = 0;
  assert(cmoc_signal(3, handler) == CMOC_SIG_DFL);
  assert(installs == 2);
  __cmoc_dispatch_signal(3);
  assert(seen == 3);
  if (!setjmp(exit_jump)) {
    __cmoc_dispatch_signal(3);
    assert(0);
  }
  assert(exited == 3);
  assert(cmoc_signal(4, CMOC_SIG_IGN) == CMOC_SIG_DFL);
  __cmoc_dispatch_signal(4);
  __cmoc_dispatch_signal(4);
  assert(seen == 3);
  assert(cmoc_signal(4, handler) == CMOC_SIG_IGN);
  assert(cmoc_signal(4, CMOC_SIG_DFL) == handler);
  assert(cmoc_signal(0, handler) == CMOC_SIG_ERR && errno == E$USigP);
  assert(cmoc_signal(256, handler) == CMOC_SIG_ERR);
  for (int n = 1; n <= 20; n++)
    assert(cmoc_signal(n, handler) == CMOC_SIG_DFL);
  assert(cmoc_signal(21, handler) == CMOC_SIG_ERR && errno == E$MemFul);
  assert(intercept(handler) == 0);
  __cmoc_dispatch_signal(200);
  assert(seen == 200);
  assert(intercept(0) == 0);
  assert(cmoc_signal(21, handler) == CMOC_SIG_DFL);
  __cmoc_dispatch_signal(21);
  assert(seen == 21 && installs == 2);
  puts("LLVM signal tests passed");
  return 0;
}
