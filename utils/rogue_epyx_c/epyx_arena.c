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

unsigned char rogue_get8(off)
unsigned int off;
{
  return rogue_arena[off];
}

int rogue_get16(off)
unsigned int off;
{
  return rogue_arena[off] * 256 + rogue_arena[off + 1];
}

void rogue_put8(off, value)
unsigned int off;
int value;
{
  rogue_arena[off] = (unsigned char) value;
}

void rogue_put16(off, value)
unsigned int off;
int value;
{
  rogue_arena[off] = (unsigned char) (value / 256);
  rogue_arena[off + 1] = (unsigned char) value;
}

char *rogue_ptr(off)
unsigned int off;
{
  return (char *) (rogue_arena + off);
}

char *rogue_string_at(off)
unsigned int off;
{
  return rogue_ptr(off);
}

char *rogue_ptr_string(table, index)
unsigned int table;
int index;
{
  return rogue_string_at(rogue_get16(table + index * 2));
}
