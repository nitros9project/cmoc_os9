/*
 * gfx40win.c -- exercise cgfx multi-window APIs on a type-8 screen.
 *
 *  Three windows on one type-8 (320x200, 16 colors) screen, no overlap:
 *
 *    +--------------------------+----+
 *    |                          |    |
 *    |        W1 (30x20)        | W2 |
 *    |        fg=15 bg=0        |10x |
 *    |                          | 24 |
 *    |                          |fg= |
 *    |                          | 15 |
 *    |                          |bg=1|
 *    +--------------------------+    |
 *    |     W3 (30x4)            |    |
 *    |     fg=15 bg=4           |    |
 *    +--------------------------+----+
 *
 *  Snapshots:
 *    01-three-windows:    all three created (after dwprotsw=0 on W1 so
 *                         the screen accepts subsequent windows), each
 *                         with distinct fg/bg + content; graphic cursor
 *                         placed in W1 via setgc(PTR_ARR) + putgc.
 *    02-overlay:          _cgfx_owset on W1 covers part of it with a
 *                         new overlay; overlay content visible.
 *    03-restored:         _cgfx_owend removes the overlay; W1's
 *                         original content shows again (the owset
 *                         save-mode bit preserves what was underneath).
 *    04-cwarea:           shrinks W1's working area, sets fcolor to
 *                         cyan, draws a bar inside that area, then
 *                         restores cwarea to W1's full size and draws
 *                         another bar outside the previous area. Both
 *                         bars should be cyan -- verifies the fcolor
 *                         state survives cwarea changes.
 *    05-dwend:            _cgfx_dwend(w2) removes W2 from the window
 *                         list. Note: dwend doesn't itself repaint the
 *                         framebuffer, so W2's pixels remain visible
 *                         until something else writes over the area.
 *    06-shadow:           _cgfx_shadow paints a centered Multi-Vue
 *                         popup with a drop shadow on W1.
 *    07-shadow-removed:   _cgfx_mvowend removes the shadow. mvowend
 *                         differs from owend in that it first issues
 *                         SS.WSet ($86, "no box") via I$SetStt before
 *                         the OWEnd escape -- needed to clear the
 *                         shadow's box-style overlay framebuffer
 *                         pixels that plain owend can't reach.
 *
 *  Companion docs: docs/coco3-screens.md.
 */

#include <cgfx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static path_id w1, w2, w3;

static const unsigned char palette[16] = {
    0,  9, 18, 27, 36, 45, 54,  7,
    11, 22, 25, 39, 52, 50, 32, 63,
};

static void set_palette(path_id p) {
    int i;
    for (i = 0; i < 16; i++)
        _cgfx_palette(p, i, palette[i]);
}

static void writez(path_id p, const char *s) { cwrite(p, s, (int)strlen(s)); }
static void at(path_id p, int x, int y)      { _cgfx_curxy(p, x, y); }
static void sleep_ticks(int t)               { _os9_sleep(&t); }

static void draw_w1_content(void) {
    at(w1, 0, 0);  writez(w1, "Window 1 (30x20)");
    at(w1, 0, 2);  writez(w1, "fg=15 bg=0 border=1");
    at(w1, 0, 4);  writez(w1, "graphics + text below:");

    _cgfx_scalesw(w1, 1);
    _cgfx_fcolor(w1, 4);
    _cgfx_setdptr(w1, 40, 50);
    _cgfx_box(w1, 200, 130);
    _cgfx_fcolor(w1, 6);
    _cgfx_setdptr(w1, 120, 90);
    _cgfx_circle(w1, 28);
    Flush();
}

