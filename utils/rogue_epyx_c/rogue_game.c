#include <os.h>
#include <os9abi.h>
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>

#include "epyx_arena.h"
#include "epyx_format.h"
#include "epyx_screen.h"
#include "epyx_tables.h"
#include "rogue_game.h"

int read(int path, void *buffer, int count);
int rogue_ignore_signals();

static void redraw_dungeon();
static void show_inventory();
static int read_key();
static int starts_with_vowel(const char *s);

#define DUNGEON_MIN_WIDTH  28
#define DUNGEON_MAX_WIDTH  78
#define DUNGEON_MIN_HEIGHT 10
#define DUNGEON_MAX_HEIGHT 18
#define FLOOR_OBJECTS  6
#define INVENTORY_MAX  8
#define HELP_TEXT_MAX  1024
#define CHR_TEXT_MAX   192
#define KEY_CTRL_C     3
#define KEY_CTRL_E     5
#define KEY_ESCAPE     27
#define KEY_RETURN     13

#define OBJ_NONE       0
#define OBJ_FOOD       1
#define OBJ_GOLD       2
#define OBJ_POTION     3
#define OBJ_SCROLL     4
#define OBJ_WEAPON     5
#define OBJ_ARMOR      6

#define POTION_HEALING 5
#define SCROLL_MAGIC_MAPPING 1

typedef struct rogue_object {
  char kind;
  char glyph;
  char subtype;
  char x;
  char y;
  char quantity;
} RogueObject;

typedef struct rogue_monster {
  char x;
  char y;
  char hp;
} RogueMonster;

typedef struct inventory_item {
  char kind;
  char glyph;
  char subtype;
  char quantity;
} InventoryItem;

static int hero_x;
static int hero_y;
static char dungeon_level;
static int player_gold;
static char player_hp;
static char wielded_weapon;
static char worn_armor;
static char armor_guard;
static char turn_taken;
static char inventory_count;
static char dungeon_x;
static char dungeon_y;
static char dungeon_width;
static char dungeon_height;
static char status_y;
static char top_door_x;
static char bottom_door_x;
static char stair_x;
static char stair_y;
static char status_invalid;
static char last_status_level;
static char last_status_hp;
static int last_status_gold;
static char last_status_armor;
static RogueObject floor_objects[FLOOR_OBJECTS];
static InventoryItem inventory[INVENTORY_MAX];
static RogueMonster monster;
static char room_line[DUNGEON_MAX_WIDTH + 1];
static char object_name_buf[48];
static char death_cause_buf[32];
static char potion_color_index[POTION_COUNT];
static struct sgbuf saved_stdin_opts;
static struct sgbuf game_stdin_opts;
static int have_saved_stdin_opts;
static char rogue_chr_text[CHR_TEXT_MAX];
static char rogue_help_text[HELP_TEXT_MAX];

static const char *potion_colors[] = {
  "amber", "aquamarine", "black", "blue", "brown",
  "clear", "crimson", "cyan", "gold", "green",
  "grey", "magenta", "orange", "pink", "plaid",
  "purple", "red", "silver", "tan", "tangerine",
  "turquoise", "vermilion", "violet", "white", "yellow"
};

static void seed_random()
{
  _os_time t;
  unsigned seed;

  seed = 1;
  if (_os_getime(&t) == 0) {
    seed = t.seconds;
    seed = seed * 60 + t.minutes;
    seed = seed * 24 + t.hours;
    seed = seed * 31 + t.day;
    seed = seed * 12 + t.month;
    seed += t.year;
  }
  srand(seed);
}

static int random_range(limit)
int limit;
{
  if (limit <= 1) return 0;
  return rand() % limit;
}

static int arena_string_len(off)
unsigned int off;
{
  int len;

  len = 0;
  while (rogue_get8(off + len)) len++;
  return len;
}

static int arena_random_char(off)
unsigned int off;
{
  return rogue_get8(off + random_range(arena_string_len(off)));
}

