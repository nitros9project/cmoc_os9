#include <os.h>
#include <os9abi.h>

#include "epyx_arena.h"
#include "epyx_format.h"
#include "epyx_screen.h"
#include "epyx_tables.h"
#include "rogue_game.h"

int read();
int open();
int close();

#define DUNGEON_X      2
#define DUNGEON_Y      2
#define DUNGEON_WIDTH  38
#define DUNGEON_HEIGHT 16
#define OPT_COUNT      32
#define OPT_ECHO       4
#define OPT_PAUSE      7

static int hero_x;
static int hero_y;
static int turns;
static char saved_stdin_opts[OPT_COUNT];
static int have_saved_stdin_opts;

static void copy_opts(dest, src)
char *dest;
char *src;
{
  int i;

  for (i = 0; i < OPT_COUNT; i++) dest[i] = src[i];
}

static void terminal_game_mode()
{
  registers_6809 regs;
  char opts[OPT_COUNT];

  have_saved_stdin_opts = 0;
  regs.a = 0;
  regs.b = SS_Opt;
  regs.x = (int) saved_stdin_opts;
  regs.y = 0;
  if (_os_syscall(I$GetStt, &regs) != 0) return;

  copy_opts(opts, saved_stdin_opts);
  opts[OPT_ECHO] = 0;
  opts[OPT_PAUSE] = 0;
  regs.a = 0;
  regs.b = SS_Opt;
  regs.x = (int) opts;
  regs.y = 0;
  if (_os_syscall(I$SetStt, &regs) == 0) have_saved_stdin_opts = 1;
}

static void terminal_restore()
{
  registers_6809 regs;

  if (!have_saved_stdin_opts) return;
  regs.a = 0;
  regs.b = SS_Opt;
  regs.x = (int) saved_stdin_opts;
  regs.y = 0;
  _os_syscall(I$SetStt, &regs);
}

static void put_at(x, y, ch)
int x;
int y;
int ch;
{
  epyx_move_cursor(x, y);
  epyx_write_char(ch);
}

static void draw_horizontal(y)
int y;
{
  int x;

  put_at(DUNGEON_X, y, '+');
  for (x = 1; x < DUNGEON_WIDTH - 1; x++) epyx_write_char('-');
  epyx_write_char('+');
}

static void draw_room()
{
  int y;
  int x;

  draw_horizontal(DUNGEON_Y);
  for (y = 1; y < DUNGEON_HEIGHT - 1; y++) {
    put_at(DUNGEON_X, DUNGEON_Y + y, '|');
    for (x = 1; x < DUNGEON_WIDTH - 1; x++) epyx_write_char('.');
    epyx_write_char('|');
  }
  draw_horizontal(DUNGEON_Y + DUNGEON_HEIGHT - 1);

  put_at(DUNGEON_X + 12, DUNGEON_Y, '+');
  put_at(DUNGEON_X + 12, DUNGEON_Y - 1, '#');
  put_at(DUNGEON_X + 24, DUNGEON_Y + DUNGEON_HEIGHT - 1, '+');
  put_at(DUNGEON_X + 24, DUNGEON_Y + DUNGEON_HEIGHT, '#');
}

static void draw_status()
{
  epyx_move_cursor(0, DUNGEON_Y + DUNGEON_HEIGHT + 2);
  epyx_reverse_on();
  epyx_printf(" Level:%d  Gold:%d  Hp:%d(%d)  Ac:%d  Str:%d  Exp:%d/%d ",
              1, 0, 12, 12, 10, 16, 1, 0);
  epyx_reverse_off();
  epyx_clear_to_eol();
}

static void draw_hero()
{
  put_at(hero_x, hero_y, '@');
  rogue_put16(OFF_HERO_POS, hero_y * 256 + hero_x);
}

static void erase_hero()
{
  put_at(hero_x, hero_y, '.');
}

static int is_walkable(x, y)
int x;
int y;
{
  return x > DUNGEON_X && x < DUNGEON_X + DUNGEON_WIDTH - 1 &&
         y > DUNGEON_Y && y < DUNGEON_Y + DUNGEON_HEIGHT - 1;
}

