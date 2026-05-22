# Epyx Rogue C Port Roadmap

This file is the working handoff plan for `roguec`, the readable C port of
Epyx Rogue for the CoCo 3. It is meant to be the first thing to read when a new
Codex session resumes work.

## Current State

- Working directory: `/Users/boisy/Projects/coco-shelf/cmoc_os9`
- Main source: `utils/rogue_epyx_c/rogue_game.c`
- Epyx references:
  - Assembly: `/Users/boisy/Projects/coco-shelf/nitros9/3rdparty/packages/rogue/rogue.asm`
  - Data: `/Users/boisy/Projects/coco-shelf/nitros9/3rdparty/packages/rogue/rogue.dat`
  - Help/symbol files: `rogue.hlp`, `rogue.chr`
  - Score file: `rogue.scr`
- Build command:

```sh
cd /Users/boisy/Projects/coco-shelf/cmoc_os9/utils/rogue_epyx_c
make clean && make && os9 ident roguec
```

Last known build:

```text
Module size: $3B19  #15129
Data size  : $6926  #26918
```

Only expected warning is the existing builtin macro warning from cmoc/clang:

```text
warning: undefining builtin macro [-Wbuiltin-macro-redefined]
```

## Implemented So Far

- Loads Epyx `rogue.dat` into the arena and uses many data-backed strings.
- Uses Epyx screen/status format strings from `rogue.dat`.
- Startup title flow with Epyx-style corner asterisk animation.
- Player name prompt and greeting.
- Basic terminal option save/restore using `_os_gs_popt` / `_os_ss_popt`.
- Basic two-room discovered-map model:
  - player glyph from Epyx glyph table: `8`
  - floor/corridor/wall/door/stairs glyphs from `rogue.dat` table at `$35A6`
  - door glyph `/`
  - stairs glyph `=`
  - corridor reveal with `#`
  - no full-room redraw on ordinary player movement
- Basic inventory and object pickup/drop.
- Basic food, gold, potion, scroll, weapon, armor support.
- Weapon/armor names read from Epyx tables.
- Basic kobold monster and deterministic combat.
- Death screen with Epyx-style border/tombstone/rankings prompt.
- Read-only Hall of Fame display after death, using `rogue.scr`.
- Recipe disk refresh is handled externally by Boisy's script; do not refresh it
  unless explicitly asked.

## Current Design Constraints

- Keep source readable C. Do not turn this into a thin assembly wrapper.
- Prefer Epyx `rogue.dat` strings/tables over hardcoded text.
- Check `rogue.asm` before implementing behavior that Epyx already has.
- Watch code size aggressively. Every new feature should report module size.
- Keep build products out of intentional commits unless the project already
  wants them. `rogue.scr` is now copied by the local Makefile and should be
  included on the runtime disk alongside `rogue.dat`, `rogue.hlp`, and
  `rogue.chr`.

## High-Level Goal

The end goal is not a clone from scratch. The end goal is a readable C
reconstruction of the Epyx CoCo 3 Rogue behavior that can be built with cmoc and
run under OS-9.

## Next Feature Sequence

### 1. Epyx Initial Inventory

Implement this next.

Epyx setup routine: `rogue.asm` around `L96A1`.

Epyx initial inventory:

- dungeon level set to 1
- wielded `+1,+1 mace`
- short bow
- 25-40 arrows
- worn ring mail
- one food ration

Current C port only starts with food. Add the rest in a small readable way. This
will immediately make inventory, combat, wield/wear, and status feel more like
Epyx.

Suggested C-side steps:

- Replace `wielded_weapon` and `worn_armor` boolean-ish flags with item indexes
  or pointers if needed. The current flags are too weak once multiple weapons
  and armor items exist.
- Add initial mace, bow, arrows, ring mail, and food in `rogue_game_run()` or a
  small `init_inventory()` helper.
- Use Epyx weapon/armor names already available through `object_name()`.
- Keep quantities for arrows.
- Rebuild and inspect size.

### 2. Improve Inventory Formatting

Epyx object formatter is in `rogue.asm` around the object description routines
near `L72B6` and related code.

Current C inventory display is simplified:

```text
a) some item
```

Epyx inventory includes richer state such as:

- pack letters
- quantities
- weapon in hand
- armor being worn
- identified/unknown object names
- charges for wands/staves
- armor class details

Do a conservative pass first:

- Show quantities for stacked objects.
- Show `(weapon in hand)` / worn armor phrasing using Epyx strings if available.
- Keep the screen paging behavior intact.

### 3. Score File Persistence

The Hall of Fame screen is currently read-only.

Epyx score handling:

