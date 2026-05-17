#include <cgfx.h>
#include <os.h>
#include <unistd.h>

struct sgbuf {
    char sg_class, sg_case, sg_backsp, sg_delete, sg_echo, sg_alf, sg_nulls, sg_pause, sg_page;
    char sg_bspch, sg_dlnch, sg_eorch, sg_eofch, sg_rlnch, sg_dulnch, sg_psch, sg_kbich, sg_kbach;
    char sg_bsech, sg_bellch, sg_parity, sg_baud;
    int sg_d2p;
    char sg_xon, sg_xoff, sg_err;
    int sg_tbl;
    char sg_spare[3];
};

static MSRET mp;
static struct sgbuf oldopts, newopts;

int MouseKey(path_id path)
{
    char ch;

    _gs_opt(path, &oldopts);
    _gs_opt(path, &newopts);
    newopts.sg_echo = newopts.sg_kbich = newopts.sg_kbach = 0;
    _ss_opt(path, &newopts);

    while (1)
    {
        if (_gs_rdy(path) > 0)
        {
            read(path, &ch, 1);
            _ss_opt(path, &oldopts);
            return ch;
        }

        _cgfx_gs_mouse(path, &mp);
        if (!mp.pt_valid)
            continue;

        if (mp.pt_cbsa)
        {
            _ss_opt(path, &oldopts);
            tsleep(15);
            return -1;
        }
        else if (mp.pt_cctb)
        {
            _ss_opt(path, &oldopts);
            tsleep(15);
            return -2;
        }
    }
}
