#include "epyx_arena.h"
#include "epyx_startup.h"

static void copy_command_line(command_line)
const char *command_line;
{
  unsigned int off;
  int count;
  char ch;

  off = OFF_COMMAND_LINE;
  count = 0;
  if (command_line == 0) command_line = "";

  do {
    ch = command_line[count];
    if (ch == '\r') ch = 0;
    rogue_put8(off + count, ch);
    count++;
  } while (ch != 0 && count < 20);

  rogue_put8(off + count - 1, 0);
}

int epyx_startup(dat_path, command_line)
const char *dat_path;
const char *command_line;
{
  if (rogue_load_dat(dat_path) != 0) return -1;

  /*
   * The original start routine copies OS-9 parameters into the arena at
   * $1528 after loading rogue.dat. Keep that visible until option parsing is
   * translated from L405F.
   */
  copy_command_line(command_line);
  return 0;
}
