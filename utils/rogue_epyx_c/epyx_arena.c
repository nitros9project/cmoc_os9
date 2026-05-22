#include "epyx_arena.h"

int open();
int read();
int close();

unsigned char rogue_arena[ROGUE_ARENA_SIZE];

int rogue_load_dat(path)
const char *path;
{
  int fd;
  int count;

  fd = open(path, 1);
  if (fd < 0) return -1;
  count = read(fd, rogue_arena, ROGUE_DAT_EXPECTED_SIZE);
  close(fd);
  return count == ROGUE_DAT_EXPECTED_SIZE ? 0 : -1;
}
