#include <cgfx.h>
#include <os.h>
#include <string.h>
#include <unistd.h>

#define WT_DBOX 4

struct sgbuf {
    char sg_class, sg_case, sg_backsp, sg_delete, sg_echo, sg_alf, sg_nulls, sg_pause, sg_page;
    char sg_bspch, sg_dlnch, sg_eorch, sg_eofch, sg_rlnch, sg_dulnch, sg_psch, sg_kbich, sg_kbach;
    char sg_bsech, sg_bellch, sg_parity, sg_baud;
    int sg_d2p;
    char sg_xon, sg_xoff, sg_err;
    int sg_tbl;
    char sg_spare[3];
};

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