static void try_move(dx, dy)
int dx;
int dy;
{
  int nx;
  int ny;

  nx = hero_x + dx;
  ny = hero_y + dy;
  if (!is_walkable(nx, ny)) {
    epyx_message("You bump into a wall.");
    return;
  }

  erase_hero();
  rogue_put16(OFF_OLD_HERO_POS, hero_y * 256 + hero_x);
  hero_x = nx;
  hero_y = ny;
  turns++;
  draw_hero();
  epyx_message("Moved to %d,%d.  q quits.", hero_x, hero_y);
}

static int read_key()
{
  char ch;

  if (read(0, &ch, 1) != 1) return -1;
  return ch;
}

static void wait_for_space_or_escape()
{
  int ch;

  epyx_message("SPACE to continue ESC to quit");
  while (1) {
    ch = read_key();
    if (ch == 27 || ch == 26 || ch == 'q' || ch == 'Q') break;
    if (ch == ' ') break;
  }
}

static int read_help_line(fd, line, max)
int fd;
char *line;
int max;
{
  int len;
  char ch;

  len = 0;
  while (len < max - 1) {
    if (read(fd, &ch, 1) != 1) break;
    if (ch == '\r' || ch == '\n') break;
    line[len++] = ch;
  }
  line[len] = 0;
  return len;
}

static void show_help_file(path)
const char *path;
{
  int fd;
  int y;
  char line[40];

  fd = open(path, 1);
  if (fd < 0) {
    epyx_message("Can't open \"%s\".", path);
    return;
  }

  epyx_clear_window();
  y = 0;
  while (1) {
    if (read_help_line(fd, line, sizeof(line)) == 0 && line[0] == 0) break;
    if (line[0] == 'X') break;
    if (line[0] == 'N') {
      wait_for_space_or_escape();
      epyx_clear_window();
      y = 0;
      continue;
    }

    epyx_move_cursor(0, y++);
    epyx_write_string(line);
    epyx_clear_to_eol();
    if (y >= rogue_get8(OFF_SCREEN_HEIGHT) - 2) {
      wait_for_space_or_escape();
      epyx_clear_window();
      y = 0;
    }
  }

  close(fd);
  wait_for_space_or_escape();
  epyx_clear_window();
  draw_room();
  draw_status();
  draw_hero();
  epyx_message("Rogue C test: hjklyubn move, i inventory, q quit.");
}

static int command(ch)
int ch;
{
  if (ch == 'q' || ch == 'Q') return 0;
  if (ch == 'h' || ch == 'H' || ch == 8) try_move(-1, 0);
  else if (ch == 'l' || ch == 'L' || ch == 9) try_move(1, 0);
  else if (ch == 'k' || ch == 'K' || ch == 12) try_move(0, -1);
  else if (ch == 'j' || ch == 'J' || ch == 10 || ch == 13) try_move(0, 1);
  else if (ch == 'y' || ch == 'Y') try_move(-1, -1);
  else if (ch == 'u' || ch == 'U') try_move(1, -1);
  else if (ch == 'b' || ch == 'B') try_move(-1, 1);
  else if (ch == 'n' || ch == 'N') try_move(1, 1);
  else if (ch == 'i' || ch == 'I') {
    epyx_message("You are wielding %s and wearing %s.",
                 epyx_weapon_name(0), epyx_armor_name(0));
  } else if (ch == '?') {
    show_help_file("rogue.hlp");
  } else if (ch == '/') {
    show_help_file("rogue.chr");
  } else if (ch < 32 || ch > 126) {
    epyx_message("Unknown command code %d.", ch);
  } else {
    epyx_message("Unknown command '%c'.", ch);
  }
  return 1;
}

int rogue_game_run()
{
  int ch;

  hero_x = DUNGEON_X + DUNGEON_WIDTH / 2;
  hero_y = DUNGEON_Y + DUNGEON_HEIGHT / 2;
  turns = 0;

  epyx_screen_init();
  terminal_game_mode();
  draw_room();
  draw_status();
  draw_hero();
  epyx_message("Rogue C test: hjklyubn move, i inventory, q quit.");

  while (1) {
    ch = read_key();
    if (ch < 0) break;
    if (!command(ch)) break;
    draw_status();
    draw_hero();
  }

  terminal_restore();
  epyx_cursor_on();
  epyx_move_cursor(0, DUNGEON_Y + DUNGEON_HEIGHT + 4);
  epyx_printf("Turns: %d\n", turns);
  return 0;
}
