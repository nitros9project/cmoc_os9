#include "epyx_arena.h"
#include "epyx_startup.h"
#include "rogue_game.h"

void exit();
int write();

int main()
{
  if (epyx_startup("rogue.dat", "") != 0) {
    write(1, "Cannot load rogue.dat\n", 22);
    exit(1);
  }

  return rogue_game_run();
}
