/*
 * gfx80draw.c -- exercise cgfx drawing primitives on a type-7 window
 *   (640x200, 4 colors, 80x25 char cells). Single snapshot covering:
 *
 *     pointer:   _cgfx_setdptr / _cgfx_rsetdptr
 *     points:    _cgfx_point / _cgfx_rpoint
 *     lines:     _cgfx_line / _cgfx_rline / _cgfx_linem / _cgfx_rlinem
 *     shapes:    _cgfx_box / _cgfx_rbox / _cgfx_circle / _cgfx_ellipse
 *                _cgfx_arc
 *     fills:     _cgfx_bar / _cgfx_rbar / _cgfx_ffill
 *                _cgfx_pset (PAT_XHTC over PAT_SLD baseline)
 *     modes:     _cgfx_lset (LOG_OR / LOG_AND / LOG_XOR overlays)
 *     units:     _cgfx_scalesw(1) for raw pixel coords (640x200 mode 7
 *                native -- same as the implicit scaled coord space).
 *
 * Companion docs: docs/coco3-screens.md.
 */

#include <cgfx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static path_id outpath;

/* Type 7 has 4 palette slots. */
static const unsigned char palette[4] = {
    0,   /* 0 black   -- BG */
    9,   /* 1 blue    -- frame outlines */
    18,  /* 2 green   -- mid-tone accent */
    63,  /* 3 white   -- FG default */
};

static void writez(const char *s) { cwrite(outpath, s, (int)strlen(s)); }
static void at(int x, int y)      { _cgfx_curxy(outpath, x, y); }

/* Draw an outline-only box from (x1,y1) to (x2,y2) with current fg. */
static void frame(int x1, int y1, int x2, int y2) {
    _cgfx_setdptr(outpath, x1, y1);
    _cgfx_box(outpath, x2, y2);
}

