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
