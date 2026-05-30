/*
 * gfx80.c -- exercise cgfx graphics-text APIs on a type-7 window:
 *   640x200, 4 colors, 80x25 char grid. Highlights the features that
 *   text screens (types 1/2) don't have:
 *
 *     - 80-column layout (vs 40-col type 1)
 *     - 6x8 font selection via _cgfx_font(GRP_FONT, FNT_S6X8)
 *     - bold via _cgfx_boldsw
 *     - proportional spacing via _cgfx_propsw
 *     - transparent character cells via _cgfx_tcharsw (lets underlying
 *       graphics show through where the cell BG would otherwise paint)
 *     - explicit border color via _cgfx_border
 *
 * Single snapshot, deterministic output.
 *
 * Companion docs: docs/coco3-screens.md.
 */

#include <cgfx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static path_id outpath;

/* Type 7 has only 4 palette slots (0..3). */
static const unsigned char palette[4] = {
    0,   /* 0 black -- BG */
    9,   /* 1 bright blue */
    18,  /* 2 bright green -- used as border */
    63,  /* 3 white -- FG default */
};

static void writez(const char *s) { cwrite(outpath, s, (int)strlen(s)); }
static void at(int x, int y)      { _cgfx_curxy(outpath, x, y); }

static const char *PANGRAM =
    "The quick brown fox jumps over the lazy dog 1234567890";

int main(void) {
    int i;

    if (_os_open("/w", FAM_READ | FAM_WRITE, &outpath) != 0)
        exit(193);

    /* Type 7 = 640x200, 4 colors, 80x25 char cells. szy=25 (the +1
     * "modern screen drivers" workaround documented in
     * docs/coco3-screens.md). FG slot 3, BG slot 0, border slot 2. */
    _cgfx_dwset(outpath, 7, 0, 0, 80, 25, 3, 0, 2);
    for (i = 0; i < 4; i++)
        _cgfx_palette(outpath, i, palette[i]);
    _cgfx_border(outpath, 2);
    _cgfx_curoff(outpath);
    _cgfx_select(outpath);
    _cgfx_clear(outpath);

    /* Row 0: title. Row 1: 80-col ruler so it's obvious the window is
     * twice as wide as text40's. */
    at(0, 0); writez("cmoc_os9 gfx80 (type 7: 640x200, 4 colors, 80x25, border=slot 2)");
    at(0, 1); writez("0........1.........2.........3.........4.........5.........6.........7.........");

    /* Rows 3..4: 8x8 vs 6x8 font. _cgfx_font must be called BEFORE the
     * row's first write or the in-flight label gets stomped by the font
     * switch sequence. */
    _cgfx_font(outpath, GRP_FONT, FNT_S8X8);
    at(0, 3); writez("FNT_S8X8: "); writez(PANGRAM);
    Flush();

    _cgfx_font(outpath, GRP_FONT, FNT_S6X8);
    at(0, 4); writez("FNT_S6X8: "); writez(PANGRAM);
    Flush();
    _cgfx_font(outpath, GRP_FONT, FNT_S8X8);  /* restore for the rest */

    /* Rows 6..7: bold off/on. */
    at(0, 6); _cgfx_boldsw(outpath, 0); writez("boldsw=0: "); writez(PANGRAM);
    Flush();
    at(0, 7); _cgfx_boldsw(outpath, 1); writez("boldsw=1: "); writez(PANGRAM);
    _cgfx_boldsw(outpath, 0);
    Flush();

    /* Rows 9..10: proportional off/on. Same text, different layout. */
    at(0, 9);  _cgfx_propsw(outpath, 0); writez("propsw=0: "); writez(PANGRAM);
    Flush();
    at(0, 10); _cgfx_propsw(outpath, 1); writez("propsw=1: "); writez(PANGRAM);
    _cgfx_propsw(outpath, 0);
    Flush();

    /* Rows 12..15: FG palette slots 1..3 (slot 0 is BG so invisible). */
    at(0, 12); writez("FG palette (slots 1..3 -- type 7 caps at 4 colors):");
    for (i = 1; i <= 3; i++) {
        char line[80];
        at(2, 12 + i);
        _cgfx_fcolor(outpath, i);
        sprintf(line, "slot %d: %s", i, PANGRAM);
        writez(line);
        Flush();
    }
    _cgfx_fcolor(outpath, 3);  /* restore */

    /* Rows 17..21: transparency. Paint rows 18..21 blue by writing spaces
     * with bcolor=1, then overlay text:
     *   row 18 -- tcharsw=0 (default): text cells paint their own BG
     *             (slot 0 = black) over the blue underlay.
     *   row 20 -- tcharsw=1: each cell's BG pixels are skipped, so the
     *             blue underlay shows through everywhere except the
     *             glyph foreground pixels.
     */
    _cgfx_fcolor(outpath, 3);
    at(0, 17); writez("Transparency (tcharsw):");
    Flush();
    _cgfx_bcolor(outpath, 1);              /* blue underlay */
    for (i = 18; i <= 21; i++) {
        at(0, i);
        writez("                                                                                ");
        Flush();
    }
    _cgfx_bcolor(outpath, 0);              /* restore window BG */
    Flush();

    _cgfx_tcharsw(outpath, 0);
    at(0, 18); writez("tcharsw=0: opaque cells (cell BG paints over the blue underlay)");
    Flush();
    _cgfx_tcharsw(outpath, 1);
    at(0, 20); writez("tcharsw=1: transparent cells (blue underlay shows through)");
    _cgfx_tcharsw(outpath, 0);
    Flush();

    /* Hold for the harness exit. */
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
