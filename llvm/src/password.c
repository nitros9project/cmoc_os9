#include "cmoc_os9.h"
#include <errno.h>
static int path = -1;
char _pwdelim = OS9DLM;
static char buffer[PWSIZ + 1];
static PWENT entry;
void setpwent(void) {
  if (path >= 0)
    cmoc_os_seek(path, 0);
}
void endpwent(void) {
  if (path >= 0)
    cmoc_os_close(path);
  path = -1;
}
int getpwdlm(void) { return _pwdelim; }
PWENT *getpwent(void) {
  int n, i, fields;
  char *p, *columns[8];
  if (path < 0) {
    path = cmoc_open(PASSWORD, 1);
    if (path < 0)
      return 0;
  }
  for (;;) {
    n = readln(path, buffer, PWSIZ);
    if (n <= 0)
      return 0;
    buffer[n] = 0;
    p = strpbrk(buffer, "\r\n");
    if (p)
      *p = 0;
    if (!*buffer || *buffer == '*')
      continue;
    p = strpbrk(buffer, ",:");
    if (!p)
      continue;
    _pwdelim = *p;
    columns[0] = buffer;
    fields = 1;
    for (p = buffer; *p; p++)
      if (*p == _pwdelim) {
        *p = 0;
        if (fields < 8)
          columns[fields++] = p + 1;
        else {
          fields = 9;
          break;
        }
      }
    if (fields != (_pwdelim == ':' ? 8 : 7))
      continue;
    i = 0;
    entry.unam = columns[i++];
    entry.upw = columns[i++];
    entry.uid = columns[i++];
    entry.upri = columns[i++];
    entry.ugcos = _pwdelim == ':' ? columns[i++] : 0;
    entry.ucmd = columns[i++];
    entry.udat = columns[i++];
    entry.ujob = columns[i];
    return &entry;
  }
}
PWENT *getpwuid(int uid) {
  PWENT *p;
  while ((p = getpwent()))
    if (atoi(p->uid) == uid)
      return p;
  return 0;
}
PWENT *getpwnam(char *name) {
  PWENT *p;
  while ((p = getpwent()))
    if (!strucmp(p->unam, name))
      return p;
  return 0;
}
