#include "cmoc_os9.h"
#include <errno.h>
#include <stdint.h>
static int children[256];
static char *command_parts(const char *s, char **args, int *length) {
  char *p, *end;
  size_t n;
  if (!s || !*s) {
    errno = EINVAL;
    return 0;
  }
  n = strlen(s);
  if (n > 32764) {
    errno = E$IForkP;
    return 0;
  }
  p = malloc(n + 2);
  if (!p)
    return 0;
  memcpy(p, s, n + 1);
  end = p;
  while (*end && *end != ' ' && *end != '\t')
    end++;
  if (*end)
    *end++ = 0;
  while (*end == ' ' || *end == '\t')
    end++;
  *args = end;
  *length = strlen(end);
  end[*length] = '\r';
  end[++*length] = 0;
  return p;
}
int cmoc_system(const char *command) {
  char *p, *args;
  int length, pid, status, child;
  if (!command)
    return cmoc_access("shell", 4) == 0;
  p = command_parts(command, &args, &length);
  if (!p)
    return -1;
  pid = os9fork(p, length, args, 1, 1, 0);
  free(p);
  if (pid < 0)
    return -1;
  while ((child = cmoc_wait(&status)) >= 0)
    if (child == pid)
      return status;
  return -1;
}
FILE *cmoc_popen(const char *command, const char *mode) {
  int pipe, saved, target, pid, length, error, other;
  char *copy, *args;
  FILE *stream;
  if (!mode || (mode[0] != 'r' && mode[0] != 'w') || mode[1]) {
    errno = EINVAL;
    return 0;
  }
  copy = command_parts(command, &args, &length);
  if (!copy)
    return 0;
  pipe = cmoc_open("/pipe", 3);
  if (pipe < 0) {
    free(copy);
    return 0;
  }
  target = mode[0] == 'r' ? 1 : 0;
  saved = dup(target);
  if (saved < 0) {
    error = errno;
    close(pipe);
    free(copy);
    errno = error;
    return 0;
  }
  if (close(target) < 0) {
    error = errno;
    close(saved);
    close(pipe);
    free(copy);
    errno = error;
    return 0;
  }
  other = dup(pipe);
  if (other != target) {
    error = errno;
    if (other >= 0)
      close(other);
    dup(saved);
    close(saved);
    close(pipe);
    free(copy);
    errno = error;
    return 0;
  }
  pid = os9fork(copy, length, args, 1, 1, 0);
  error = errno;
  close(target);
  other = dup(saved);
  close(saved);
  free(copy);
  if (pid < 0 || other != target) {
    if (pid >= 0)
      cmoc_kill(pid, 0);
    close(pipe);
    errno = error;
    return 0;
  }
  stream = fdopen(pipe, mode);
  if (!stream) {
    error = errno;
    close(pipe);
    while ((other = cmoc_wait(&length)) >= 0 && other != pid) {
    }
    errno = error;
    return 0;
  }
  children[pipe] = pid;
  return stream;
}
int cmoc_pclose(FILE *stream) {
  int fd, pid, status, child, e;
  if (!stream) {
    errno = EINVAL;
    return -1;
  }
  fd = fileno(stream);
  if (fd < 0 || fd > 255 || !children[fd]) {
    errno = EINVAL;
    return -1;
  }
  pid = children[fd];
  children[fd] = 0;
  e = fclose(stream);
  while ((child = cmoc_wait(&status)) >= 0)
    if (child == pid)
      return e ? -1 : status;
  return -1;
}
