#ifndef EPYX_ARENA_H
#define EPYX_ARENA_H

#include "epyx_offsets.h"

extern unsigned char rogue_arena[ROGUE_ARENA_SIZE];

int rogue_load_dat(const char *path);
unsigned char rogue_get8(unsigned int off);
int rogue_get16(unsigned int off);
void rogue_put8(unsigned int off, int value);
void rogue_put16(unsigned int off, int value);
char *rogue_ptr(unsigned int off);
char *rogue_string_at(unsigned int off);
char *rogue_ptr_string(unsigned int table, int index);

#endif
