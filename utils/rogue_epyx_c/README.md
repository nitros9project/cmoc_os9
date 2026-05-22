# Epyx Rogue C Reconstruction

This directory is for a readable C reconstruction of the CoCo 3 Epyx Rogue
program. The goal is not to port the larger Unix/PC C source. The goal is to
translate the compact Epyx OS-9 architecture into maintainable C while keeping
the same external data-area model.

The original executable allocates 24K, reads `rogue.dat` into that arena, then
uses fixed offsets inside the arena for game state, tables, strings, and
screen buffers. This reconstruction keeps that model because it is the main
reason the Epyx executable is about 39K.

Current status:

- `epyx_offsets.h` names the first confirmed data-area offsets.
- `epyx_arena.c` loads `rogue.dat` and exposes typed accessors.
- `main.c` loads the arena and clears the command-line buffer at `$1528`;
  full option parsing is still pending translation.
- `epyx_screen.c` names the first translated terminal primitives from the
  `L63DD`/`L6CDE`/`L6D07`/`L6D6F` cluster.
- `epyx_format.c` translates the compact `L3D23` formatter subset and exposes
  the first readable wrappers for `L6D16`/`L68D8`-style output.
- `rogue_game.c` is the current playable harness. It draws a minimal room,
  moves the hero with `hjklyubn`, shows a Rogue-style status line, handles
  `?` and `/` using the original Epyx `rogue.hlp` and `rogue.chr` files, and
  uses confirmed `rogue.dat` offsets directly for inventory text and object
  names. This is not the translated game loop yet; it is a runnable target for
  testing display, input, data loading, and binary size while the real routines
  are translated.

Next translation targets:

1. Startup flow at `rogue.asm:L405F`.
2. Screen/status helpers around `L63DD`, `L6C95`, and `L6D07`.
3. New-game initialization calls at `L40A0`.
4. Command loop at `L418E`, replacing the temporary harness in `rogue_game.c`.

Keep functions named by behavior when known, and include the original assembly
label in comments while the translation is being verified.
