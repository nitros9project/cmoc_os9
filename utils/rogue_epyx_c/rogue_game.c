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
static void show_inventory_filter();

#define DUNGEON_X      2
#define DUNGEON_Y      2
#define DUNGEON_WIDTH  38
#define DUNGEON_HEIGHT 16
#define FLOOR_OBJECTS  3
#define INVENTORY_MAX  8
#define KEY_CTRL_C     3
#define KEY_CTRL_E     5
#define KEY_ESCAPE     27
#define KEY_RETURN     13
#define HUNGER_FULL    40
#define HUNGER_HUNGRY  20
#define HUNGER_WEAK    10

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

typedef struct inventory_item {
  char kind;
  char glyph;
  int quantity;
} InventoryItem;

typedef struct rogue_monster {
  char x;
  char y;
  char glyph;
  char hp;
} RogueMonster;

static int hero_x;
static int hero_y;
static int turns;
static int dungeon_level;
static int player_gold;
static int player_hp;
static int player_max_hp;
static int last_status_level;
static int last_status_gold;
static int last_status_hp;
static int last_status_max_hp;
static int inventory_count;
static int hunger_left;
static int turn_taken;
static int game_over;
static int command_repeat;
static int repeat_key;
static int repeat_left;
static int stairs_x;
static int stairs_y;
static RogueObject floor_objects[FLOOR_OBJECTS];
static InventoryItem inventory[INVENTORY_MAX];
static RogueMonster monster;
static char room_line[DUNGEON_WIDTH + 1];
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
  int y;

  epyx_reverse_off();
  epyx_cursor_on();
  y = rogue_get8(OFF_SCREEN_HEIGHT) - 2;
  if (y < 0) y = 0;
  epyx_move_cursor(0, y);
  epyx_clear_to_eol();
  terminal_restore();
  epyx_write_string("\r\n");
}

static void put_at(x, y, ch)
int x;
int y;
int ch;
{
  epyx_move_cursor(x, y);
  epyx_write_char(ch);
}

static void draw_room_line(y, left, fill, right)
int y;
int left;
int fill;
int right;
{
  int x;

  room_line[0] = (char) left;
  for (x = 1; x < DUNGEON_WIDTH - 1; x++) room_line[x] = (char) fill;
  room_line[DUNGEON_WIDTH - 1] = (char) right;
  room_line[DUNGEON_WIDTH] = 0;

  epyx_move_cursor(DUNGEON_X, y);
  epyx_write_string(room_line);
}

static void draw_room()
{
  int y;

  draw_room_line(DUNGEON_Y, '+', '-', '+');
  for (y = 1; y < DUNGEON_HEIGHT - 1; y++)
    draw_room_line(DUNGEON_Y + y, '|', '.', '|');
  draw_room_line(DUNGEON_Y + DUNGEON_HEIGHT - 1, '+', '-', '+');

  put_at(DUNGEON_X + 12, DUNGEON_Y, '+');
  put_at(DUNGEON_X + 12, DUNGEON_Y - 1, '#');
  put_at(DUNGEON_X + 24, DUNGEON_Y + DUNGEON_HEIGHT - 1, '+');
  put_at(DUNGEON_X + 24, DUNGEON_Y + DUNGEON_HEIGHT, '#');
}

static void invalidate_status()
{
  last_status_level = -1;
  last_status_gold = -1;
  last_status_hp = -1;
  last_status_max_hp = -1;
}

