/*
 * gfx40draw.c -- exercise cgfx drawing primitives on a type-8 window
 *   (320x200, 16 colors, 40x25 char cells). Mirrors gfx80draw's
 *   coverage but on the wider-pixel / more-colorful mode 8:
 *
 *     pointer / points / lines / shapes / fills / draw modes -- same
 *       primitives as gfx80draw.c, just at 320x200 native resolution.
 *     pset:   pattern group GRP_PAT6 (the 16-color group), PAT_XHTC.
 *     scalesw:1 here -- raw mode-8 pixel coords (320x200). With
 *       scalesw=0 the same coords would be interpreted as 640x200
 *       scaled, halving the horizontal extent of every drawing op.
 *     fcolor: uses palette slots 0..15 freely (mode 8 caps at 16).
 *
 * Companion docs: docs/coco3-screens.md.
 */

#include <cgfx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static path_id outpath;

/* Type 8 has 16 palette slots. Slot 0 stays black (BG), 15 stays white
 * (default FG); the middle slots span a useful spread. */
static const unsigned char palette[16] = {
    0,   /* 0  black     -- BG */
    9,   /* 1  blue      -- frame outlines */
    18,  /* 2  green     -- mid-tone accent */
    27,  /* 3  cyan      */
    36,  /* 4  red       */
    45,  /* 5  magenta   */
    54,  /* 6  yellow    */
    7,   /* 7  lavender  */
    11,  /* 8  blue+r    */
    22,  /* 9  green-ish */
    25,  /* 10 cyan-ish  */
    39,  /* 11 red+b     */
    52,  /* 12 yellow-orange */
    50,  /* 13 magenta-yellow */
    32,  /* 14 dark red  */
    63,  /* 15 white     -- FG default */
};

static void writez(const char *s) { cwrite(outpath, s, (int)strlen(s)); }
static void at(int x, int y)      { _cgfx_curxy(outpath, x, y); }

static void frame(int x1, int y1, int x2, int y2) {
    _cgfx_setdptr(outpath, x1, y1);
    _cgfx_box(outpath, x2, y2);
}

