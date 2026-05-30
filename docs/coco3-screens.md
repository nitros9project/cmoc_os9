# CoCo 3 / NitrOS-9 screens, palettes, and windows

Quick reference for anyone writing tests against `cgfx`. Captures the
platform constraints that shape what a graphics-test scenario can exercise.

## Palette

The GIME has **16 palette slots** (`prn` 0–15). Each slot holds one of **64
RGB values** in the form `RGBrgb`, six bits:

```
bit 5 = R  (red,   high intensity)
bit 4 = G  (green, high)
bit 3 = B  (blue,  high)
bit 2 = r  (red,   low)
bit 1 = g  (green, low)
bit 0 = b  (blue,  low)
```

So `0` is black, `63` (`0b111111`) is white. Naming a few useful values:

| Value | Bits      | Color           |
|-------|-----------|-----------------|
| 0     | `000000`  | black           |
| 9     | `001001`  | bright blue     |
| 18    | `010010`  | bright green    |
| 36    | `100100`  | bright red      |
| 27    | `011011`  | bright cyan     |
| 45    | `101101`  | bright magenta  |
| 54    | `110110`  | bright yellow   |
| 63    | `111111`  | white           |

Single-bit values (e.g. `8 = 001000`) give dimmer variants — the same hue at
half intensity.

cgfx APIs:

- `_cgfx_palette(path, prn, colno)` — set slot `prn` to color `colno`.
- `_cgfx_fcolor(path, prn)` / `_cgfx_bcolor(path, prn)` / `_cgfx_border(path, prn)`
- `_cgfx_defcolr(path)` — restore the default 16-slot palette for that window type.

## Screen types

Set via the second arg of `_cgfx_dwset()` / `_cgfx_owset()`. All sizes are
in character cells; the harness exposes them at their pixel resolution.

| Type | Kind     | Resolution | Char grid | Colors | Palette slots used |
|------|----------|-----------|-----------|--------|--------------------|
| 1    | text     | —         | 40×25     | 16     | 0–7 bg, 8–15 fg    |
| 2    | text     | —         | 80×25     | 16     | 0–7 bg, 8–15 fg    |
| 5    | graphics | 640×200   | 80×25     | 2      | 0–1                |
| 6    | graphics | 320×200   | 40×25     | 4      | 0–3                |
| 7    | graphics | 640×200   | 80×25     | 4      | 0–3                |
| 8    | graphics | 320×200   | 40×25     | 16     | 0–15               |

The `SetType()` helper at `cgfx/settype.c` uses a 24-row default height for
types 1, 6, 8 (40 wide) and types 2, 5, 7 (80 wide). The 25th row exists on
the screen but the standard NitrOS-9 window leaves it out of the usable
window area.

### Text-screen attributes

Type 1 and 2 windows support:

- **Underline** — `_cgfx_undlnon/off(path)`
- **Blink** — `_cgfx_blnkon/off(path)`. Blinking is **text-only**; graphics
  screens (5–8) do not support it. Snapshot timing matters for blink — use
  `ssim` comparison or mask the blinking region.

`_cgfx_revon/revoff` exists in the API but does **not** produce reverse
video on text screens despite the header doc; it's effectively a no-op
here. Use a graphics-screen window (5–8) if you need reverse.

### Graphics-screen text

Types 5–8 can render text with:

- Bold, underline (via `_cgfx_boldsw`, `_cgfx_undlnon/off`)
- Any FG / BG palette slot in the screen's allowed range
- A transparency switch that overlays text over existing graphics without
  filling the cell background

No blink on graphics screens.

## Windows and screens

A *screen* is a single GIME mode + framebuffer. A *window* (set up via
`_cgfx_dwset` or overlaid via `_cgfx_owset`) is a rectangular sub-region of
that screen.

Two hard constraints to remember when designing a test:

1. **All windows on a screen must be the same type.** You can't mix a text
   window and a graphics window on one screen.
2. **Windows on the same screen cannot overlap.** Overlays (`_cgfx_owset`)
   are the documented mechanism for stacking.

Each `/wN` device is one window. The recipe ships `w` through `w15`
(`recipes/coco3/recipe.mak`). Tests typically open `/w` (first available).

## Gotchas (cgfx-side)

- **cgfx buffers output in a 256-byte per-path ring** (`cgfx/cbuffer.as`).
  In a loop that pairs a state-change call (`_cgfx_bcolor`, `_cgfx_fcolor`,
  `_cgfx_curxy`, etc.) with a `cwrite()`, pending bytes can sit unsent long
  enough that a snapshot misses them or successive state changes collide.
  Call `Flush()` after each iteration (declared in `cgfx.h`).

- **`_cgfx_dwset(type=1, …, szy=24)` only renders rows 0..21** in
  practice, even though the docs would lead you to expect 24 rows. Pass
  `szy=25` to get the full 0..22 (23 usable rows). The matching `+1`
  also appears in `graphictest/maze.c` for type-6 (graphics) windows
  with the comment "up one line for modern screen drivers".

- **`_cgfx_font` with a different-width buffer resets cursor X to 0**.
  grfdrv (`level2/cmds/grfdrv.asm:1611-1626`) compares the new font's
  pixel width to the active one; if they differ (e.g. switching from
  8x8 / FNT_S8X8 to 6x8 / FNT_S6X8), it calls `L11CD` which clears
  `Wt.CurX`. Y is untouched. The mechanical reason: old-font column
  indices don't map to new-font pixel addresses, so resetting X is the
  safe default. **Practical impact**: any "write label, switch font,
  write text" sequence on the *same row* loses the label — the
  post-switch write starts at col 0 and overwrites it. Switch the font
  *before* the row's first write, or accept the implicit CR.

## See also

- `cgfx/include/cgfx.h` — full API surface, with per-function notes.
- `cgfx/settype.c` — canonical `SetType()` helper, useful as a reference
  for type-1/2/6/8 default geometry.
- `graphictest/README.md` — how scenarios snapshot and compare these.
