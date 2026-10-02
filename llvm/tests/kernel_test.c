#include "cmoc_os9.h"
#include <assert.h>
#include <errno.h>
#include <stdint.h>
struct syscall_request {
  unsigned code;
  registers_6809 *regs;
};
static int expected, failure, calls;
static registers_6809 incoming, returned;
int __cmoc_syscall(struct syscall_request *q) {
  assert(q->code == (unsigned)expected);
  calls++;
  incoming = *q->regs;
  if (!failure)
    *q->regs = returned;
  return failure;
}
static void setup(int code) {
  expected = code;
  failure = 0;
  memset(&returned, 0, sizeof returned);
}
int main(void) {
  int path = 77, n = 5, status = -1, pid = 33, ticks = 123;
  long value = 12;
  void *module = (void *)0x1234;
  registers_6809 regs = {0};
  char buf[8];
  setup(I$Open);
  returned.a = 9;
  assert(cmoc_os_open("file", 3, &path) == 0 && path == 9 && incoming.a == 3);
  failure = E$PNNF;
  path = 77;
  assert(cmoc_os_open("file", 3, &path) == E$PNNF && path == 77 &&
         errno == E$PNNF);
  setup(I$Create);
  returned.a = 7;
  assert(cmoc_os_create("new", 2, &path, 11) == 0 && path == 7 &&
         incoming.b == 11);
  setup(I$Read);
  returned.y = 3;
  assert(cmoc_os_read(7, buf, &n) == 0 && n == 3 && incoming.y == 5);
  failure = E$Read;
  n = 5;
  assert(cmoc_os_read(7, buf, &n) == E$Read && n == 5);
  failure = E$EOF;
  assert(cmoc_os_read(7, buf, &n) == 0 && n == 0);
  {
    int before = calls;
    n = 0;
    assert(cmoc_os_write(7, buf, &n) == 0 && calls == before);
    n = -1;
    assert(cmoc_os_read(7, buf, &n) == E$BPAddr && calls == before);
  }
  setup(I$GetStt);
  returned.x = 0x1234;
  returned.u = 0x5678;
  assert(cmoc_os_gs_size(7, &value) == 0 && value == 0x12345678L &&
         incoming.b == SS_Size);
  failure = E$BMode;
  value = 12;
  assert(cmoc_os_gs_pos(7, &value) == E$BMode && value == 12);
  setup(I$GetStt);
  failure = E$EOF;
  assert(cmoc_os_gs_eof(7, &status) == 0 && status == -1);
  setup(F$ID);
  returned.y = 0xf123;
  assert(cmoc_os_getuid(&status) == 0 && status == 0xf123);
  setup(F$SUser);
  assert(cmoc_os_asetuid(0xabcd) == 0 && incoming.y == 0xabcd);
  setup(F$ID);
  returned.y = 1;
  assert(cmoc_os_setuid(0) == E$FNA);
  setup(F$Fork);
  returned.a = 42;
  assert(cmoc_os_fork("child", 5, buf, 1, 1, 4, &pid) == 0 && pid == 42 &&
         incoming.a == 0x11 && incoming.b == 4 && incoming.y == 5);
  failure = E$MNF;
  pid = 33;
  assert(cmoc_os_fork("child", 5, buf, 1, 1, 4, &pid) == E$MNF && pid == 33);
  setup(F$Wait);
  returned.a = 42;
  returned.b = 7;
  assert(cmoc_os_wait(&status) == 42 && status == 7);
  setup(F$Link);
  returned.u = 0x4567;
  assert(cmoc_os_modlink("data", 0, 4, &module) == 0 &&
         module == (void *)0x4567 && incoming.a == 0x40);
  failure = E$MNF;
  assert(cmoc_os_modlink("data", 0, 4, &module) == E$MNF &&
         module == (void *)0x4567);
  setup(F$Sleep);
  returned.x = 3;
  assert(cmoc_os9_sleep(&ticks) == 0 && ticks == 3 && incoming.x == 123);
  failure = E$USigP;
  ticks = 123;
  assert(cmoc_os9_sleep(&ticks) == E$USigP && ticks == 123);
  assert(cmoc_os_syscall(256, &regs) == E$UnkSvc);
  puts("LLVM OS-9 register adapter tests passed");
  return 0;
}
