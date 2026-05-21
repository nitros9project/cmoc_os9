#include <os.h>
#include <os9abi.h>
#include <fcntl.h>

#include "epyx_arena.h"
#include "epyx_format.h"
#include "epyx_screen.h"
#include "epyx_tables.h"
#include "rogue_game.h"

int read(int path, void *buffer, int count);
int readln(int path, void *buffer, int count);
int rogue_ignore_signals();

static void redraw_dungeon();

#define DUNGEON_X      2
#define DUNGEON_Y      2
#define DUNGEON_WIDTH  38
#define DUNGEON_HEIGHT 16
#define FLOOR_OBJECTS  2
#define KEY_CTRL_C     3
#define KEY_CTRL_E     5
#define KEY_ESCAPE     27
#define KEY_RETURN     13

#define OBJ_NONE       0
#define OBJ_FOOD       1
#define OBJ_GOLD       2

typedef struct rogue_object {
  char kind;
  char glyph;
  char x;
  char y;
  int quantity;
} RogueObject;

static int hero_x;
static int hero_y;
static int turns;
static int dungeon_level;
static int player_gold;
static int food_count;
static int stairs_x;
static int stairs_y;
static RogueObject floor_objects[FLOOR_OBJECTS];
static struct sgbuf saved_stdin_opts;
static struct sgbuf game_stdin_opts;
static int have_saved_stdin_opts;

static void terminal_game_mode()
{
  if (have_saved_stdin_opts) return;
  if (_os_gs_popt(0, &saved_stdin_opts) != 0) return;
  if (_os_gs_popt(0, &game_stdin_opts) != 0) return;

  game_stdin_opts.sg_echo = 0;
  if (_os_ss_popt(0, &game_stdin_opts) != 0) return;
  have_saved_stdin_opts = 1;
}

static void terminal_restore()
{
  if (!have_saved_stdin_opts) return;
  _os_ss_popt(0, &saved_stdin_opts);
  have_saved_stdin_opts = 0;
}

static void terminal_finish()
{
  epyx_reverse_off();
  epyx_cursor_on();
  terminal_restore();
  epyx_write_string("\r\n");
  epyx_printf("Turns: %d\r\n", turns);
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
              dungeon_level, player_gold, 12, 12, 10, 16, 1, 0);
  epyx_reverse_off();
  epyx_clear_to_eol();
}

static void draw_stairs()
{
  put_at(stairs_x, stairs_y, '>');
}