static void init_scroll_title(index)
int index;
{
  unsigned int off;
  int pos;
  int words;
  int syllables;

  off = OFF_RANDOM_SCROLL_NAMES + index * SCROLL_TITLE_SIZE;
  pos = 0;
  words = 2 + random_range(5);

  while (words-- > 0 && pos < SCROLL_TITLE_SIZE - 1) {
    syllables = 1 + random_range(3);
    while (syllables-- > 0 && pos < SCROLL_TITLE_SIZE - 2) {
      if (random_range(3) != 0)
        rogue_put8(off + pos++, arena_random_char(OFF_SCROLL_CONSONANTS));
      rogue_put8(off + pos++, arena_random_char(OFF_SCROLL_VOWELS));
    }
    if (words > 0 && pos < SCROLL_TITLE_SIZE - 1)
      rogue_put8(off + pos++, ' ');
  }
  rogue_put8(off + pos, 0);
}

static void init_object_names()
{
  char used[25];
  int i;
  int color;

  for (i = 0; i < 25; i++) used[i] = 0;
  for (i = 0; i < POTION_COUNT; i++) {
    do {
      color = random_range(25);
    } while (used[color]);
    used[color] = 1;
    potion_color_index[i] = (char) color;
    rogue_put8(OFF_POTION_KNOWN_FLAGS + i, 0);
  }

  for (i = 0; i < SCROLL_COUNT; i++) {
    rogue_put8(OFF_SCROLL_KNOWN_FLAGS + i, 0);
    init_scroll_title(i);
  }
}

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

static int string_width(text)
const char *text;
{
  int len;

  len = 0;
  while (text[len]) len++;
  return len;
}

static void centered_text(y, text)
int y;
const char *text;
{
  int x;

  x = (rogue_get8(OFF_SCREEN_WIDTH) - string_width(text)) / 2;
  if (x < 0) x = 0;
  epyx_move_cursor(x, y);
  epyx_write_string(text);
}

static void centered_format(y, fmt, a, b)
int y;
const char *fmt;
const char *a;
const char *b;
{
  epyx_format(object_name_buf, sizeof(object_name_buf), fmt, a, b);
  centered_text(y, object_name_buf);
}

static void short_delay()
{
  int ticks;

  ticks = 2;
  _os9_sleep(&ticks);
}

static void show_title_screen()
{
  int max_x;
  int max_y;
  int half_y;
  int step_x;
  int y;
  int left_x;
  int right_x;

  epyx_clear_window();
  max_x = rogue_get8(OFF_SCREEN_MAX_X);
  max_y = rogue_get8(OFF_SCREEN_MAX_Y);
  half_y = max_y / 2;
  step_x = 2;
  if (max_y) step_x = rogue_get8(OFF_SCREEN_WIDTH) / max_y;
  if (step_x < 1) step_x = 1;

  left_x = 1;
  right_x = max_x - 1;
  for (y = 0; y < half_y; y++) {
    put_at(left_x, y, '*');
    put_at(right_x, y, '*');
    put_at(left_x, max_y - y, '*');
    put_at(right_x, max_y - y, '*');
    short_delay();
    left_x += step_x;
    right_x -= step_x;
  }

  epyx_clear_window();
  centered_text(half_y, rogue_string_at(OFF_TITLE_ROGUE));
  if (rogue_get8(OFF_SCREEN_WIDTH) >= 26)
    centered_text(half_y + 5, rogue_string_at(OFF_TITLE_COPYRIGHT));
  centered_text(half_y + 7, rogue_string_at(OFF_TITLE_PRESS_SPACE));
  while (read_key() != ' ') ;
  epyx_clear_window();
}

static const char *monster_death_cause()
{
  char *name;

  name = rogue_string_at(rogue_get16(OFF_MONSTER_TABLE +
                                    ('K' - 'A') * MONSTER_ENTRY_SIZE));
  epyx_format(death_cause_buf, sizeof(death_cause_buf),
              starts_with_vowel(name) ? "an %s" : "a %s", name);
  return death_cause_buf;
}

