#include <cgfx.h>
#include <os.h>
#include <unistd.h>

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
