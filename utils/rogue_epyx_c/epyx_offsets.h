#ifndef EPYX_OFFSETS_H
#define EPYX_OFFSETS_H

/*
 * Offsets into the 24K arena loaded from Epyx rogue.dat.
 * These names come from direct references in rogue.asm.
 */

#define ROGUE_ARENA_SIZE             0x6000
#define ROGUE_DAT_EXPECTED_SIZE      0x5e4a

#define OFF_WEAPON_NAME_TABLE        0x004b
#define OFF_ARMOR_NAME_TABLE         0x00c7
#define OFF_SCROLL_TABLE             0x0156
#define OFF_POTION_TABLE             0x0262
#define OFF_RING_TABLE               0x034c
#define OFF_RANK_NAME_TABLE          0x0504

#define OFF_SCROLL_FLAGS             0x061b
#define OFF_OBJECT_IDENT_FLAGS       0x0629
#define OFF_RANDOM_SCROLL_NAMES      0x0642
#define OFF_POTION_COLOR_PTRS        0x077d
#define OFF_RING_STONE_PTRS          0x0799
#define OFF_WAND_MATERIAL_PTRS       0x07b5
#define OFF_SCROLL_CALLED_PTRS       0x07ed
#define OFF_POTION_CALLED_PTRS       0x080b
#define OFF_RING_CALLED_PTRS         0x0827
#define OFF_WAND_CALLED_PTRS         0x0843

#define OFF_CURRENT_ARMOR_PTR        0x0db1
#define OFF_OLD_HERO_POS             0x0dad
#define OFF_CURRENT_ROOM_TILE_PTR    0x0db9
#define OFF_DUNGEON_LEVEL            0x0d91
#define OFF_PLAYER_GOLD              0x0d92
#define OFF_HERO_POS                 0x10dc

#define OFF_DEFAULT_PLAYER_NAME      0x14b0
#define OFF_SCORE_FILE_NAME          0x14c8
#define OFF_SAVE_FILE_NAME           0x14d5
#define OFF_MACRO_TEXT               0x14e1
#define OFF_FAST_MODE_FLAG           0x1527
#define OFF_COMMAND_LINE             0x1528
#define OFF_AUTHOR_HEADER            0x153c
#define OFF_SAVE_HEADER_BUFFER       0x156e

#define OFF_DAMAGE_BONUS             0x220f
#define OFF_DAMAGE_TAKEN_BONUS       0x2211
#define OFF_PLAYER_NAME_BUFFER       0x2349
#define OFF_DEBUG_ENABLE_FLAG        0x26bc
#define OFF_RING_MOD_MAX_DAMAGE      0x2a34

#define OFF_FORMAT_BUFFER            0x35bf
#define OFF_MESSAGE_LENGTH           0x363f
#define OFF_MESSAGE_CURSOR_X         0x3640
#define OFF_MESSAGE_TEXT_WIDTH       0x3641

#define OFF_GRAPHICS_FONT_FLAG       0x3571
#define OFF_MIN_WINDOW_WIDTHS        0x3664
#define OFF_STATUS_X_TABLE           0x3671
#define OFF_STATUS_Y_TABLE           0x36a1
#define OFF_STATUS_HEIGHT_ADJUST     0x3660
#define OFF_STATUS_USABLE_HEIGHT     0x3661
#define OFF_STATUS_TABLE_OFFSET      0x3662
#define OFF_LAST_FAST_MODE_FLAG      0x3700
#define OFF_STATUS_FORMATS           0x3701
#define OFF_SCREEN_WIDTH             0x37cb
#define OFF_SCREEN_HEIGHT            0x37cc
#define OFF_SCREEN_MAX_X             0x37cd
#define OFF_SCREEN_MAX_Y             0x37ce
#define OFF_CHAR_BUFFER              0x37cf
#define OFF_CURSOR_XY_BUFFER         0x37d0
#define OFF_REVERSE_OFF              0x37dd
#define OFF_REVERSE_ON               0x37e0
#define OFF_CURSOR_ON                0x2def
#define OFF_CURSOR_OFF               0x2df1
#define OFF_EAT_GOOD_FOOD            0x29fd
#define OFF_NO_WAY_DOWN              0x2b04
#define OFF_NO_WAY_UP                0x2b5f
#define OFF_FOUND_OBJECT_MESSAGE     0x2af1
#define OFF_SOME_FOOD                0x3a29
#define OFF_NO_APPROPRIATE_OBJECT    0x3860
#define OFF_FOUND_GOLD_MESSAGE       0x3981
#define OFF_FOOD_NAME                0x4342

#define WEAPON_COUNT                 10
#define ARMOR_COUNT                  8
#define RANK_COUNT                   21
#define FORMAT_BUFFER_SIZE           128

#endif