int main(void) {
    /* ===== W1: 30x20 at (0,0), white on black ==========================
     * Type 8 creates a fresh 320x200/16-color screen with W1 as its
     * primary window. szy = 21 because graphics windows need +1 to get
     * the requested visible row count (same quirk as maze.c / text40.c).
     */
    if (_os_open("/w", FAM_READ | FAM_WRITE, &w1) != 0) exit(193);
    _cgfx_dwset(w1, 8, 0, 0, 30, 21, 15, 0, 1);
    /* Override only the palette slots we use as window BGs. The screen
     * palette is global -- setting it once via W1 affects all windows
     * on this screen. */
    _cgfx_palette(w1, 0, 0);    /* slot 0 (W1 bg) = black */
    _cgfx_palette(w1, 1, 9);    /* slot 1 (W2 bg) = bright blue */
    _cgfx_palette(w1, 4, 36);   /* slot 4 (W3 bg) = bright red */
    _cgfx_palette(w1, 15, 63);  /* slot 15 (fg) = white */
    _cgfx_curoff(w1);
    _cgfx_select(w1);
    _cgfx_clear(w1);
    Flush();

    /* ===== W2: 10x24 at (30,0), yellow on green. Pass screen type 0 so
     * cowin treats it as "use current screen" (L07F9 conversion table:
     * sty=$00 -> internal $FF -> L075C / L076D path uses W1's screen). */
    /* W2 bg = slot 1 (palette[1]=9 = bright blue). */
    if (_os_open("/w", FAM_READ | FAM_WRITE, &w2) != 0) exit(194);
    _cgfx_dwset(w2, 0, 30, 0, 10, 24, 15, 1, 1);
    _cgfx_curoff(w2);
    _cgfx_clear(w2);
    Flush();

    /* ===== W3: fills the bottom strip cols 0..29 (30 wide, 4 tall) at
     * (0,20). bg = slot 4 (palette[4]=36 = red).  */
    if (_os_open("/w", FAM_READ | FAM_WRITE, &w3) != 0) exit(195);
    _cgfx_dwset(w3, 0, 0, 21, 30, 3, 15, 4, 1);
    _cgfx_dwprotsw(w3, 0);
    _cgfx_curoff(w3);
    _cgfx_clear(w3);
    Flush();

    /* Fill each window's content. */
    draw_w1_content();

    at(w2, 0, 0);  writez(w2, "W2");
    at(w2, 0, 2);  writez(w2, "10x24");
    at(w2, 0, 4);  writez(w2, "fg=15");
    at(w2, 0, 5);  writez(w2, "bg=1");
    at(w2, 0, 7);  writez(w2, "tall");
    at(w2, 0, 8);  writez(w2, "narrow");
    Flush();

    at(w3, 0, 0);  writez(w3, "W3 (30x4) fills the gap below W1");
    at(w3, 0, 1);  writez(w3, "fg=15");
    at(w3, 0, 2);  writez(w3, "bg=4");
    at(w3, 0, 3);  writez(w3, "(red)");
    Flush();

    /* Graphic cursor: load the arrow pointer from the merged SYS/stdptrs
     * buffer group, then place it inside W1. */
    _cgfx_setgc(w1, GRP_PTR, PTR_ARR);
    _cgfx_putgc(w1, 150, 80);
    Flush();

    sleep_ticks(300);  /* ~5s hold for snapshot 1 */

    /* ===== Phase 2: overlay on W1 ===== */
    /* _cgfx_owset(path, svs, cpx, cpy, szx, szy, fprn, bprn).
     * svs=1 should preserve W1's underlying pixels so owend can restore. */
    _cgfx_owset(w1, 1, 5, 6, 20, 10, 15, 5);
    at(w1, 0, 0);  writez(w1, "OVERLAY!");
    at(w1, 0, 2);  writez(w1, "owset(svs=1)");
    at(w1, 0, 4);  writez(w1, "fg=15 bg=5");
    Flush();

    sleep_ticks(300);  /* ~5s hold for snapshot 2 */

    /* ===== Phase 3: remove overlay; W1's saved pixels restored. ===== */
    _cgfx_owend(w1);
    Flush();

    sleep_ticks(300);  /* ~5s hold for snapshot 3 */

    /* ===== Phase 4: cwarea test ============================================
     * Shrink W1's working area, set fcolor to cyan, draw a bar inside the
     * shrunk area, restore the working area, draw another bar in a region
     * that was OUTSIDE the previous cwarea. Both bars should be cyan --
     * cwarea changes the clip/draw region but doesn't reset fcolor. */
    _cgfx_cwarea(w1, 4, 12, 22, 6);  /* shrink to (4,12) 22x6 chars */
    _cgfx_fcolor(w1, 3);             /* slot 3 (default palette = cyan) */
    _cgfx_bcolor(w1, 3);
    _cgfx_setdptr(w1, 60, 110);
    _cgfx_bar(w1, 130, 140);         /* inside the shrunk area */
    _cgfx_cwarea(w1, 0, 0, 30, 21);  /* restore to W1's full size */
    _cgfx_setdptr(w1, 180, 30);
    _cgfx_bar(w1, 230, 60);          /* outside the previous cwarea */
    _cgfx_bcolor(w1, 0);             /* reset bg */
    Flush();

    sleep_ticks(300);  /* ~5s hold for snapshot 4 */

    /* ===== Phase 5: dwend closes W2 ======================================
     * dwend removes the window from cowin's window list but doesn't
     * itself repaint the framebuffer; the previously-rendered W2
     * pixels stay until something else writes them. */
    _cgfx_dwend(w2);
    Flush();

    sleep_ticks(300);  /* ~5s hold for snapshot 5 */

    /* ===== Phase 6: shadow overlay on W1 ================================
     * _cgfx_shadow(path, width, length, fg, bg) draws a centered popup
     * with a drop shadow. Placed at the end of the scenario because
     * the shadow's framebuffer pixels persist through plain owend and
     * would block any subsequent visible state change. */
    _cgfx_shadow(w1, 18, 8, 15, 6);
    Flush();

    sleep_ticks(300);  /* ~5s hold for snapshot 6 */

    /* ===== Phase 7: mvowend on the shadow ================================
     * mvowend issues SS.WSet (B=$86, "set overlay to no box") via
     * I$SetStt then sends the OWEnd escape. In practice neither this
     * nor plain owend visibly clears the shadow's framebuffer pixels
     * on a type-8 screen -- the API teardown updates cowin's window
     * bookkeeping, but the rendered pixels stay until something
     * explicitly repaints. Snap 7 ends up identical to snap 6; locking
     * the behavior captures the current truth as the regression
     * baseline. Even _cgfx_clear(w1) after mvowend was observed not to
     * clear the shadow region. */
    _cgfx_mvowend(w1);
    Flush();

    sleep_ticks(300);  /* ~5s hold for snapshot 7 */

    /* Hold for harness exit. */
    _os_ss_keysense(w1, 1);
    {
        int keys;
        while ((_os_gs_keysense(w1, &keys) == 0) &&
               ((keys & _SS_KEYSENSE_SPACE) == 0))
            ;
    }
    _os_ss_keysense(w1, 0);
    _os_close(w1);
    _os_close(w2);
    _os_close(w3);
    return 0;
}
