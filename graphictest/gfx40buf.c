/*
 * gfx40buf.c -- exercise cgfx buffer/bitmap APIs on a type-8 screen.
 *
 *   _cgfx_dfngpbuf    define a buffer
 *   _cgfx_getblk      capture a screen region into a buffer
 *   _cgfx_putblk      paste a buffer back onto the screen
 *   _cgfx_kilbuf      free a buffer
 *
 *   Convention from cgfx/button.c: group = current process pid,
 *   buffer numbers run 1..255. Each group caps at <8K of memory.
 *
 *   _cgfx_gpload (upload raw bitmap data via I/O) is deferred -- its
 *   wire format needs more spelunking than this test deserves.
 *
 *   Mode 8 (320x200, 16 colors) is the nicest fit: enough palette
 *   slots to make captured regions distinguishable and the resolution
 *   leaves room for several paste targets.
 *
 *   Companion docs: docs/coco3-screens.md.
 */

#include <cgfx.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static path_id outpath;

static void writez(const char *s) { cwrite(outpath, s, (int)strlen(s)); }
static void at(int x, int y)      { _cgfx_curxy(outpath, x, y); }

int main(void) {
    int pid;

    if (_os_open("/w", FAM_READ | FAM_WRITE, &outpath) != 0)
        exit(193);

    _cgfx_dwset(outpath, 8, 0, 0, 40, 25, 15, 0, 1);
    /* Override the palette slots we use. The screen palette is global,
     * one set per screen. */
    _cgfx_palette(outpath, 0, 0);    /* black */
    _cgfx_palette(outpath, 1, 9);    /* bright blue */
    _cgfx_palette(outpath, 2, 18);   /* bright green */
    _cgfx_palette(outpath, 4, 36);   /* bright red */
    _cgfx_palette(outpath, 6, 54);   /* bright yellow */
    _cgfx_palette(outpath, 15, 63);  /* white */
    _cgfx_curoff(outpath);
    _cgfx_select(outpath);
    _cgfx_clear(outpath);
    _cgfx_scalesw(outpath, 1);       /* native 320x200 pixel coords */

    pid = getpid();

    at(0, 0); writez("cmoc_os9 gfx40buf: dfngpbuf/getblk/putblk/kilbuf");
    at(0, 2); writez("source  ->  getblk + putblk x4 across:");
    at(0, 12); writez("dfngpbuf 32x16 -> putblk (undefined contents):");
    at(0, 16); writez("putblk after kilbuf:");
    Flush();

    /* ============================================================
     * Source region: 32 wide x 16 tall at pixel (16, 28)
     * Red border around a green fill, with a white cross-shape inside,
     * so it's instantly recognizable when pasted elsewhere.
     * ============================================================ */
    _cgfx_fcolor(outpath, 4);  /* red border */
    _cgfx_bcolor(outpath, 2);  /* green interior */
    _cgfx_setdptr(outpath, 16, 28);
    _cgfx_bar(outpath, 47, 43);

    _cgfx_fcolor(outpath, 15); /* white cross */
    _cgfx_setdptr(outpath, 22, 35);
    _cgfx_line(outpath, 41, 35);
    _cgfx_setdptr(outpath, 31, 30);
    _cgfx_line(outpath, 31, 41);
    Flush();

    /* ============================================================
     * Capture the 32x16 source region into buffer #1 of our PID group.
     * Then paste it across the screen at four positions to verify the
     * capture+paste cycle round-trips. */
    _cgfx_getblk(outpath, pid, 1, 16, 28, 32, 16);
    Flush();

    _cgfx_putblk(outpath, pid, 1, 80, 28);
    _cgfx_putblk(outpath, pid, 1, 144, 28);
    _cgfx_putblk(outpath, pid, 1, 208, 28);
    _cgfx_putblk(outpath, pid, 1, 272, 28);
    Flush();

    /* ============================================================
     * dfngpbuf reserves a buffer (no data uploaded). putblk of it
     * shows what undefined buffer contents render as in mode 8.
     * Buffer length: 32*16 bytes / 2 (4 bits per pixel) = 256 bytes. */
    _cgfx_dfngpbuf(outpath, pid, 2, 256);
    _cgfx_putblk(outpath, pid, 2, 16, 96);
    Flush();

    /* ============================================================
     * Kill buffer #1, then attempt one more putblk(buf=1). The paste
     * after kill should be a no-op (or render whatever undefined state
     * the freed slot leaves behind). */
    _cgfx_kilbuf(outpath, pid, 1);
    _cgfx_putblk(outpath, pid, 1, 16, 130);
    Flush();

    /* Clean up buffer 2 too. */
    _cgfx_kilbuf(outpath, pid, 2);
    Flush();

    /* Hold for harness exit. */
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