static void show_death_screen()
{
  int y;

  epyx_clear_window();
  y = rogue_get8(OFF_SCREEN_HEIGHT) - 14;
  if (y < 0) y = 0;

  centered_text(y + 1, rogue_string_at(OFF_DEATH_TOP));
  centered_text(y + 2, rogue_string_at(OFF_DEATH_SHOULDER));
  centered_text(y + 3, rogue_string_at(OFF_DEATH_RIP));
  centered_text(y + 4, rogue_string_at(OFF_DEATH_BLANK1));
  centered_text(y + 5, rogue_string_at(OFF_DEATH_BLANK2));
  centered_text(y + 6, rogue_string_at(OFF_DEATH_BLANK3));
  centered_format(y + 9, rogue_string_at(OFF_DEATH_EPITAPH),
                  rogue_string_at(OFF_DEFAULT_PLAYER_NAME),
                  monster_death_cause());
  epyx_format(object_name_buf, sizeof(object_name_buf),
              rogue_string_at(OFF_DEATH_TOTAL_WORTH), player_gold);
  centered_text(y + 11, object_name_buf);
  centered_text(y + 13, rogue_string_at(OFF_TITLE_PRESS_SPACE));
  while (read_key() != ' ') ;
  epyx_clear_window();
}

static int room_col(n)
int n;
{
  return dungeon_x + n * (dungeon_width - 1) / 37;
}

static void init_layout()
{
  int screen_width;
  int screen_height;

  screen_width = rogue_get8(OFF_SCREEN_WIDTH);
  screen_height = rogue_get8(OFF_SCREEN_HEIGHT);

  dungeon_x = 1;
  dungeon_y = screen_height >= 20 ? 2 : 1;
  status_y = (char) (screen_height > 2 ? screen_height - 2 : 0);

  dungeon_width = (char) (screen_width - dungeon_x - 1);
  if (dungeon_width > DUNGEON_MAX_WIDTH) dungeon_width = DUNGEON_MAX_WIDTH;
  if (dungeon_width < DUNGEON_MIN_WIDTH) dungeon_width = DUNGEON_MIN_WIDTH;

  dungeon_height = status_y - dungeon_y - 2;
  if (dungeon_height > DUNGEON_MAX_HEIGHT) dungeon_height = DUNGEON_MAX_HEIGHT;
  if (dungeon_height < DUNGEON_MIN_HEIGHT) dungeon_height = DUNGEON_MIN_HEIGHT;

  top_door_x = (char) room_col(12);
  bottom_door_x = (char) room_col(24);
  stair_x = bottom_door_x;
  stair_y = dungeon_y + dungeon_height - 2;
}

static void set_floor_object(slot, kind, glyph, subtype, x, y, quantity)
int slot;
int kind;
int glyph;
int subtype;
int x;
int y;
int quantity;
{
  floor_objects[slot].kind = (char) kind;
  floor_objects[slot].glyph = (char) glyph;
  floor_objects[slot].subtype = (char) subtype;
  floor_objects[slot].x = (char) x;
  floor_objects[slot].y = (char) y;
  floor_objects[slot].quantity = (char) quantity;
}

static void draw_room_line(y, left, fill, right)
int y;
int left;
int fill;
int right;
{
  int x;

  room_line[0] = (char) left;
  for (x = 1; x < dungeon_width - 1; x++) room_line[x] = (char) fill;
  room_line[dungeon_width - 1] = (char) right;
  room_line[dungeon_width] = 0;

  epyx_move_cursor(dungeon_x, y);
  epyx_write_string(room_line);
}

static void draw_room()
{
  int y;

  draw_room_line(dungeon_y, '+', '-', '+');
  for (y = 1; y < dungeon_height - 1; y++)
    draw_room_line(dungeon_y + y, '|', '.', '|');
  draw_room_line(dungeon_y + dungeon_height - 1, '+', '-', '+');

  put_at(top_door_x, dungeon_y, '+');
  put_at(top_door_x, dungeon_y - 1, '#');
  put_at(bottom_door_x, dungeon_y + dungeon_height - 1, '+');
  if (dungeon_y + dungeon_height < status_y) put_at(bottom_door_x, dungeon_y + dungeon_height, '#');
}

