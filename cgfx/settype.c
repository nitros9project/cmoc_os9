#include <cgfx.h>

error_code _Flush(void);

void SetType(path_id path, int stype, int fg, int bg)
{
    int oldtype;

    _cgfx_gs_styp(path, &oldtype);

    if (oldtype != stype)
    {
        _cgfx_dwend(path);
        if (stype == 1 || stype == 6 || stype == 8)
            _cgfx_dwset(path, stype, 0, 0, 40, 24, fg, bg, bg);
        else
            _cgfx_dwset(path, stype, 0, 0, 80, 24, fg, bg, bg);
        _cgfx_select(path);
    }
    _cgfx_fcolor(path, fg);
    _cgfx_bcolor(path, bg);
    _cgfx_border(path, bg);
    _cgfx_clear(path);
    _Flush();
}
