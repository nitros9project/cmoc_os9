#ifndef EPYX_TABLES_H
#define EPYX_TABLES_H

typedef struct epyx_object_info {
  char *name;
  unsigned char data0;
  unsigned char value;
} EpyxObjectInfo;

char *epyx_default_player_name();
char *epyx_score_file_name();
char *epyx_save_file_name();
char *epyx_weapon_name(int index);
char *epyx_armor_name(int index);
char *epyx_rank_name(int index);
EpyxObjectInfo epyx_scroll_info(int index);
EpyxObjectInfo epyx_potion_info(int index);
EpyxObjectInfo epyx_ring_info(int index);
EpyxObjectInfo epyx_wand_info(int index);
char *epyx_scroll_name(int index);
char *epyx_potion_name(int index);
char *epyx_ring_name(int index);
char *epyx_wand_name(int index);
int epyx_scroll_known(int index);
int epyx_potion_known(int index);
void epyx_set_scroll_known(int index);
void epyx_set_potion_known(int index);

#endif