int main(void) {
    int i;

    if (_os_open("/w", FAM_READ | FAM_WRITE, &outpath) != 0)
        exit(193);

    _cgfx_dwset(outpath, 7, 0, 0, 80, 25, 3, 0, 0);
    for (i = 0; i < 4; i++)
        _cgfx_palette(outpath, i, palette[i]);
    _cgfx_curoff(outpath);
    _cgfx_select(outpath);
    _cgfx_clear(outpath);
    _cgfx_scalesw(outpath, 1);  /* raw pixel coords */

    /* Row 0 title (text). Row 1 reserved for quadrant labels. */
    at(0, 0);
    writez("cmoc_os9 gfx80draw: mode 7 drawing primitives (640x200, 4 colors)");
    Flush();

    /* ============================================================
     * TL quadrant (x: 0..319, y: 16..103): points + lines
     * ============================================================ */
    at(0, 1); writez("TL: point/rpoint, line/rline, linem/rlinem");
    Flush();
    _cgfx_fcolor(outpath, 1);
    frame(0, 16, 319, 103);
    Flush();

    /* point grid (16 dots, white) on the left half */
    _cgfx_fcolor(outpath, 3);
    for (i = 0; i < 16; i++)
        _cgfx_point(outpath, 8 + (i % 8) * 16, 24 + (i / 8) * 16);
    Flush();

    /* rpoint chain stepping diagonally */
    _cgfx_setdptr(outpath, 16, 80);
    for (i = 0; i < 12; i++)
        _cgfx_rpoint(outpath, 10, -4);
    Flush();

    /* line / rline triangle on the right half */
    _cgfx_fcolor(outpath, 2);
    _cgfx_setdptr(outpath, 180, 30);
    _cgfx_line(outpath, 300, 30);
    _cgfx_setdptr(outpath, 180, 30);
    _cgfx_line(outpath, 240, 90);
    _cgfx_setdptr(outpath, 300, 30);
    _cgfx_line(outpath, 240, 90);
    Flush();

    /* rline zigzag */
    _cgfx_fcolor(outpath, 3);
    _cgfx_setdptr(outpath, 180, 95);
    for (i = 0; i < 6; i++)
        _cgfx_rline(outpath, 20, (i & 1) ? -4 : 4);
    Flush();

    /* linem chain (each segment advances the draw pointer) */
    _cgfx_setdptr(outpath, 180, 70);
    _cgfx_linem(outpath, 200, 60);
    _cgfx_linem(outpath, 220, 70);
    _cgfx_linem(outpath, 240, 60);
    _cgfx_linem(outpath, 260, 70);
    Flush();

    /* ============================================================
     * TR quadrant (x: 320..639, y: 16..103): shapes
     * ============================================================ */
    at(40, 1); writez("TR: box/rbox, circle, ellipse, arc");
    Flush();
    _cgfx_fcolor(outpath, 1);
    frame(320, 16, 639, 103);
    Flush();

    /* box on the left */
    _cgfx_fcolor(outpath, 2);
    _cgfx_setdptr(outpath, 340, 28);
    _cgfx_box(outpath, 410, 92);
    Flush();

    /* rbox -- relative size from the current pointer */
    _cgfx_setdptr(outpath, 425, 28);
    _cgfx_rbox(outpath, 70, 64);
    Flush();

    /* circle radius 24 at (530, 60) */
    _cgfx_fcolor(outpath, 3);
    _cgfx_setdptr(outpath, 530, 60);
    _cgfx_circle(outpath, 24);
    Flush();

    /* ellipse 36x18 at (600, 60) */
    _cgfx_setdptr(outpath, 600, 60);
    _cgfx_ellipse(outpath, 36, 18);
    Flush();

    /* arc -- 90 deg top-right quadrant of a 28-radius circle at (470, 90):
     * start vector (28, 0) = east, end vector (0, -28) = north.
     * grfdrv (level2/cmds/grfdrv.asm L18A3+) treats the two offsets as
     * the start/end clip lines from the center, so a degenerate pair on
     * the same axis can drop to zero-area and render nothing. */
    _cgfx_setdptr(outpath, 470, 90);
    _cgfx_arc(outpath, 28, 28, 28, 0, 0, -28);
    Flush();

    /* ============================================================
     * BL quadrant (x: 0..319, y: 108..199): fills
     * ============================================================ */
    at(0, 14); writez("BL: bar/rbar, ffill, pset PAT_XHTC");
    Flush();
    _cgfx_fcolor(outpath, 1);
    frame(0, 112, 319, 199);
    Flush();

    /* bar -- solid filled rect, fg is outline, bg is interior */
    _cgfx_fcolor(outpath, 3);
    _cgfx_bcolor(outpath, 2);
    _cgfx_setdptr(outpath, 10, 124);
    _cgfx_bar(outpath, 80, 172);
    Flush();

    /* rbar relative */
    _cgfx_bcolor(outpath, 1);
    _cgfx_setdptr(outpath, 90, 124);
    _cgfx_rbar(outpath, 70, 48);
    Flush();

    /* ffill: draw an outline first, then flood-fill the interior. ffill
     * uses bcolor (slot 2 here) to paint. */
    _cgfx_fcolor(outpath, 3);
    _cgfx_setdptr(outpath, 170, 124);
    _cgfx_circle(outpath, 22);
    _cgfx_bcolor(outpath, 2);
    _cgfx_setdptr(outpath, 170, 124);   /* inside the circle */
    _cgfx_ffill(outpath);
    Flush();

    /* patterned bar: switch to PAT_XHTC (crosshatch) from the 4-color
     * pattern group. */
    _cgfx_pset(outpath, GRP_PAT4, PAT_XHTC);
    _cgfx_bcolor(outpath, 2);
    _cgfx_setdptr(outpath, 220, 124);
    _cgfx_bar(outpath, 300, 172);
    _cgfx_pset(outpath, GRP_PAT4, PAT_SLD);  /* restore solid */
    Flush();
    _cgfx_bcolor(outpath, 0);

    /* ============================================================
     * BR quadrant (x: 320..639, y: 108..199): lset draw modes
     * ============================================================ */
    at(40, 14); writez("BR: lset LOG_OR / LOG_AND / LOG_XOR");
    Flush();
    _cgfx_fcolor(outpath, 1);
    frame(320, 112, 639, 199);
    Flush();

    /* Three identical green underlay bars, then overlay each with a
     * white bar in a different draw mode. */
    _cgfx_fcolor(outpath, 2);
    _cgfx_bcolor(outpath, 2);
    _cgfx_setdptr(outpath, 340, 130);
    _cgfx_bar(outpath, 420, 188);
    _cgfx_setdptr(outpath, 440, 130);
    _cgfx_bar(outpath, 520, 188);
    _cgfx_setdptr(outpath, 540, 130);
    _cgfx_bar(outpath, 620, 188);
    Flush();

    _cgfx_fcolor(outpath, 3);
    _cgfx_bcolor(outpath, 3);

    _cgfx_lset(outpath, LOG_OR);
    _cgfx_setdptr(outpath, 360, 145);
    _cgfx_bar(outpath, 410, 175);

    _cgfx_lset(outpath, LOG_AND);
    _cgfx_setdptr(outpath, 460, 145);
    _cgfx_bar(outpath, 510, 175);

    _cgfx_lset(outpath, LOG_XOR);
    _cgfx_setdptr(outpath, 560, 145);
    _cgfx_bar(outpath, 610, 175);

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