static void draw_floor_objects()
{
  int i;

  for (i = 0; i < FLOOR_OBJECTS; i++) {
    if (floor_objects[i].kind != OBJ_NONE)
      put_at(floor_objects[i].x, floor_objects[i].y, floor_objects[i].glyph);
  }
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

static RogueObject *object_at(x, y)
int x;
int y;
{
  int i;

  for (i = 0; i < FLOOR_OBJECTS; i++) {
    if (floor_objects[i].kind != OBJ_NONE &&
        floor_objects[i].x == x && floor_objects[i].y == y)
      return &floor_objects[i];
  }
  return 0;
}

static void pickup_object(obj)
RogueObject *obj;
{
  if (obj->kind == OBJ_GOLD) {
    player_gold += obj->quantity;
    rogue_put16(OFF_PLAYER_GOLD, player_gold);
    epyx_message(rogue_string_at(OFF_FOUND_GOLD_MESSAGE), obj->quantity);
  } else if (obj->kind == OBJ_FOOD) {
    food_count += obj->quantity;
    epyx_message(rogue_string_at(OFF_FOUND_OBJECT_MESSAGE),
                 rogue_string_at(OFF_SOME_FOOD));
  }

  obj->kind = OBJ_NONE;
}

static void try_move(dx, dy)
int dx;
int dy;
{
  int nx;
  int ny;
  RogueObject *obj;

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

  obj = object_at(hero_x, hero_y);
  if (obj) {
    pickup_object(obj);
  } else {
    epyx_message("Moved to %d,%d.  q quits.", hero_x, hero_y);
  }
}

static int read_key()
{
  char ch;

  if (read(0, &ch, 1) != 1) return -1;
  return ch;
}

static int wait_for_space_or_escape()
{
  int ch;

  epyx_message("SPACE to continue ESC to quit");
  while (1) {
    ch = read_key();
    if (ch == KEY_ESCAPE || ch == KEY_CTRL_E) return 0;
    if (ch == ' ') return 1;
  }
}

static int read_help_line(fd, line, max)
int fd;
char *line;
int max;
{
  int len;
  int i;

  len = readln(fd, line, max - 1);
  if (len <= 0) {
    line[0] = 0;
    return 0;
  }

  for (i = 0; i < len && i < max - 1; i++) {
    if (line[i] == '\r' || line[i] == '\n') break;
  }
  line[i] = 0;
  return i;
}

static void show_help_file(path)
const char *path;
{
  int fd;
  int y;
  int aborted;
  char line[40];

  fd = open(path, 1);
  if (fd < 0) {
    epyx_message("Can't open \"%s\".", path);
    return;
  }

  epyx_clear_window();
  y = 0;
  aborted = 0;
  while (1) {
    if (read_help_line(fd, line, sizeof(line)) == 0 && line[0] == 0) break;
    if (line[0] == 'X') break;
    if (line[0] == 'N') {
      if (!wait_for_space_or_escape()) {
        aborted = 1;
        break;
      }
      epyx_clear_window();
      y = 0;
      continue;
    }

    epyx_move_cursor(0, y++);
    epyx_write_string(line);
    epyx_clear_to_eol();
    if (y >= rogue_get8(OFF_SCREEN_HEIGHT) - 2) {
      if (!wait_for_space_or_escape()) {
        aborted = 1;
        break;
      }
      epyx_clear_window();
      y = 0;
    }
  }

  close(fd);
  if (!aborted) wait_for_space_or_escape();
  redraw_dungeon();
  epyx_message("Rogue C test: hjklyubn move, i inventory, q quit.");
}

static void eat_food()
{
  if (food_count <= 0) {
    epyx_message(rogue_string_at(OFF_NO_APPROPRIATE_OBJECT));
    return;
  }

  food_count--;
  epyx_message(rogue_string_at(OFF_EAT_GOOD_FOOD));
}

static void redraw_dungeon()
{
  epyx_clear_window();
  draw_room();
  draw_stairs();
  draw_floor_objects();
  draw_status();
  draw_hero();
}

static void change_level(delta)
int delta;
{
  if (delta > 0 && (hero_x != stairs_x || hero_y != stairs_y)) {
    epyx_message(rogue_string_at(OFF_NO_WAY_DOWN));
    return;
  }

  if (delta < 0 && dungeon_level == 1) {
    epyx_message(rogue_string_at(OFF_NO_WAY_UP));
    return;
  }

  dungeon_level += delta;
  rogue_put8(OFF_DUNGEON_LEVEL, dungeon_level);
  hero_x = DUNGEON_X + DUNGEON_WIDTH / 2;
  hero_y = DUNGEON_Y + DUNGEON_HEIGHT / 2;
  redraw_dungeon();
  epyx_message("You are now on level %d.", dungeon_level);
}

static int command(ch)
int ch;
{
  if (ch == 'q' || ch == 'Q') {
    return 0;
  }
  if (ch == 'h' || ch == 'H' || ch == 8) try_move(-1, 0);
  else if (ch == 'l' || ch == 'L' || ch == 9) try_move(1, 0);
  else if (ch == 'k' || ch == 'K' || ch == 12) try_move(0, -1);
  else if (ch == 'j' || ch == 'J' || ch == 10 || ch == 13) try_move(0, 1);
  else if (ch == 'y' || ch == 'Y') try_move(-1, -1);
  else if (ch == 'u' || ch == 'U') try_move(1, -1);
  else if (ch == 'b' || ch == 'B') try_move(-1, 1);
  else if (ch == 'n' || ch == 'N') try_move(1, 1);
  else if (ch == 'e' || ch == 'E') eat_food();
  else if (ch == '>') change_level(1);
  else if (ch == '<') change_level(-1);
  else if (ch == 'i' || ch == 'I') {
    epyx_message("Food:%d  Weapon:%s  Armor:%s",
                 food_count, epyx_weapon_name(0), epyx_armor_name(0));
  } else if (ch == '?') {
    show_help_file("rogue.hlp");
  } else if (ch == '/') {
    show_help_file("rogue.chr");
  } else if (ch == KEY_ESCAPE || ch == KEY_CTRL_E) {
    epyx_message("Cancelled.");
  } else if (ch < 32 || ch > 126) {
    epyx_message("Unknown command code %d.", ch);
  } else {
    epyx_message("Unknown command '%c'.", ch);
  }
  return 1;
}

static void add_floor_object(slot, kind, glyph, x, y, quantity)
int slot;
int kind;
int glyph;
int x;
int y;
int quantity;
{
  floor_objects[slot].kind = (char) kind;
  floor_objects[slot].glyph = (char) glyph;
  floor_objects[slot].x = (char) x;
  floor_objects[slot].y = (char) y;
  floor_objects[slot].quantity = quantity;
}

int rogue_game_run()
{
  int ch;

  hero_x = DUNGEON_X + DUNGEON_WIDTH / 2;
  hero_y = DUNGEON_Y + DUNGEON_HEIGHT / 2;
  turns = 0;
  dungeon_level = 1;
  player_gold = 0;
  food_count = 1;
  stairs_x = DUNGEON_X + 24;
  stairs_y = DUNGEON_Y + DUNGEON_HEIGHT - 2;
  rogue_put8(OFF_DUNGEON_LEVEL, dungeon_level);
  rogue_put16(OFF_PLAYER_GOLD, player_gold);
  add_floor_object(0, OBJ_GOLD, '$', DUNGEON_X + 8, DUNGEON_Y + 5, 37);
  add_floor_object(1, OBJ_FOOD, '%', DUNGEON_X + 27, DUNGEON_Y + 9, 1);

  rogue_ignore_signals();
  epyx_screen_init();
  terminal_game_mode();
  redraw_dungeon();
  epyx_message("Rogue C test: hjklyubn move, e eat, i inventory, q quit.");

  while (1) {
    ch = read_key();
    if (ch < 0) break;
    if (!command(ch)) break;
    draw_status();
    draw_hero();
  }

  terminal_finish();
  return 0;
}