static void draw_status()
{
  int y;
  int redraw_all;

  /*
   * Mirrors the important behavior of rogue.asm:L6AA2: cache each status
   * field and only rewrite fields whose values changed.
   */
  y = DUNGEON_Y + DUNGEON_HEIGHT + 2;
  redraw_all = last_status_level < 0;
  epyx_reverse_on();

  if (redraw_all || dungeon_level != last_status_level) {
    epyx_move_cursor(1, y);
    epyx_printf("Level:%-2d", dungeon_level);
    last_status_level = dungeon_level;
  }

  if (redraw_all || player_gold != last_status_gold) {
    epyx_move_cursor(11, y);
    epyx_printf("Gold:%-5d", player_gold);
    last_status_gold = player_gold;
  }

  if (redraw_all || player_hp != last_status_hp ||
      player_max_hp != last_status_max_hp) {
    epyx_move_cursor(23, y);
    epyx_printf("Hp:%3d(%3d)", player_hp, player_max_hp);
    last_status_hp = player_hp;
    last_status_max_hp = player_max_hp;
  }

  if (redraw_all) {
    epyx_move_cursor(35, y);
    epyx_printf("Ac:%d  Str:%d  Exp:%d/%d ", 10, 16, 1, 0);
    epyx_clear_to_eol();
  }

  epyx_reverse_off();
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

static void draw_monster()
{
  if (monster.hp > 0) put_at(monster.x, monster.y, monster.glyph);
}

static void draw_hero()
{
  put_at(hero_x, hero_y, '@');
  rogue_put16(OFF_HERO_POS, hero_y * 256 + hero_x);
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

static int floor_glyph_at(x, y)
int x;
int y;
{
  RogueObject *obj;

  obj = object_at(x, y);
  if (obj) return obj->glyph;
  if (x == stairs_x && y == stairs_y) return '>';
  return '.';
}

static RogueObject *free_floor_object()
{
  int i;

  for (i = 0; i < FLOOR_OBJECTS; i++) {
    if (floor_objects[i].kind == OBJ_NONE) return &floor_objects[i];
  }
  return 0;
}

static void erase_hero()
{
  put_at(hero_x, hero_y, floor_glyph_at(hero_x, hero_y));
}

static void erase_monster()
{
  put_at(monster.x, monster.y, floor_glyph_at(monster.x, monster.y));
}

static int monster_at(x, y)
int x;
int y;
{
  return monster.hp > 0 && monster.x == x && monster.y == y;
}

static int adjacent_to_hero(x, y)
int x;
int y;
{
  return x >= hero_x - 1 && x <= hero_x + 1 &&
         y >= hero_y - 1 && y <= hero_y + 1 &&
         (x != hero_x || y != hero_y);
}

static void monster_hit_player()
{
  player_hp--;
  draw_status();
  if (player_hp <= 0) {
    game_over = 1;
    epyx_message("You died.");
  } else {
    epyx_message("It hits.");
  }
}

static const char *object_name(kind)
int kind;
{
  if (kind == OBJ_FOOD) return rogue_string_at(OFF_SOME_FOOD);
  return "unknown object";
}

static InventoryItem *inventory_item(kind)
int kind;
{
  int i;

  for (i = 0; i < inventory_count; i++) {
    if (inventory[i].kind == kind) return &inventory[i];
  }
  return 0;
}

static InventoryItem *add_inventory(kind, glyph, quantity)
int kind;
int glyph;
int quantity;
{
  InventoryItem *item;

  item = inventory_item(kind);
  if (item) {
    item->quantity += quantity;
    return item;
  }

  if (inventory_count >= INVENTORY_MAX) return 0;
  item = &inventory[inventory_count++];
  item->kind = (char) kind;
  item->glyph = (char) glyph;
  item->quantity = quantity;
  return item;
}

static int remove_inventory(item, quantity)
InventoryItem *item;
int quantity;
{
  int index;

  if (!item || item->quantity < quantity) return 0;
  item->quantity -= quantity;
  if (item->quantity > 0) return 1;

  index = item - inventory;
  inventory_count--;
  while (index < inventory_count) {
    inventory[index].kind = inventory[index + 1].kind;
    inventory[index].glyph = inventory[index + 1].glyph;
    inventory[index].quantity = inventory[index + 1].quantity;
    index++;
  }
  return 1;
}

static void pickup_object(obj)
RogueObject *obj;
{
  if (obj->kind == OBJ_GOLD) {
    player_gold += obj->quantity;
    rogue_put16(OFF_PLAYER_GOLD, player_gold);
    epyx_message(rogue_string_at(OFF_FOUND_GOLD_MESSAGE), obj->quantity);
  } else if (obj->kind == OBJ_FOOD) {
    add_inventory(obj->kind, obj->glyph, obj->quantity);
    epyx_message(rogue_string_at(OFF_FOUND_OBJECT_MESSAGE),
                 rogue_string_at(OFF_SOME_FOOD));
  }

  obj->kind = OBJ_NONE;
}

static void spend_turn()
{
  turns++;
  turn_taken = 1;
  hunger_left--;
  if (hunger_left == HUNGER_HUNGRY) epyx_message("You are starting to feel hungry.");
  else if (hunger_left == HUNGER_WEAK) epyx_message("You are starting to feel weak.");
  else if (hunger_left < 1) {
    hunger_left = 1;
    epyx_message("You faint from lack of food.");
  }
}

static void try_move(dx, dy)
int dx;
int dy;
{
  int nx;
  int ny;

  nx = hero_x + dx;
  ny = hero_y + dy;
  if (monster_at(nx, ny)) {
    monster.hp--;
    spend_turn();
    if (monster.hp <= 0) {
      erase_monster();
      epyx_message("Defeated.");
    } else {
      epyx_message("You hit.");
    }
    return;
  }

  if (!is_walkable(nx, ny)) {
    epyx_message("You bump into a wall.");
    return;
  }

  erase_hero();
  rogue_put16(OFF_OLD_HERO_POS, hero_y * 256 + hero_x);
  hero_x = nx;
  hero_y = ny;
  spend_turn();
  draw_hero();
}

static void rest_turn()
{
  spend_turn();
}

static void monster_turn()
{
  int dx;
  int dy;
  int nx;
  int ny;

  if (monster.hp <= 0) return;
  if (adjacent_to_hero(monster.x, monster.y)) {
    monster_hit_player();
    return;
  }

  dx = 0;
  dy = 0;
  if (monster.x < hero_x) dx = 1;
  else if (monster.x > hero_x) dx = -1;
  if (monster.y < hero_y) dy = 1;
  else if (monster.y > hero_y) dy = -1;

  nx = monster.x + dx;
  ny = monster.y + dy;
  if (!is_walkable(nx, ny) || object_at(nx, ny)) return;
  if (nx == hero_x && ny == hero_y) {
    monster_hit_player();
    return;
  }

  erase_monster();
  monster.x = (char) nx;
  monster.y = (char) ny;
  draw_monster();
  draw_hero();
}

static void pickup_here()
{
  RogueObject *obj;

  obj = object_at(hero_x, hero_y);
  if (!obj) {
    epyx_message(rogue_string_at(OFF_NO_APPROPRIATE_OBJECT));
    return;
  }

  pickup_object(obj);
  draw_status();
  draw_hero();
}

static int read_key()
{
  char ch;

  if (read(0, &ch, 1) != 1) return -1;
  return ch;
}

static InventoryItem *choose_inventory_item(prompt, kind)
const char *prompt;
int kind;
{
  int ch;
  int index;
  int i;

  if (inventory_count == 0) {
    epyx_message(rogue_string_at(OFF_NO_APPROPRIATE_OBJECT));
    return 0;
  }

  if (kind) {
    for (i = 0; i < inventory_count; i++) {
      if (inventory[i].kind == kind) break;
    }
    if (i >= inventory_count) {
      epyx_message(rogue_string_at(OFF_NO_APPROPRIATE_OBJECT));
      return 0;
    }
  }

  while (1) {
    epyx_message(prompt);
    ch = read_key();
    if (ch == KEY_ESCAPE || ch == KEY_CTRL_E) {
      epyx_message("Cancelled.");
      return 0;
    }
    if (ch == '*' || ch == ':') {
      show_inventory_filter(kind);
      continue;
    }
    if (ch >= 'A' && ch <= 'Z') ch += 'a' - 'A';
    index = ch - 'a';
    if (index < 0 || index >= inventory_count) {
      epyx_message(rogue_string_at(OFF_NO_APPROPRIATE_OBJECT));
      return 0;
    }
    if (kind && inventory[index].kind != kind) {
      epyx_message(rogue_string_at(OFF_NO_APPROPRIATE_OBJECT));
      return 0;
    }
    return &inventory[index];
  }
}

static void eat_item()
{
  InventoryItem *item;

  item = choose_inventory_item("Eat what?", OBJ_FOOD);
  if (!item) return;

  remove_inventory(item, 1);
  hunger_left = HUNGER_FULL;
  epyx_message(rogue_string_at(OFF_EAT_GOOD_FOOD));
}

static void drop_item()
{
  InventoryItem *item;
  RogueObject *obj;

  if (object_at(hero_x, hero_y)) {
    epyx_message(rogue_string_at(OFF_NO_APPROPRIATE_OBJECT));
    return;
  }

  item = choose_inventory_item("Drop what?", 0);
  if (!item) return;

  obj = free_floor_object();
  if (!obj) {
    epyx_message(rogue_string_at(OFF_NO_APPROPRIATE_OBJECT));
    return;
  }

  obj->kind = item->kind;
  obj->glyph = item->glyph;
  obj->x = (char) hero_x;
  obj->y = (char) hero_y;
  obj->quantity = 1;
  remove_inventory(item, 1);
  spend_turn();
  draw_hero();
  epyx_message("Dropped.");
}

static int wait_for_space_or_escape_at(y)
int y;
{
  int ch;

  epyx_move_cursor(0, y);
  epyx_reverse_on();
  epyx_write_string("SPACE to continue ESC to quit");
  epyx_reverse_off();
  epyx_clear_to_eol();
  while (1) {
    ch = read_key();
    if (ch == KEY_ESCAPE || ch == KEY_CTRL_E) return 0;
    if (ch == ' ') return 1;
  }
}

static int wait_for_space_or_escape_after(y)
int y;
{
  int prompt_y;
  int max_y;

  max_y = rogue_get8(OFF_SCREEN_HEIGHT) - 2;
  prompt_y = y + 1;
  if (prompt_y > max_y) prompt_y = max_y;
  if (prompt_y < 0) prompt_y = 0;
  return wait_for_space_or_escape_at(prompt_y);
}

static int confirm_quit()
{
  int ch;

  epyx_move_cursor(0, 0);
  epyx_clear_to_eol();
  if (rogue_get8(OFF_SCREEN_WIDTH) < 45)
    epyx_write_string("Quit (Yes/No)?");
  else
    epyx_write_string("Do you wish to end your quest now (Yes/No) ?");

  ch = read_key();
  if (ch == 'y' || ch == 'Y') {
    epyx_clear_window();
    epyx_move_cursor(0, 0);
    epyx_printf("You quit with %d gold pieces\r\n", player_gold);
    return 0;
  }

  epyx_move_cursor(0, 0);
  epyx_clear_to_eol();
  draw_status();
  draw_hero();
  return 1;
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
      if (!wait_for_space_or_escape_after(y)) {
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
      if (!wait_for_space_or_escape_after(y)) {
        aborted = 1;
        break;
      }
      epyx_clear_window();
      y = 0;
    }
  }

  close(fd);
  if (!aborted) wait_for_space_or_escape_after(y);
  redraw_dungeon();
}

static void show_inventory_filter(kind)
int kind;
{
  int i;
  int shown;
  InventoryItem *item;

  if (inventory_count == 0) {
    epyx_message("You are empty handed.");
    return;
  }

  epyx_clear_window();
  shown = 0;
  for (i = 0; i < inventory_count; i++) {
    item = &inventory[i];
    if (kind && item->kind != kind) continue;
    epyx_move_cursor(0, shown);
    epyx_printf("%c) %s", 'a' + i, object_name(item->kind));
    if (item->quantity > 1) epyx_printf(" [%d]", item->quantity);
    epyx_clear_to_eol();
    shown++;
  }

  if (shown == 0) {
    redraw_dungeon();
    epyx_message(rogue_string_at(OFF_NO_APPROPRIATE_OBJECT));
    return;
  }

  wait_for_space_or_escape_at(shown + 2);
  redraw_dungeon();
}

static void show_inventory()
{
  /*
   * Simplified translation of rogue.asm:L7037.  The original walks the
   * backpack list, filters by object kind, formats "%c) %s", and reports
   * either empty-handed or no-appropriate-object when nothing is displayed.
   */
  show_inventory_filter(0);
}

static void redraw_dungeon()
{
  epyx_clear_window();
  draw_room();
  draw_stairs();
  draw_floor_objects();
  draw_monster();
  invalidate_status();
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

static int movement_delta(ch)
int ch;
{
  if (ch == 'h' || ch == 'H' || ch == 8) return 1;
  if (ch == 'l' || ch == 'L' || ch == 9) return 2;
  if (ch == 'k' || ch == 'K' || ch == 12) return 3;
  if (ch == 'j' || ch == 'J' || ch == 10 || ch == 13) return 4;
  if (ch == 'y' || ch == 'Y') return 5;
  if (ch == 'u' || ch == 'U') return 6;
  if (ch == 'b' || ch == 'B') return 7;
  if (ch == 'n' || ch == 'N') return 8;
  return 0;
}

static int handle_repeat_prefix(ch)
int ch;
{
  if (ch >= '0' && ch <= '9') {
    command_repeat = command_repeat * 10 + ch - '0';
    if (command_repeat > 99) command_repeat = 99;
    return 1;
  }

  if ((movement_delta(ch) || ch == '.') && command_repeat > 1) {
    repeat_key = ch;
    repeat_left = command_repeat - 1;
  }
  command_repeat = 0;
  return 0;
}

static int command(ch)
int ch;
{
  int move;

  /* rogue.asm:L4238-L43D1 numeric repeat-prefix subset. */
  if (handle_repeat_prefix(ch)) return 1;

  /* rogue.asm:L4400 movement command cluster. */
  move = movement_delta(ch);
  if (move == 1) try_move(-1, 0);
  else if (move == 2) try_move(1, 0);
  else if (move == 3) try_move(0, -1);
  else if (move == 4) try_move(0, 1);
  else if (move == 5) try_move(-1, -1);
  else if (move == 6) try_move(1, -1);
  else if (move == 7) try_move(-1, 1);
  else if (move == 8) try_move(1, 1);

  /* rogue.asm:L43AD legal turn commands that are not movement. */
  else if (ch == '.') rest_turn();

  /* rogue.asm:L448A-L44C6 inventory and item command cluster. */
  else if (ch == ',') pickup_here();
  else if (ch == 'd' || ch == 'D') drop_item();
  else if (ch == 'e' || ch == 'E') eat_item();
  else if (ch == 'i' || ch == 'I') show_inventory();

  /* rogue.asm:L4505-L451F stairs and symbol/help commands. */
  else if (ch == '>') change_level(1);
  else if (ch == '<') change_level(-1);
  else if (ch == '?') show_help_file("rogue.hlp");
  else if (ch == '/') show_help_file("rogue.chr");

  /* rogue.asm:L447D quit command. */
  else if (ch == 'q' || ch == 'Q') return confirm_quit();
  else if (ch == KEY_ESCAPE || ch == KEY_CTRL_E) {
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
  player_hp = 12;
  player_max_hp = 12;
  invalidate_status();
  inventory_count = 0;
  hunger_left = HUNGER_FULL;
  turn_taken = 0;
  game_over = 0;
  command_repeat = 0;
  repeat_key = 0;
  repeat_left = 0;
  stairs_x = DUNGEON_X + 24;
  stairs_y = DUNGEON_Y + DUNGEON_HEIGHT - 2;
  monster.x = DUNGEON_X + 30;
  monster.y = DUNGEON_Y + 4;
  monster.glyph = 'K';
  monster.hp = 3;
  rogue_put8(OFF_DUNGEON_LEVEL, dungeon_level);
  rogue_put16(OFF_PLAYER_GOLD, player_gold);
  add_inventory(OBJ_FOOD, '%', 1);
  add_floor_object(0, OBJ_GOLD, '$', DUNGEON_X + 8, DUNGEON_Y + 5, 37);
  add_floor_object(1, OBJ_FOOD, '%', DUNGEON_X + 27, DUNGEON_Y + 9, 1);

  rogue_ignore_signals();
  epyx_screen_init();
  terminal_game_mode();
  redraw_dungeon();

  while (1) {
    if (repeat_left > 0) {
      ch = repeat_key;
      repeat_left--;
    } else {
      ch = read_key();
      if (ch < 0) break;
    }
    if (!command(ch)) break;
    if (!turn_taken) repeat_left = 0;
    if (turn_taken) {
      turn_taken = 0;
      monster_turn();
    }
    if (game_over) break;
  }

  terminal_finish();
  return 0;
}
