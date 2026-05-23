#include <cgfx.h>
#include <string.h>
#include <unistd.h>

error_code Flush(void);

void BUp(path_id path, int column, int row, const char *s, int fg, int bg)
{
    int x = column * 8 - 1;
    int y = row * 8 - 2;
    int len = strlen(s);

    _cgfx_fcolor(path, bg);
    _cgfx_setdptr(path, x - 1, y - 1);
    _cgfx_rbar(path, len * 8 + 4, 15);
    _cgfx_fcolor(path, fg);
    _cgfx_bcolor(path, bg);

    _cgfx_curxy(path, column, row);
    cwrite(path, s, 80);

    _cgfx_setdptr(path, x, y);
    _cgfx_rbox(path, strlen(s) * 8 + 1, 10);
    _cgfx_setdptr(path, x + strlen(s) * 8 + 1, y);
    _cgfx_rlinem(path, 2, 2);
    _cgfx_rlinem(path, 0, 10);
    _cgfx_rline(path, -2, -2);
    _cgfx_linem(path, x + 3, y + 12);
    _cgfx_rlinem(path, -2, -2);
    Flush();
}

void BDown(path_id path, int column, int row, const char *s)
{
    int x = column * 8 - 2;
    int y = row * 8 - 3;
    int pid = getpid();

    _cgfx_getblk(path, pid, 255, x, y, strlen(s) * 8 + 3, 12);
    _cgfx_putblk(path, pid, 255, x + 1, y + 1);
    _cgfx_kilbuf(path, pid, 255);
    Flush();
}