static void draw_status()
{
  int armor;
  char redraw;

  redraw = status_invalid;
  armor = worn_armor ? 6 : 5;

  if (redraw || dungeon_level != last_status_level) {
    epyx_move_cursor(0, status_y);
    epyx_printf(rogue_string_at(OFF_STATUS_LEVEL_FORMAT), dungeon_level);
    last_status_level = dungeon_level;
  }
  if (redraw || player_hp != last_status_hp) {
    epyx_move_cursor(9, status_y);
    epyx_printf(rogue_string_at(OFF_STATUS_HITS_FORMAT), player_hp, 12);
    last_status_hp = player_hp;
  }
  if (redraw) {
    epyx_move_cursor(23, status_y);
    epyx_printf(rogue_string_at(OFF_STATUS_STRENGTH_FORMAT), 16, 16);
  }
  if (redraw || player_gold != last_status_gold) {
    epyx_move_cursor(38, status_y);
    epyx_printf(rogue_string_at(OFF_STATUS_GOLD_FORMAT), player_gold);
    last_status_gold = player_gold;
  }
  if (redraw || armor != last_status_armor) {
    epyx_move_cursor(52, status_y);
    epyx_printf(rogue_string_at(OFF_STATUS_ARMOR_FORMAT), armor);
    last_status_armor = (char) armor;
  }
  status_invalid = 0;
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
  if (monster.hp > 0) put_at(monster.x, monster.y, 'K');
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
  return x > dungeon_x && x < dungeon_x + dungeon_width - 1 &&
         y > dungeon_y && y < dungeon_y + dungeon_height - 1;
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
  if (x == stair_x && y == stair_y) return '>';
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

static int occupied_floor_position(x, y)
int x;
int y;
{
  if (x == hero_x && y == hero_y) return 1;
  if (x == stair_x && y == stair_y) return 1;
  if (monster.hp > 0 && x == monster.x && y == monster.y) return 1;
  return object_at(x, y) != 0;
}

static void random_floor_position(xp, yp)
int *xp;
int *yp;
{
  int tries;
  int x;
  int y;

  for (tries = 0; tries < 40; tries++) {
    x = dungeon_x + 1 + random_range(dungeon_width - 2);
    y = dungeon_y + 1 + random_range(dungeon_height - 2);
    if (!occupied_floor_position(x, y)) {
      *xp = x;
      *yp = y;
      return;
    }
  }

  *xp = dungeon_x + 1;
  *yp = dungeon_y + 1;
}

static void set_random_floor_object(slot, kind, glyph, subtype, quantity)
int slot;
int kind;
int glyph;
int subtype;
int quantity;
{
  int x;
  int y;

  random_floor_position(&x, &y);
  set_floor_object(slot, kind, glyph, subtype, x, y, quantity);
}

static void populate_level()
{
  int i;
  int x;
  int y;

  for (i = 0; i < FLOOR_OBJECTS; i++) floor_objects[i].kind = OBJ_NONE;

  hero_x = dungeon_x + dungeon_width / 2;
  hero_y = dungeon_y + dungeon_height / 2;

  monster.hp = 0;
  random_floor_position(&x, &y);
  monster.x = (char) x;
  monster.y = (char) y;
  monster.hp = (char) (2 + dungeon_level);

  set_random_floor_object(0, OBJ_GOLD, '$', 0, 20 + random_range(60));
  set_random_floor_object(1, OBJ_FOOD, '%', 0, 1);
  set_random_floor_object(2, OBJ_POTION, '?', random_range(POTION_COUNT), 1);
  set_random_floor_object(3, OBJ_SCROLL, '~', random_range(SCROLL_COUNT), 1);
  set_random_floor_object(4, OBJ_WEAPON, '^', 0, 1);
  set_random_floor_object(5, OBJ_ARMOR, '*', 0, 1);
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

static void no_appropriate()
{
  epyx_message(rogue_string_at(OFF_NO_APPROPRIATE_OBJECT));
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
  if (worn_armor) {
    armor_guard = !armor_guard;
    if (armor_guard) {
      epyx_message("The armor absorbs the hit.");
      return;
    }
  }

  player_hp--;
  draw_status();
  if (player_hp <= 0) {
    epyx_message(rogue_string_at(OFF_DEATH_YOU_DIED));
  } else {
    epyx_message("It hits.");
  }
}

static char object_glyph(kind)
int kind;
{
  if (kind == OBJ_FOOD) return '%';
  if (kind == OBJ_POTION) return '?';
  if (kind == OBJ_SCROLL) return '~';
  if (kind == OBJ_WEAPON) return '^';
  return '*';
}

static const char *formatted_name(fmt, name)
const char *fmt;
const char *name;
{
  epyx_format(object_name_buf, sizeof(object_name_buf), fmt, name);
  return object_name_buf;
}

static const char *formatted_name2(fmt, a, b)
const char *fmt;
const char *a;
const char *b;
{
  epyx_format(object_name_buf, sizeof(object_name_buf), fmt, a, b);
  return object_name_buf;
}

static const char *potion_color(subtype)
int subtype;
{
  if (subtype < 0 || subtype >= POTION_COUNT) return "clear";
  return potion_colors[potion_color_index[subtype]];
}

static int starts_with_vowel(s)
const char *s;
{
  return *s == 'a' || *s == 'e' || *s == 'i' || *s == 'o' || *s == 'u';
}

static const char *object_name(kind, subtype)
int kind;
int subtype;
{
  if (kind == OBJ_FOOD) return rogue_string_at(OFF_SOME_FOOD);
  if (kind == OBJ_POTION) {
    if (epyx_potion_known(subtype))
      return formatted_name2("a potion of %s(%s)",
                             epyx_potion_name(subtype),
                             potion_color(subtype));
    if (starts_with_vowel(potion_color(subtype)))
      return formatted_name("an %s potion", potion_color(subtype));
    return formatted_name("a %s potion", potion_color(subtype));
  }
  if (kind == OBJ_SCROLL) {
    if (epyx_scroll_known(subtype))
      return formatted_name("a scroll of %s", epyx_scroll_name(subtype));
    return formatted_name("a scroll titled '%s'",
                          rogue_string_at(OFF_RANDOM_SCROLL_NAMES +
                                          subtype * SCROLL_TITLE_SIZE));
  }
  if (kind == OBJ_WEAPON) return "a mace";
  if (kind == OBJ_ARMOR) return "some armor";
  return "something";
}

static InventoryItem *inventory_item(kind, subtype)
int kind;
int subtype;
{
  int i;

  for (i = 0; i < inventory_count; i++) {
    if (inventory[i].kind == kind && inventory[i].subtype == subtype)
      return &inventory[i];
  }
  return 0;
}

static int has_inventory_kind(kind)
int kind;
{
  int i;

  for (i = 0; i < inventory_count; i++) {
    if (inventory[i].kind == kind) return 1;
  }
  return 0;
}

static InventoryItem *add_item(kind, glyph, subtype, quantity)
int kind;
int glyph;
int subtype;
int quantity;
{
  InventoryItem *item;

  item = inventory_item(kind, subtype);
  if (item) {
    item->quantity = (char) (item->quantity + quantity);
    return item;
  }
  if (inventory_count >= INVENTORY_MAX) return 0;

  item = &inventory[inventory_count++];
  item->kind = (char) kind;
  item->glyph = (char) glyph;
  item->subtype = (char) subtype;
  item->quantity = (char) quantity;
  return item;
}

static void remove_item(item)
InventoryItem *item;
{
  int index;

  if (!item) return;
  if (item->quantity > 1) {
    item->quantity--;
    return;
  }

  index = item - inventory;
  inventory_count--;
  while (index < inventory_count) {
    inventory[index] = inventory[index + 1];
    index++;
  }
}

static void pickup_object(obj)
RogueObject *obj;
{
  if (obj->kind == OBJ_GOLD) {
    player_gold += obj->quantity;
    rogue_put16(OFF_PLAYER_GOLD, player_gold);
    epyx_message(rogue_string_at(OFF_FOUND_GOLD_MESSAGE), obj->quantity);
  } else {
    if (!add_item(obj->kind, obj->glyph, obj->subtype, obj->quantity)) {
      epyx_message("Pack full.");
      return;
    }
    epyx_message(rogue_string_at(OFF_FOUND_OBJECT_MESSAGE),
                 object_name(obj->kind, obj->subtype));
  }

  obj->kind = OBJ_NONE;
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
    monster.hp -= wielded_weapon ? 2 : 1;
    turn_taken = 1;
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
  turn_taken = 1;
  draw_hero();
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
    no_appropriate();
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

static void copy_string(dest, src)
char *dest;
const char *src;
{
  while ((*dest++ = *src++) != 0) ;
}

static void ask_player_name()
{
  char *name;
  int ch;
  int len;

  name = rogue_string_at(OFF_PLAYER_NAME_BUFFER);
  len = 0;
  name[0] = 0;

  epyx_clear_window();
  epyx_move_cursor(0, 0);
  epyx_write_string(rogue_string_at(OFF_NAME_PROMPT));
  epyx_cursor_on();

  while (1) {
    ch = read_key();
    if (ch == KEY_RETURN) break;
    if (ch == KEY_ESCAPE || ch == KEY_CTRL_E) {
      len = 0;
      break;
    }
    if ((ch == 8 || ch == 127) && len > 0) {
      len--;
      name[len] = 0;
      epyx_write_char(8);
      epyx_write_char(' ');
      epyx_write_char(8);
    } else if (ch >= 32 && ch < 127 && len < 23) {
      name[len++] = (char) ch;
      name[len] = 0;
      epyx_write_char(ch);
    }
  }

  epyx_cursor_off();
  if (len > 0) copy_string(rogue_string_at(OFF_DEFAULT_PLAYER_NAME), name);
}

static void preload_text_file(path, buffer, max)
const char *path;
char *buffer;
int max;
{
  path_id fd;
  int count;

  buffer[0] = 0;
  if (_os_open(path, FAM_READ, &fd) != 0) return;

  count = max - 1;
  if (_os_read(fd, buffer, &count) == 0) buffer[count] = 0;
  _os_close(fd);
}

static InventoryItem *choose_item(prompt, kind)
const char *prompt;
int kind;
{
  int ch;
  int index;

  if (inventory_count == 0 || (kind && !has_inventory_kind(kind))) {
    no_appropriate();
    return 0;
  }

  while (1) {
    epyx_message(prompt);
    ch = read_key();
    if (ch == KEY_ESCAPE || ch == KEY_CTRL_E) {
      epyx_message("Cancelled.");
      return 0;
    }
    if (ch == '*' || ch == ':') {
      show_inventory();
      continue;
    }
    if (ch >= 'A' && ch <= 'Z') ch += 'a' - 'A';
    index = ch - 'a';
    if (index >= 0 && index < inventory_count &&
        (kind == 0 || inventory[index].kind == kind))
      return &inventory[index];
    no_appropriate();
    return 0;
  }
}

static void eat_item()
{
  InventoryItem *item;

  item = choose_item("Eat what?", OBJ_FOOD);
  if (!item) return;

  remove_item(item);
  epyx_message(rogue_string_at(OFF_EAT_GOOD_FOOD));
}

static void quaff_item()
{
  InventoryItem *item;
  int subtype;

  item = choose_item("Quaff what?", OBJ_POTION);
  if (!item) return;

  subtype = item->subtype;
  epyx_set_potion_known(subtype);
  remove_item(item);
  if (subtype == POTION_HEALING) {
    player_hp += 4;
    if (player_hp > 12) player_hp = 12;
    draw_status();
    epyx_message(rogue_string_at(OFF_POTION_HEALING_MESSAGE));
  } else {
    epyx_message(rogue_string_at(OFF_ODD_TASTING_POTION));
  }
}

static void read_scroll()
{
  InventoryItem *item;
  int subtype;

  item = choose_item("Read what?", OBJ_SCROLL);
  if (!item) return;

  subtype = item->subtype;
  epyx_set_scroll_known(subtype);
  remove_item(item);
  if (subtype == SCROLL_MAGIC_MAPPING) {
    redraw_dungeon();
    epyx_message(rogue_string_at(OFF_SCROLL_MAP_MESSAGE));
  } else {
    epyx_message(rogue_string_at(OFF_BLANK_SCROLL_MESSAGE));
  }
}

static void wield_item()
{
  if (!choose_item("Wield what?", OBJ_WEAPON)) return;

  wielded_weapon = 1;
  epyx_message("You are now wielding a mace.");
}

static void wear_armor()
{
  if (worn_armor) {
    epyx_message("You are already wearing some.");
    return;
  }
  if (!choose_item("Wear what?", OBJ_ARMOR)) return;

  worn_armor = 1;
  armor_guard = 0;
  epyx_message("You are now wearing armor.");
}

static void take_off_armor()
{
  if (!worn_armor) {
    epyx_message("You aren't wearing any armor.");
    return;
  }

  worn_armor = 0;
  armor_guard = 0;
  epyx_message("You used to be wearing armor.");
}

static void drop_item()
{
  RogueObject *obj;
  InventoryItem *item;
  int kind;

  if (object_at(hero_x, hero_y)) {
    no_appropriate();
    return;
  }

  item = choose_item("Drop what?", 0);
  if (!item) return;
  kind = item->kind;

  obj = free_floor_object();
  if (!obj) {
    no_appropriate();
    return;
  }

  obj->kind = (char) kind;
  obj->glyph = item->glyph;
  obj->subtype = item->subtype;
  obj->x = (char) hero_x;
  obj->y = (char) hero_y;
  obj->quantity = 1;
  remove_item(item);
  if (kind == OBJ_WEAPON && !has_inventory_kind(OBJ_WEAPON)) wielded_weapon = 0;
  if (kind == OBJ_ARMOR && !has_inventory_kind(OBJ_ARMOR)) {
    worn_armor = 0;
    armor_guard = 0;
  }
  turn_taken = 1;
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
  epyx_write_string("Quit (Yes/No)?");

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

static void show_help_text(text)
char *text;
{
  int y;
  int aborted;
  char line[33];
  int i;

  if (text[0] == 0) {
    epyx_message("Help file not loaded.");
    return;
  }

  epyx_clear_window();
  y = 0;
  aborted = 0;
  while (1) {
    i = 0;
    while (*text && *text != '\r' && i < sizeof(line) - 1) line[i++] = *text++;
    while (*text && *text != '\r') text++;
    if (*text == '\r') text++;
    line[i] = 0;

    if (line[0] == 0) break;
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

  if (!aborted) wait_for_space_or_escape_after(y);
  redraw_dungeon();
}

static void show_inventory()
{
  int i;
  InventoryItem *item;

  if (inventory_count == 0) {
    epyx_message("You are empty handed.");
    return;
  }

  epyx_clear_window();
  for (i = 0; i < inventory_count; i++) {
    item = &inventory[i];
    epyx_move_cursor(0, i);
    epyx_printf("%c) %s", 'a' + i, object_name(item->kind, item->subtype));
    if (item->quantity > 1) epyx_printf(" [%d]", item->quantity);
    if (item->kind == OBJ_WEAPON && wielded_weapon) epyx_printf(" (wielded)");
    if (item->kind == OBJ_ARMOR && worn_armor) epyx_printf(" (worn)");
    epyx_clear_to_eol();
  }
  wait_for_space_or_escape_at(inventory_count + 1);
  redraw_dungeon();
}

static void redraw_dungeon()
{
  epyx_clear_window();
  draw_room();
  put_at(stair_x, stair_y, '>');
  draw_floor_objects();
  draw_monster();
  status_invalid = 1;
  draw_status();
  draw_hero();
}

static void change_level(delta)
int delta;
{
  if (delta > 0 && (hero_x != stair_x || hero_y != stair_y)) {
    epyx_message(rogue_string_at(OFF_NO_WAY_DOWN));
    return;
  }

  if (delta < 0 && dungeon_level == 1) {
    epyx_message(rogue_string_at(OFF_NO_WAY_UP));
    return;
  }

  dungeon_level = (char) (dungeon_level + delta);
  rogue_put8(OFF_DUNGEON_LEVEL, dungeon_level);
  populate_level();
  redraw_dungeon();
  epyx_message("You are now on level %d.", dungeon_level);
}

static int movement_delta(ch)
int ch;
{
  if (ch == 'h' || ch == 8) return 1;
  if (ch == 'l' || ch == 9) return 2;
  if (ch == 'k' || ch == 12) return 3;
  if (ch == 'j' || ch == 10 || ch == 13) return 4;
  if (ch == 'y') return 5;
  if (ch == 'u') return 6;
  if (ch == 'b') return 7;
  if (ch == 'n') return 8;
  return 0;
}

static int command(ch)
int ch;
{
  int move;
  int lower;

  lower = ch;
  if (lower >= 'A' && lower <= 'Z') lower += 'a' - 'A';

  /* rogue.asm:L4400 movement command cluster. */
  move = movement_delta(lower);
  if (move == 1) try_move(-1, 0);
  else if (move == 2) try_move(1, 0);
  else if (move == 3) try_move(0, -1);
  else if (move == 4) try_move(0, 1);
  else if (move == 5) try_move(-1, -1);
  else if (move == 6) try_move(1, -1);
  else if (move == 7) try_move(-1, 1);
  else if (move == 8) try_move(1, 1);

  /* rogue.asm:L43AD legal turn commands that are not movement. */
  else if (ch == '.') turn_taken = 1;

  /* rogue.asm:L448A-L44C6 inventory and item command cluster. */
  else if (ch == ',') pickup_here();
  else if (ch == 'd') drop_item();
  else if (ch == 'e') eat_item();
  else if (ch == 'i') show_inventory();
  else if (ch == 'q') quaff_item();
  else if (ch == 'r') read_scroll();
  else if (ch == 'w') wield_item();
  else if (ch == 'W') wear_armor();
  else if (ch == 'T') take_off_armor();

  /* rogue.asm:L4505-L451F stairs and symbol/help commands. */
  else if (ch == '>') change_level(1);
  else if (ch == '<') change_level(-1);
  else if (ch == '?') show_help_text(rogue_help_text);
  else if (ch == '/') show_help_text(rogue_chr_text);

  /* rogue.asm:L447D quit command. */
  else if (ch == 'Q') return confirm_quit();
  else if (ch == KEY_ESCAPE || ch == KEY_CTRL_E) {
    epyx_message("Cancelled.");
  } else {
    epyx_message("Unknown command.");
  }
  return 1;
}

int rogue_game_run()
{
  int ch;

  dungeon_level = 1;
  player_gold = 0;
  player_hp = 12;
  wielded_weapon = 0;
  worn_armor = 0;
  armor_guard = 0;
  turn_taken = 0;
  inventory_count = 0;
  status_invalid = 1;
  rogue_ignore_signals();
  epyx_screen_init();
  init_layout();
  terminal_game_mode();
  seed_random();
  init_object_names();
  show_title_screen();
  ask_player_name();
  rogue_put8(OFF_DUNGEON_LEVEL, dungeon_level);
  rogue_put16(OFF_PLAYER_GOLD, player_gold);
  add_item(OBJ_FOOD, object_glyph(OBJ_FOOD), 0, 1);
  populate_level();
  preload_text_file("rogue.hlp", rogue_help_text, HELP_TEXT_MAX);
  preload_text_file("rogue.chr", rogue_chr_text, CHR_TEXT_MAX);
  redraw_dungeon();
  epyx_message(rogue_string_at(OFF_NEW_GAME_GREETING),
               rogue_string_at(OFF_DEFAULT_PLAYER_NAME));

  while (1) {
    ch = read_key();
    if (ch < 0) break;
    if (!command(ch)) break;
    if (turn_taken) {
      turn_taken = 0;
      monster_turn();
    }
    if (player_hp <= 0) break;
  }

  if (player_hp <= 0) show_death_screen();
  terminal_finish();
  return 0;
}
