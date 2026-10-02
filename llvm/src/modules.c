#include "cmoc_os9.h"
#include <errno.h>
#include <stdint.h>
struct data_link {
  char *data;
  void *module;
  struct data_link *next;
};
static struct data_link *links;
int datlink(const char *name, char **data, int *space) {
  void *header;
  mod_data *m;
  char *d;
  struct data_link *link;
  int e;
  if (!data || !space) {
    errno = E$BPAddr;
    return -1;
  }
  e = cmoc_os_modlink(name, 0, 4, &header);
  if (e == E$MNF)
    e = cmoc_os_modload(name, 0, 4, &header);
  if (e)
    return -1;
  m = header;
  if (m->m_size < 16 || (m->m_tylan & 0xf0) != 0x40 || m->m_data < 13 ||
      m->m_data > m->m_size - 3 || m->m_dsize > m->m_size - m->m_data - 3) {
    cmoc_os_modunlink(header);
    errno = E$BMHP;
    return -1;
  }
  link = malloc(sizeof *link);
  if (!link) {
    cmoc_os_modunlink(header);
    return -1;
  }
  d = (char *)header + m->m_data;
  link->data = d;
  link->module = header;
  link->next = links;
  links = link;
  *data = d;
  *space = m->m_dsize;
  return 0;
}
int dunlink(char *data) {
  struct data_link **p = &links, *l;
  int e;
  while (*p && (*p)->data != data)
    p = &(*p)->next;
  if (!*p) {
    errno = E$BPAddr;
    return -1;
  }
  l = *p;
  e = cmoc_os_modunlink(l->module);
  if (e)
    return -1;
  *p = l->next;
  free(l);
  return 0;
}
char *getdrive(void) {
  static char drive[32];
  void *header;
  mod_config *m;
  unsigned offset, n;
  if (cmoc_os_modlink("init", 0, 12, &header))
    return 0;
  m = header;
  offset = m->m_sysdrive;
  if (m->m_size < sizeof *m + 3 || offset < sizeof *m ||
      offset >= m->m_size - 3) {
    cmoc_os_modunlink(header);
    errno = E$BMHP;
    return 0;
  }
  for (n = 0; n < sizeof drive - 1 && offset + n < m->m_size - 3; n++) {
    unsigned char c = ((unsigned char *)header)[offset + n];
    drive[n] = c & 127;
    if (!c || (c & 128))
      break;
  }
  drive[n < 31 ? n + 1 : 31] = 0;
  cmoc_os_modunlink(header);
  return drive;
}
