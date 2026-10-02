#include "cmoc_os9.h"
#include <assert.h>
#include <errno.h>
#include <stdint.h>
static const char *lines[] = {"* comment\n", "malformed\n",
                              "alice,hash,42,128,shell,/dd/alice,start\n",
                              "bob:pass:7:64:Bob B:shell:/dd/bob:login\n"};
static unsigned line;
static int closed;
static unsigned char module[128];
static int unlinked, missing;
static char heap[128];
char *__os9_heap_cur = heap, *__os9_heap_end = heap + sizeof heap;
int cmoc_open(const char *name, int mode) {
  assert(!strcmp(name, PASSWORD) && mode == 1);
  return 0;
}
int readln(int fd, void *buffer, int n) {
  size_t len;
  assert(fd == 0);
  if (line == 4)
    return 0;
  len = strlen(lines[line]);
  assert((int)len < n);
  memcpy(buffer, lines[line++], len);
  return len;
}
int cmoc_os_seek(int fd, long p) {
  assert(fd == 0 && p == 0);
  line = 0;
  return 0;
}
int cmoc_os_close(int fd) {
  assert(fd == 0);
  closed++;
  return 0;
}
int cmoc_os_modlink(const char *name, int lang, int type, void **p) {
  assert(lang == 0);
  if (missing) {
    errno = E$MNF;
    return E$MNF;
  }
  assert(type == 4 || (!strcmp(name, "init") && type == 12));
  *p = module;
  return 0;
}
int cmoc_os_modload(const char *name, int lang, int type, void **p) {
  assert(name && lang == 0 && type == 4);
  *p = module;
  return 0;
}
int cmoc_os_modunlink(void *p) {
  assert(p == module);
  unlinked++;
  return 0;
}
void *sbrk(int n) {
  char *p = __os9_heap_cur;
  if (n < 0 || n > __os9_heap_end - p) {
    errno = E$NoRAM;
    return (void *)-1;
  }
  __os9_heap_cur += n;
  return p;
}
int main(void) {
  PWENT *pw;
  char *data = (char *)1;
  int size = -1;
  mod_data *m = (void *)module;
  mod_config *config = (void *)module;
  pw = getpwent();
  assert(pw && !strcmp(pw->unam, "alice") && !strcmp(pw->uid, "42") &&
         pw->ugcos == 0 && getpwdlm() == ',');
  pw = getpwent();
  assert(pw && !strcmp(pw->unam, "bob") && !strcmp(pw->ugcos, "Bob B") &&
         getpwdlm() == ':');
  assert(!getpwent());
  setpwent();
  pw = getpwnam("ALICE");
  assert(pw && !strcmp(pw->uid, "42"));
  setpwent();
  pw = getpwuid(7);
  assert(pw && !strcmp(pw->unam, "bob"));
  endpwent();
  assert(closed == 1);
  m->m_size = 100;
  m->m_tylan = 0x40;
  m->m_data = sizeof *m;
  m->m_dsize = 16;
  assert(datlink("test", &data, &size) == 0 &&
         data == (char *)module + sizeof *m && size == 16);
  assert(dunlink(data) == 0 && unlinked == 1);
  assert(dunlink(data) == -1 && errno == E$BPAddr);
  missing = 1;
  assert(datlink("test", &data, &size) == 0);
  missing = 0;
  assert(dunlink(data) == 0);
  m->m_data = 99;
  data = (char *)1;
  size = -1;
  assert(datlink("bad", &data, &size) == -1 && data == (char *)1 &&
         size == -1 && errno == E$BMHP);
  m->m_size = 2;
  assert(datlink("bad", &data, &size) == -1);
  memset(module, 0, sizeof module);
  config->m_size = 100;
  config->m_sysdrive = sizeof *config;
  memcpy(module + sizeof *config, "/d\xe4", 3);
  assert(!strcmp(getdrive(), "/dd"));
  memset(heap, 0xa5, sizeof heap);
  assert(cmoc_sbrk(16) == heap);
  for (int i = 0; i < 16; i++)
    assert(heap[i] == 0);
  assert(cmoc_sbrk(-4) == heap + 16 && __os9_heap_cur == heap + 12);
  assert(cmoc_sbrk(-13) == 0 && __os9_heap_cur == heap + 12);
  assert(cmoc_brk(heap + 4) == heap + 12 && __os9_heap_cur == heap + 4);
  assert(cmoc_brk((void *)((uintptr_t)heap + 129)) == 0);
  assert(unbrk(-1) == 0);
  assert(ibrk(124) == heap + 4);
  assert(ibrk(1) == 0);
  puts("LLVM password, module, and heap tests passed");
  return 0;
}