int main(void) {
    int i;

    if (_os_open("/w", FAM_READ | FAM_WRITE, &outpath) != 0)
        exit(193);

    _cgfx_dwset(outpath, 8, 0, 0, 40, 25, 15, 0, 0);
    for (i = 0; i < 16; i++)
        _cgfx_palette(outpath, i, palette[i]);
    _cgfx_curoff(outpath);
    _cgfx_select(outpath);
    _cgfx_clear(outpath);
    _cgfx_scalesw(outpath, 1);  /* native 320x200 pixel coords */

    at(0, 0);
    writez("cmoc_os9 gfx40draw: mode 8 (320x200, 16 colors)");
    Flush();

    /* ============================================================
     * TL quadrant (x: 0..159, y: 16..103): points + lines
     * ============================================================ */
    at(0, 1); writez("TL: point/line");
    Flush();
    _cgfx_fcolor(outpath, 1);
    frame(0, 16, 159, 103);
    Flush();

    /* point grid in slot 15 (white) */
    _cgfx_fcolor(outpath, 15);
    for (i = 0; i < 12; i++)
        _cgfx_point(outpath, 6 + (i % 6) * 12, 24 + (i / 6) * 12);
    Flush();

    /* rpoint diagonal in slot 6 (yellow) */
    _cgfx_fcolor(outpath, 6);
    _cgfx_setdptr(outpath, 8, 80);
    for (i = 0; i < 10; i++)
        _cgfx_rpoint(outpath, 6, -3);
    Flush();

    /* line triangle (slot 4 red) on the right half */
    _cgfx_fcolor(outpath, 4);
    _cgfx_setdptr(outpath, 90, 26);
    _cgfx_line(outpath, 150, 26);
    _cgfx_setdptr(outpath, 90, 26);
    _cgfx_line(outpath, 120, 90);
    _cgfx_setdptr(outpath, 150, 26);
    _cgfx_line(outpath, 120, 90);
    Flush();

    /* linem zigzag (slot 2 green) */
    _cgfx_fcolor(outpath, 2);
    _cgfx_setdptr(outpath, 90, 96);
    _cgfx_linem(outpath, 100, 90);
    _cgfx_linem(outpath, 110, 96);
    _cgfx_linem(outpath, 120, 90);
    _cgfx_linem(outpath, 130, 96);
    _cgfx_linem(outpath, 140, 90);
    Flush();

    /* ============================================================
     * TR quadrant (x: 160..319, y: 16..103): shapes
     * ============================================================ */
    at(20, 1); writez("TR: shapes");
    Flush();
    _cgfx_fcolor(outpath, 1);
    frame(160, 16, 319, 103);
    Flush();

    /* box (slot 3 cyan) */
    _cgfx_fcolor(outpath, 3);
    _cgfx_setdptr(outpath, 170, 28);
    _cgfx_box(outpath, 220, 92);
    Flush();

    /* rbox (slot 5 magenta) */
    _cgfx_fcolor(outpath, 5);
    _cgfx_setdptr(outpath, 230, 28);
    _cgfx_rbox(outpath, 50, 64);
    Flush();

    /* circle (slot 15) -- at mode 8 the pixel aspect is different from
     * mode 7; this still reads as wider-than-tall due to scanline ratio. */
    _cgfx_fcolor(outpath, 15);
    _cgfx_setdptr(outpath, 295, 50);
    _cgfx_circle(outpath, 16);
    Flush();

    /* ellipse (slot 6 yellow) */
    _cgfx_fcolor(outpath, 6);
    _cgfx_setdptr(outpath, 295, 85);
    _cgfx_ellipse(outpath, 20, 10);
    Flush();

    /* arc -- 90 deg top-right quadrant. See doc note: offsets must span
     * at least two axes or grfdrv collapses the clip region to zero. */
    _cgfx_fcolor(outpath, 4);
    _cgfx_setdptr(outpath, 260, 90);
    _cgfx_arc(outpath, 18, 18, 18, 0, 0, -18);
    Flush();

    /* ============================================================
     * BL quadrant (x: 0..159, y: 112..199): fills
     * ============================================================ */
    at(0, 14); writez("BL: bar/ffill/PAT_XHTC");
    Flush();
    _cgfx_fcolor(outpath, 1);
    frame(0, 116, 159, 199);
    Flush();

    /* bar (border slot 15, fill slot 2 green) */
    _cgfx_fcolor(outpath, 15);
    _cgfx_bcolor(outpath, 2);
    _cgfx_setdptr(outpath, 6, 124);
    _cgfx_bar(outpath, 50, 168);
    Flush();

    /* rbar (border slot 6 yellow, fill slot 4 red) */
    _cgfx_fcolor(outpath, 6);
    _cgfx_bcolor(outpath, 4);
    _cgfx_setdptr(outpath, 56, 124);
    _cgfx_rbar(outpath, 44, 44);
    Flush();

    /* ffill: draw a circle outline, then flood the interior */
    _cgfx_fcolor(outpath, 15);
    _cgfx_setdptr(outpath, 130, 144);
    _cgfx_circle(outpath, 14);
    _cgfx_bcolor(outpath, 5);          /* magenta fill */
    _cgfx_setdptr(outpath, 130, 144);  /* inside the circle */
    _cgfx_ffill(outpath);
    Flush();

    /* patterned bar (PAT_XHTC from the 16-color pattern group) */
    _cgfx_pset(outpath, GRP_PAT6, PAT_XHTC);
    _cgfx_fcolor(outpath, 15);
    _cgfx_bcolor(outpath, 3);
    _cgfx_setdptr(outpath, 6, 175);
    _cgfx_bar(outpath, 100, 195);
    _cgfx_pset(outpath, GRP_PAT6, PAT_SLD);
    Flush();
    _cgfx_bcolor(outpath, 0);

    /* ============================================================
     * BR quadrant (x: 160..319, y: 112..199): lset draw modes
     * ============================================================ */
    at(20, 14); writez("BR: lset OR/AND/XOR");
    Flush();
    _cgfx_fcolor(outpath, 1);
    frame(160, 116, 319, 199);
    Flush();

    /* Three underlay bars (slot 4 red) */
    _cgfx_fcolor(outpath, 4);
    _cgfx_bcolor(outpath, 4);
    _cgfx_setdptr(outpath, 170, 128);
    _cgfx_bar(outpath, 210, 188);
    _cgfx_setdptr(outpath, 220, 128);
    _cgfx_bar(outpath, 260, 188);
    _cgfx_setdptr(outpath, 270, 128);
    _cgfx_bar(outpath, 310, 188);
    Flush();

    /* Overlay each in a different lset mode with slot 2 (green) */
    _cgfx_fcolor(outpath, 2);
    _cgfx_bcolor(outpath, 2);

    _cgfx_lset(outpath, LOG_OR);
    _cgfx_setdptr(outpath, 178, 140);
    _cgfx_bar(outpath, 202, 176);

    _cgfx_lset(outpath, LOG_AND);
    _cgfx_setdptr(outpath, 228, 140);
    _cgfx_bar(outpath, 252, 176);

    _cgfx_lset(outpath, LOG_XOR);
    _cgfx_setdptr(outpath, 278, 140);
    _cgfx_bar(outpath, 302, 176);

    _cgfx_lset(outpath, LOG_NONE);
    Flush();

    /* Hold for the harness. */
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
