/*
 * text40.c -- exercise cgfx text-screen output on a type-1 (40x25) window.
 *
 * Demonstrates:
 *   - per-slot palette assignment (RGBrgb 6-bit color)
 *   - text attributes: normal, underlined, reverse, blinking
 *   - foreground/background palette-slot selection
 *
 * The window is cleared once, laid out top-to-bottom, then the program
 * spins on _SS_KEYSENSE_SPACE so MAME can snapshot a stable frame.
 *
 * Companion docs: docs/coco3-screens.md.
 */

#include <cgfx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static path_id outpath;

/* RGBrgb 6-bit palette. Slot 0 stays black so the unwritten window
 * background is uniform; slot 15 stays white as the default fg.
 * Other slots span a visible spread so per-slot fcolor/bcolor changes
 * are distinguishable in a 40-col snapshot.
 */
static const unsigned char palette[16] = {
    0,   /* 0  black     (BG) */
    9,   /* 1  bright blue    */
    18,  /* 2  bright green   */
    27,  /* 3  bright cyan    */
    36,  /* 4  bright red     */
    45,  /* 5  bright magenta */
    54,  /* 6  bright yellow  */
    7,   /* 7  dim lavender   */
    63,  /* 8  white     (FG default) */
    11,  /* 9  blue + dim red */
    22,  /* 10 green-ish      */
    25,  /* 11 cyan-ish       */
    39,  /* 12 red + dim blue */
    52,  /* 13 yellow-orange  */
    50,  /* 14 magenta-yellow */
    32,  /* 15 dark red       */
};

static void writez(const char *s) {
    cwrite(outpath, s, (int)strlen(s));
}

static void at(int x, int y) { _cgfx_curxy(outpath, x, y); }

int main(void) {
    int i;

    if (_os_open("/w", FAM_READ | FAM_WRITE, &outpath) != 0)
        exit(193);

    /* Type 1 = text 40x25; we use 24 rows (the standard NitrOS-9
     * usable height -- matches SetType()'s convention).
     * fg slot 8, bg slot 0, border slot 0.
     */
    /* szy = 25 (not 24): NitrOS-9 "modern screen drivers" eat the bottom
     * row -- see the matching +1 in maze.c. Asking for 24 leaves visible
     * rows 0..22 only; 25 gives the full 0..23. */
    _cgfx_dwset(outpath, 1, 0, 0, 40, 25, 8, 0, 0);
    for (i = 0; i < 16; i++)
        _cgfx_palette(outpath, i, palette[i]);
    _cgfx_curoff(outpath);
    _cgfx_select(outpath);
    _cgfx_clear(outpath);

    at(0, 0);  writez("cmoc_os9 text40 attr+color test");

    at(0, 2);  writez("Attributes:");
    at(2, 3);  writez("Normal");
    at(2, 4);  _cgfx_undlnon(outpath);  writez("Underlined");  _cgfx_undlnoff(outpath);
    at(2, 5);  _cgfx_blnkon(outpath);   writez("Blinking");    _cgfx_blnkoff(outpath);

    at(0, 8);  writez("FG palette (slots 8..15):");
    for (i = 8; i < 16; i++) {
        char line[40];
        at(2, 9 + (i - 8));
        _cgfx_fcolor(outpath, i);
        sprintf(line,"slot %2d: The quick brown fox", i);
        writez(line);
    }
    _cgfx_fcolor(outpath, 8);  /* restore */

    at(0, 18); writez("BG palette (slots 1..4):");
    for (i = 1; i <= 4; i++) {
        char line[40];
        at(2, 18 + i);
        _cgfx_bcolor(outpath, i);
        sprintf(line, "slot %2d: sample text on BG  ", i);
        writez(line);
        Flush();  /* push the state+write pair before the next iteration */
    }
    _cgfx_bcolor(outpath, 0);  /* restore */
    Flush();

    /* Hold the frame until the harness exits MAME (mirrors maze/wintest). */
    _os_ss_keysense(outpath, 1);
    {
        int keys;
        while ((_os_gs_keysense(outpath, &keys) == 0) &&
               ((keys & _SS_KEYSENSE_SPACE) == 0))
            ;
    }
    _os_ss_keysense(outpath, 0);
    _os_close(outpath);
    return 0;
}
