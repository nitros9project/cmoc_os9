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
#define OFF_WAND_TABLE               0x043c
#define OFF_RANK_NAME_TABLE          0x0504

#define OFF_SCROLL_KNOWN_FLAGS       0x05fe
#define OFF_POTION_KNOWN_FLAGS       0x060d
#define OFF_RING_KNOWN_FLAGS         0x061b
#define OFF_WAND_KNOWN_FLAGS         0x0629
#define OFF_RANDOM_SCROLL_NAMES      0x0642
#define OFF_POTION_COLOR_PTRS        0x077d
#define OFF_RING_STONE_PTRS          0x0799
#define OFF_WAND_MATERIAL_PTRS       0x07b5
#define OFF_SCROLL_CALLED_PTRS       0x07ed
#define OFF_POTION_CALLED_PTRS       0x080b
#define OFF_RING_CALLED_PTRS         0x0827
#define OFF_WAND_CALLED_PTRS         0x0843
#define OFF_SCROLL_CONSONANTS        0x4a23
#define OFF_SCROLL_VOWELS            0x4a39

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
#define OFF_TITLE_ROGUE              0x171b
#define OFF_TITLE_COPYRIGHT          0x1721
#define OFF_TITLE_PRESS_SPACE        0x1739
#define OFF_DEATH_RANKINGS_PROMPT    0x1965
#define OFF_SCORE_HALL_HEADER        0x19e1
#define OFF_SCORE_GOLD_HEADER        0x19fd
#define OFF_SCORE_ROW_FORMAT         0x1a07
#define OFF_SCORE_KILLED_BY_FORMAT   0x1a0f
#define OFF_SCORE_RANK_FORMAT        0x1a1d
#define OFF_SCORE_ON_LEVEL_FORMAT    0x1a23
#define OFF_MONSTER_TABLE            0x10fb
#define OFF_DEATH_EPITAPH            0x1a3c
#define OFF_DEATH_TOTAL_WORTH        0x1a57
#define OFF_DEATH_YOU_DIED           0x1a77
#define OFF_DEATH_TOP                0x1a81
#define OFF_DEATH_SHOULDER           0x1a87
#define OFF_DEATH_RIP                0x1a8f
#define OFF_DEATH_BLANK1             0x1a99
#define OFF_DEATH_BLANK2             0x1aa3
#define OFF_DEATH_BLANK3             0x1aad

#define OFF_DAMAGE_BONUS             0x220f
#define OFF_DAMAGE_TAKEN_BONUS       0x2211
#define OFF_PLAYER_NAME_BUFFER       0x2349
#define OFF_NAME_PROMPT              0x2362
#define OFF_NEW_GAME_GREETING        0x24b9
#define OFF_DEBUG_ENABLE_FLAG        0x26bc
#define OFF_RING_MOD_MAX_DAMAGE      0x2a34

#define OFF_FORMAT_BUFFER            0x35bf
#define OFF_MESSAGE_LENGTH           0x363f
#define OFF_MESSAGE_CURSOR_X         0x3640
#define OFF_MESSAGE_TEXT_WIDTH       0x3641
#define OFF_ASCII_GLYPH_TABLE        0x35a6

#define OFF_GRAPHICS_FONT_FLAG       0x3571
#define OFF_MIN_WINDOW_WIDTHS        0x3664
#define OFF_STATUS_X_TABLE           0x3671
#define OFF_STATUS_Y_TABLE           0x36a1
#define OFF_STATUS_HEIGHT_ADJUST     0x3660
#define OFF_STATUS_USABLE_HEIGHT     0x3661
#define OFF_STATUS_TABLE_OFFSET      0x3662
#define OFF_LAST_FAST_MODE_FLAG      0x3700
#define OFF_STATUS_FORMATS           0x3701
#define OFF_STATUS_LEVEL_FORMAT      0x3701
#define OFF_STATUS_HITS_FORMAT       0x370e
#define OFF_STATUS_STRENGTH_FORMAT   0x371e
#define OFF_STATUS_GOLD_FORMAT       0x372d
#define OFF_STATUS_ARMOR_FORMAT      0x3739
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
#define OFF_ACTION_EAT               0x3969
#define OFF_ACTION_DROP              0x396d
#define OFF_OBJECT_ACTION_PROMPT     0x3900
#define OFF_BAD_PACK_LETTER          0x392f
#define OFF_DROPPED_OBJECT_MESSAGE   0x3bc8
#define OFF_FOOD_NAME                0x4342
#define OFF_ACTION_WEAR              0x4205
#define OFF_ALREADY_WEARING_ARMOR    0x420a
#define OFF_NOW_WEARING_ARMOR        0x425e
#define OFF_NO_ARMOR_WORN            0x4275
#define OFF_TOOK_OFF_ARMOR           0x4292
#define OFF_ACTION_WIELD             0x439a
#define OFF_NOW_WIELDING_WEAPON      0x43b6
#define OFF_ACTION_READ              0x15d7
#define OFF_ACTION_QUAFF             0x4690
#define OFF_SCROLL_MAP_MESSAGE       0x44c5
#define OFF_BLANK_SCROLL_MESSAGE     0x45cd
#define OFF_POTION_HEALING_MESSAGE   0x4707
#define OFF_ODD_TASTING_POTION       0x48e1
#define OFF_COMBAT_HITS              0x20c9
#define OFF_COMBAT_HIT               0x20ce
#define OFF_COMBAT_JOIN_FORMAT       0x2284
#define OFF_COMBAT_THE_MONSTER_VERB  0x2304
#define OFF_COMBAT_YOU_VERB          0x2310
#define OFF_COMBAT_DEFEATED          0x2328

#define WEAPON_COUNT                 10
#define ARMOR_COUNT                  8
#define SCROLL_COUNT                 15
#define POTION_COUNT                 14
#define RING_COUNT                   14
#define WAND_COUNT                   14
#define RANK_COUNT                   21
#define MONSTER_ENTRY_SIZE           18
#define FORMAT_BUFFER_SIZE           128
#define SCROLL_TITLE_SIZE            21

#endif
