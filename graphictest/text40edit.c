/*
 * text40edit.c -- exercise cgfx cursor + line-editing APIs on a type-1
 * (40x25) text window. Two snapshots:
 *   01-cursor-moves: markers ('*' / '#') placed by curhom / currght /
 *                    curdwn / curlft / curup / crrtn against a known
 *                    row-numbered fill pattern.
 *   02-line-edits:   the same fill pattern after erline / ereoline /
 *                    ereoscrn / insline / delline.
 *
 * Between phases we _os9_sleep so the harness has a stable window for
 * each snapshot. curon/curoff are exercised for coverage only; the
 * cursor stays off across snapshots so blink phase doesn't perturb
 * pixel comparison.
 *
 * Companion docs: docs/coco3-screens.md.
 */

#include <cgfx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static path_id outpath;

static void writez(const char *s) { cwrite(outpath, s, (int)strlen(s)); }
static void at(int x, int y)      { _cgfx_curxy(outpath, x, y); }
static void sleep_ticks(int t)    { _os9_sleep(&t); }

/* Fill rows 0..22 with "NN: " + a pipe-and-dot pattern. The dotted
 * background makes any erase/insert/delete effect visually obvious. */
static void fill(void) {
    int row, col;
    char line[41];
    _cgfx_clear(outpath);
    for (row = 0; row < 23; row++) {
        sprintf(line, "%02d: ", row);
        for (col = 4; col < 40; col++)
            line[col] = (col % 5 == 0) ? '|' : '.';
        line[40] = '\0';
        at(0, row);
        cwrite(outpath, line, 40);
    }
    Flush();
}

int main(void) {
    if (_os_open("/w", FAM_READ | FAM_WRITE, &outpath) != 0)
        exit(193);

    _cgfx_dwset(outpath, 1, 0, 0, 40, 25, 8, 0, 0);
    /* Default /w palette leaves slot 0 (our BG) as white -- text on
     * white is invisible. Force BG=black, FG=white. */
    _cgfx_palette(outpath, 0, 0);
    _cgfx_palette(outpath, 8, 63);
    _cgfx_curoff(outpath);
    _cgfx_select(outpath);

    /* ===== Phase 1: cursor moves ===== */
    fill();
    _cgfx_curhom(outpath);                                /* (0,0) */
    writez("*");                                          /* mark home  */
    _cgfx_currght(outpath); _cgfx_currght(outpath);
    _cgfx_currght(outpath);                               /* (4,0) */
    writez("*");
    _cgfx_curdwn(outpath);                                /* (5,1) */
    writez("*");
    _cgfx_curlft(outpath); _cgfx_curlft(outpath);
    _cgfx_curlft(outpath); _cgfx_curlft(outpath);         /* (2,1) */
    writez("*");
    _cgfx_curup(outpath);                                 /* (3,0) */
    writez("*");
    _cgfx_crrtn(outpath);                                 /* (0, cur row) */
    writez("#");

    /* coverage-only; we re-disable so snapshot 1 has no cursor glyph */
    _cgfx_curon(outpath);
    _cgfx_curoff(outpath);

    Flush();
    sleep_ticks(300);  /* ~5s hold for snapshot 1 */

    /* ===== Phase 2: line edits ===== */
    fill();
    at(0, 4);   _cgfx_erline(outpath);     /* blank row 4 */
    at(10, 6);  _cgfx_ereoline(outpath);   /* row 6 cols 10..39 cleared */
    at(0, 10);  _cgfx_insline(outpath);    /* row 10 blank, 10..21 shift down */
    at(0, 14);  _cgfx_delline(outpath);    /* row 14 removed, 15..22 shift up */
    at(5, 20);  _cgfx_ereoscrn(outpath);   /* wipe from (5,20) to end */
    Flush();
    sleep_ticks(300);  /* ~5s hold for snapshot 2 */

    /* Hold open until the harness exits MAME. */
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
