#include <cgfx.h>

error_code _Flush(void);

void RBUp(path_id path, int column, int row, int fg, int bg)
{
    _cgfx_fcolor(path, bg);
    _cgfx_bcolor(path, bg);
    _cgfx_setdptr(path, column * 8, row * 8);
    _cgfx_rbar(path, 7, 7);
    _cgfx_fcolor(path, fg);
    _cgfx_rsetdptr(path, 3, 2);
    _cgfx_circle(path, 3);
    _cgfx_ffill(path);
    _cgfx_rsetdptr(path, 2, 2);
    _cgfx_circle(path, 3);
    _Flush();
}

void RBDown(path_id path, int column, int row, int fg, int bg)
{
    _cgfx_fcolor(path, bg);
    _cgfx_bcolor(path, bg);
    _cgfx_setdptr(path, column * 8, row * 8);
    _cgfx_rbar(path, 7, 7);
    _cgfx_fcolor(path, fg);
    _cgfx_rsetdptr(path, 5, 4);
    _cgfx_circle(path, 3);
    _cgfx_ffill(path);
    _Flush();
}
