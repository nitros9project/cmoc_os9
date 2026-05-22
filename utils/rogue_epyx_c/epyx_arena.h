#ifndef EPYX_ARENA_H
#define EPYX_ARENA_H

#include "epyx_offsets.h"

extern unsigned char rogue_arena[ROGUE_ARENA_SIZE];

int rogue_load_dat(const char *path);

#define rogue_get8(off) (rogue_arena[(off)])
#define rogue_get16(off) (((int) rogue_arena[(off)] << 8) | rogue_arena[(off) + 1])
#define rogue_put8(off, value) (rogue_arena[(off)] = (unsigned char) (value))
#define rogue_put16(off, value) \
  (rogue_arena[(off)] = (unsigned char) ((value) >> 8), \
   rogue_arena[(off) + 1] = (unsigned char) (value))
#define rogue_ptr(off) ((char *) (rogue_arena + (off)))
#define rogue_string_at(off) ((char *) (rogue_arena + (off)))

#endif
