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

### Putting multiple windows on one screen

`_cgfx_dwset(sty=8, …)` always creates a new screen. To attach a second
or third window to an *existing* screen, pass **screen type 0** (not the
actual type) to dwset. cowin's screen-type conversion table
(`level2/coco3/modules/cowin.asm:1619-1620`) maps user-sty `$00` to the
internal "current screen" sentinel `$FF`, which sends the dwset down the
`L076D` path. That handler reads the calling process's currently
selected path (`P$SelP`) and inherits its screen.

Two things have to be true before the second dwset:

1. **Some path must be selected** (`_cgfx_select` on the first window).
   `P$SelP` is what L076D uses to find the parent screen.
2. **The Protect bit on existing windows must be off** if your new
   window's coords could intersect any of them. grfdrv's `L0224`
   overlap check (`level2/cmds/grfdrv.asm:752+`) iterates existing
   windows and, for each one that's still protected, demands the new
   window not overlap. Call `_cgfx_dwprotsw(w, 0)` on the existing
   window to clear it. If the windows genuinely don't overlap, this is
   redundant but harmless.

See `graphictest/gfx40win.c` for a worked three-window example.

### Default screen palette is the composite-monitor table

NitrOS-9 boots assuming a composite monitor. grfdrv routes palette
writes through a CMP→RGB translation table
(`cowin.asm:1893+`), so on RGB hardware (which is what MAME emits and
what the gfx-test harness configures), a palette write of `36` (R+r,
intended bright red) renders as cyan. Add `montype -r` to the recipe
`startup` to flip `G.MonTyp` to RGB mode — after that, palette values
go to the GIME verbatim.

The bundled recipe (`recipes/coco3/startup`) does this for the
graphics-test disk; if you're running test code outside the harness,
either call `montype -r` first or remember that your palette will be
filtered through composite mode.

## Gotchas (cgfx-side)

- **cgfx buffers output in a 256-byte per-path ring** (`cgfx/cbuffer.as`).
  In a loop that pairs a state-change call (`_cgfx_bcolor`, `_cgfx_fcolor`,
  `_cgfx_curxy`, etc.) with a `cwrite()`, pending bytes can sit unsent long
  enough that a snapshot misses them or successive state changes collide.
  Call `Flush()` after each iteration (declared in `cgfx.h`).

- **The window-API functions in `cgfx/window.c` self-flush.** Each one
  starts with `lbsr _Flush` to drain pending buffered writes, then
  emits its own command via a direct `os9 I$Write` (or `I$SetStt`) —
  bypassing the 256-byte buffer entirely. After they return, the
  buffer is empty *and* the operation is committed. So calling
  `Flush()` immediately before or after any of them is redundant:

  - `_cgfx_dwset`, `_cgfx_dwend`, `_cgfx_dwprotsw`
  - `_cgfx_owset`, `_cgfx_owend`, `_cgfx_mvowend`
  - `_cgfx_select`, `_cgfx_cwarea`

  **Exception**: `_cgfx_shadow` (in `cgfx/shadow.as`) flushes pending
  writes at entry like the others, but emits its OWSet via the
  *buffered* `_cgfx_write` (`shadow.as:38`), not direct `I$Write`.
  So the 9-byte OWSet sits in the buffer until something else
  flushes — you *do* need an explicit `Flush()` after a `_cgfx_shadow`
  call before a snapshot, or before any non-buffer-flushing op.

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

- **`_cgfx_arc` start/end offsets must span at least two axes**. The
  call signature is `(path, xrad, yrad, xo1, yo1, xo2, yo2)`; the two
  offset pairs are start/end clip lines from the center. grfdrv
  (`level2/cmds/grfdrv.asm:L18A3+`) subtracts them to compute the clip
  region width/height — pass both offsets on the same axis (e.g.
  `(28,0)` → `(-28,0)`, both `y=0`) and that region collapses to
  zero-area and the arc silently doesn't render. For a 90° top-right
  quadrant use `(xrad, 0)` → `(0, -yrad)`.

- **Overlay teardown updates bookkeeping, not the framebuffer.** On
  type-8 (and likely other graphics screens), `_cgfx_owend` and
  `_cgfx_mvowend` remove an overlay from cowin's window list cleanly,
  but the overlay's *rendered pixels* stay in the framebuffer until
  something else paints over them. Observed empirically with
  `_cgfx_shadow` — the magenta popup sticks around through both
  `owend` and `mvowend`, and even a follow-up `_cgfx_clear` on the
  parent window doesn't wipe the shadow's region. Same applies to
  `_cgfx_dwend`: closing a window removes it from the list but
  doesn't repaint where it used to be (in gfx40win the closed W2
  happens to land at the screen's border color, so it *looks* erased,
  but that's the border, not active cleanup). If a test needs the
  pixels gone, redraw the area explicitly after teardown.

## See also

- `cgfx/include/cgfx.h` — full API surface, with per-function notes.
- `cgfx/settype.c` — canonical `SetType()` helper, useful as a reference
  for type-1/2/6/8 default geometry.
- `graphictest/README.md` — how scenarios snapshot and compare these.