- `rogue.asm` around `L0434` through `L06AF`
- score file name string at `OFF_SCORE_FILE_NAME` (`rogue.scr`)
- entry size: 43 bytes
- seeded file entries include Romar and Shelly

Implement:

- Insert current score into top 10.
- Write updated `rogue.scr` back to disk.
- Preserve existing Epyx file format.
- Keep a fallback for missing score file, but do not overbuild the prompt flow
  until display/write behavior is correct.

### 4. Full Object Taxonomy Skeleton

Add object kinds before adding all effects:

- ring (`o`)
- wand/staff (`!`)
- trap (`"`)
- Amulet (`&`)

Use the Epyx glyph table at `$35A6`; offsets already include
`OFF_RING_TABLE`, `OFF_WAND_TABLE`, `OFF_RING_STONE_PTRS`,
`OFF_WAND_MATERIAL_PTRS`, etc.

First version should make them visible, pick-up-able, listable, and droppable.
Effects can follow.

### 5. Ring Commands

Epyx routines:

- `P` put on ring: around `L94E3`
- `R` remove ring: around `L9573`

Add:

- left/right ring slots
- `P` and `R` commands
- messages from `rogue.dat`
- minimal effects first:
  - add strength
  - see invisible
  - aggravate monster

### 6. Throw Command

Epyx throw routine starts around `L8745`.

Add `t` command:

- choose item
- ask direction
- animate/project object along path
- hit monster if present
- drop or vanish item based on Epyx behavior
- potion throw effects can be partial initially

### 7. Wand/Staff and Zap

Epyx zap routine starts around `L7D91`.

Add `z` command only after direction prompting and object taxonomy are stable.
Initial minimal effects:

- light
- magic missile
- striking

Later:

- polymorph
- teleport away/to
- cancellation
- haste/slow monster
- lightning/fire/cold bolts
- drain life

### 8. Search, Traps, Hidden Doors

Epyx has trap and hidden-door behavior scattered around map/search routines.

Add:

- trap placement
- trap discovery
- `I` identify trap type
- `s` search
- hidden doors

This likely depends on replacing the current two-room layout with a richer map.

### 9. Real Dungeon Generator

This is the largest missing behavior.

Epyx generator includes:

- 9 room blocks
- variable room size/position
- passages between rooms
- hidden doors
- traps
- stairs
- per-room visibility/discovery

Do not start here until object/inventory/combat foundations are less brittle.
When ready, replace the fixed two-room model with a level map representation
that can still render incrementally like Epyx.

### 10. Command Completeness

Missing commands from `rogue.hlp`:

- `S` save
- restore-from-save startup path
- `c` call/rename object
- `D` discovered items
- `I` identify trap type
- `s` search
- `v` version
- `a` repeat last command
- `CTRL-r` repeat last message
- `F`, shifted movement, and `f` fast mode
- `m` / `M` macro execute/define

These are lower priority than initial inventory, object taxonomy, and real
combat, but they should stay on the list.

## Known Simplifications To Revisit

- Combat is deterministic and only uses a kobold.
- Death cause for score/death is effectively kobold-oriented.
- Potion colors still use a C string table instead of Epyx assigned pointer
  tables.
- Scroll names are generated in C but should continue to track Epyx behavior.
- Current map is fixed two-room, not a real Epyx dungeon.
- Hall of Fame display merges current score in memory but does not write it.
- `Pack full.` and `The armor absorbs the hit.` are still hardcoded.
- `Loading...` is intentionally non-Epyx text but acceptable for now because the
  Epyx pause likely hides loading.

## Useful Offsets Already Defined

See `epyx_offsets.h`. Important ones:

- `OFF_ASCII_GLYPH_TABLE` = `$35A6`
- `OFF_WEAPON_NAME_TABLE` = `$004B`
- `OFF_ARMOR_NAME_TABLE` = `$00C7`
- `OFF_SCROLL_TABLE` = `$0156`
- `OFF_POTION_TABLE` = `$0262`
- `OFF_RING_TABLE` = `$034C`
- `OFF_WAND_TABLE` = `$043C`
- `OFF_RANK_NAME_TABLE` = `$0504`
- `OFF_SCORE_FILE_NAME` = `$14C8`
- `OFF_SCORE_HALL_HEADER` = `$19E1`
- `OFF_SCORE_GOLD_HEADER` = `$19FD`
- `OFF_SCORE_ROW_FORMAT` = `$1A07`

## Handoff Advice

When resuming:

1. Build first and record size.
2. Read this file.
3. Inspect `git diff -- utils/rogue_epyx_c`.
4. Continue with "Epyx Initial Inventory" unless Boisy asks otherwise.
5. After every feature, run:

```sh
make clean && make && os9 ident roguec
```

6. Report module size and data size.
