#include "cmoc_os9.h"
#include <assert.h>
#include <errno.h>
static int paths[256], fail_fork, forks, waits, stream_path, closed_stream;
static int stream_token;
int cmoc_open(const char *name, int mode) {
  assert(!strcmp(name, "/pipe") && mode == 3);
  assert(!paths[3]);
  paths[3] = 100;
  return 3;
}
int dup(int path) {
  int n;
  assert(paths[path]);
  for (n = 0; n < 256; n++)
    if (!paths[n]) {
      paths[n] = paths[path];
      return n;
    }
  errno = E$PthFul;
  return -1;
}
int close(int path) {
  assert(paths[path]);
  paths[path] = 0;
  return 0;
}
int cmoc_access(const char *name, int mode) {
  assert(!strcmp(name, "shell") && mode == 4);
  return 0;
}
int os9fork(const char *name, int len, void *args, int lang, int type,
            int pages) {
  assert(!strcmp(name, "echo") && !memcmp(args, "one two\r", 8) && len == 8 &&
         lang == 1 && type == 1 && pages == 0);
  forks++;
  if (fail_fork) {
    errno = E$MNF;
    return -1;
  }
  return 7;
}
int cmoc_wait(int *status) {
  *status = 42;
  waits++;
  return waits % 2 ? 6 : 7;
}
int cmoc_kill(int pid, int signal) {
  assert(pid == 7 && signal == 0);
  return 0;
}
FILE *fdopen(int fd, const char *mode) {
  assert(fd == 3 && (*mode == 'r' || *mode == 'w'));
  stream_path = fd;
  return (FILE *)&stream_token;
}
int fileno(FILE *stream) {
  assert(stream == (FILE *)&stream_token);
  return stream_path;
}
int fclose(FILE *stream) {
  assert(stream == (FILE *)&stream_token);
  closed_stream++;
  return close(stream_path);
}
int main(void) {
  FILE *f;
  paths[0] = 1;
  paths[1] = 2;
  paths[2] = 3;
  assert(cmoc_system(0) == 1);
  assert(cmoc_system("echo one two") == 42 && waits == 2);
  f = cmoc_popen("echo one two", "r");
  assert(f && paths[0] == 1 && paths[1] == 2 && paths[2] == 3 &&
         paths[3] == 100 && !paths[4]);
  assert(cmoc_pclose(f) == 42 && closed_stream == 1 && !paths[3]);
  f = cmoc_popen("echo one two", "w");
  assert(f && paths[0] == 1 && paths[1] == 2);
  assert(cmoc_pclose(f) == 42);
  fail_fork = 1;
  assert(!cmoc_popen("echo one two", "r") && errno == E$MNF);
  assert(paths[0] == 1 && paths[1] == 2 && !paths[3] && !paths[4]);
  assert(!cmoc_popen("echo one two", "rx") && errno == EINVAL);
  assert(cmoc_pclose(0) == -1 && errno == EINVAL);
  assert(cmoc_system("") == -1 && errno == EINVAL);
  assert(forks == 4);
  puts("LLVM command and pipe tests passed");
  return 0;
}
