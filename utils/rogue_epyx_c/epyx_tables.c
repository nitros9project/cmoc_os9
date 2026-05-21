#include "epyx_arena.h"
#include "epyx_tables.h"

static char empty_name[1];

static char *table_string(table, count, index)
unsigned int table;
int count;
int index;
{
  if (index < 0 || index >= count) return empty_name;
  return rogue_ptr_string(table, index);
}

static EpyxObjectInfo object_table_info(table, count, index)
unsigned int table;
int count;
int index;
{
  unsigned int entry;
  EpyxObjectInfo info;

  info.name = empty_name;
  info.data0 = 0;
  info.value = 0;
  if (index < 0 || index >= count) return info;

  entry = table + index * 4;
  info.name = rogue_string_at(rogue_get16(entry));
  info.data0 = rogue_get8(entry + 2);
  info.value = rogue_get8(entry + 3);
  return info;
}

char *epyx_default_player_name()
{
  return rogue_string_at(OFF_DEFAULT_PLAYER_NAME);
}

char *epyx_score_file_name()
{
  return rogue_string_at(OFF_SCORE_FILE_NAME);
}

char *epyx_save_file_name()
{
  return rogue_string_at(OFF_SAVE_FILE_NAME);
}

char *epyx_weapon_name(index)
int index;
{
  return table_string(OFF_WEAPON_NAME_TABLE, WEAPON_COUNT, index);
}

char *epyx_armor_name(index)
int index;
{
  return table_string(OFF_ARMOR_NAME_TABLE, ARMOR_COUNT, index);
}

char *epyx_rank_name(index)
int index;
{
  return table_string(OFF_RANK_NAME_TABLE, RANK_COUNT, index);
}

EpyxObjectInfo epyx_scroll_info(index)
int index;
{
  return object_table_info(OFF_SCROLL_TABLE, SCROLL_COUNT, index);
}

EpyxObjectInfo epyx_potion_info(index)
int index;
{
  return object_table_info(OFF_POTION_TABLE, POTION_COUNT, index);
}

EpyxObjectInfo epyx_ring_info(index)
int index;
{
  return object_table_info(OFF_RING_TABLE, RING_COUNT, index);
}

EpyxObjectInfo epyx_wand_info(index)
int index;
{
  return object_table_info(OFF_WAND_TABLE, WAND_COUNT, index);
}

char *epyx_scroll_name(index)
int index;
{
  return epyx_scroll_info(index).name;
}

char *epyx_potion_name(index)
int index;
{
  return epyx_potion_info(index).name;
}

char *epyx_ring_name(index)
int index;
{
  return epyx_ring_info(index).name;
}

char *epyx_wand_name(index)
int index;
{
  return epyx_wand_info(index).name;
}

int epyx_scroll_known(index)
int index;
{
  if (index < 0 || index >= SCROLL_COUNT) return 0;
  return rogue_get8(OFF_SCROLL_KNOWN_FLAGS + index) != 0;
}

int epyx_potion_known(index)
int index;
{
  if (index < 0 || index >= POTION_COUNT) return 0;
  return rogue_get8(OFF_POTION_KNOWN_FLAGS + index) != 0;
}

void epyx_set_scroll_known(index)
int index;
{
  if (index >= 0 && index < SCROLL_COUNT)
    rogue_put8(OFF_SCROLL_KNOWN_FLAGS + index, 1);
}

void epyx_set_potion_known(index)
int index;
{
  if (index >= 0 && index < POTION_COUNT)
    rogue_put8(OFF_POTION_KNOWN_FLAGS + index, 1);
}
