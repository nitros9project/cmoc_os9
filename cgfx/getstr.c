#include <cgfx.h>
#include <os.h>
#include <string.h>
#include <unistd.h>

#define WT_DBOX 4

static struct sgbuf opts;

error_code _Flush(void);

int getstr(int path, char *title, char *s, int n, int column, int row, int fg, int bg)
{
    int oldecho;
    int len;

    _gs_opt(path, &opts);
    oldecho = opts.sg_echo;
    opts.sg_echo = 1;
    _ss_opt(path, &opts);
    _cgfx_owset(path, 1, column, row, strlen(title) + n + 3, 3, fg, bg);
    _cgfx_curoff(path);
    if (_cgfx_ss_wnset(path, WT_DBOX, 0))
        _cgfx_curxy(path, 1, 1);
    _cgfx_curon(path);
    _cgfx_font(path, GRP_FONT, FNT_S8X8);
    cwrite(path, title, 80);
    _Flush();
    while (_gs_rdy(path) == -1)
        tsleep(6);

    len = creadln(path, s, n);

    opts.sg_echo = oldecho;
    _ss_opt(path, &opts);
    _cgfx_mvowend(path);
    return len;
}
