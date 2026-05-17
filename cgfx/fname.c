#include <cgfx.h>
#include <string.h>
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

static char _FName[30];
static int files[256];
static struct sgbuf oldopts, newopts;
static char dbuf[32];

error_code _Flush(void);
long _gs_pos(path_id path);

char *FName(path_id path, const char *title, int fg, int bg)
{
    char ch;
    int dpath;
    int line, index;
    int numfiles;
    const char *s;

    _cgfx_shadow(path, 32, 14, fg, bg);
    _cgfx_curoff(path);
    _cgfx_curxy(path, (32 - strlen(title)) / 2, 1);
    write(path, title, strlen(title));
    _cgfx_curxy(path, 4, 12);
    write(path, "UP/DOWN/ENTER to select", 23);

    _cgfx_cwarea(path, 1, 3, 30, 8);

    _gs_opt(path, &oldopts);
    _gs_opt(path, &newopts);
    newopts.sg_echo = 0;
    newopts.sg_kbich = 0;
    newopts.sg_kbach = 0;
    newopts.sg_psch = 0;
    _ss_opt(path, &newopts);

    while (1)
    {
        dpath = open(".", FAM_READ | S_DIR);
        if (dpath == -1)
        {
            _cgfx_owend(path);
            _ss_opt(path, &oldopts);
            return 0;
        }

        index = 0;
        numfiles = -1;
        while (index < 256)
        {
            if (read(dpath, dbuf, 32) < 32)
            {
                numfiles = index - 1;
                break;
            }
            if (dbuf[0] != 0)
                files[index++] = (int) (_gs_pos(dpath) - 32L);
        }

        _cgfx_clear(path);

        for (line = 1; line < 8; line++)
            if (line <= (numfiles + 1))
            {
                lseek(dpath, (long) files[line - 1], 0);
                read(dpath, dbuf, 32);
                _cgfx_curxy(path, 0, line);
                strhcpy(_FName, dbuf);
                write(path, _FName, strlen(_FName));
            }

        line = 0;
        index = -1;

        while (1)
        {
            _cgfx_revon(path);
            _cgfx_curxy(path, 0, line);
            if (index < 0)
                s = "[new file]";
            else
            {
                lseek(dpath, (long) files[index], 0);
                read(dpath, dbuf, 32);
                strhcpy(_FName, dbuf);
                s = _FName;
            }
            write(path, s, strlen(s));
            read(path, &ch, 1);
            _cgfx_revoff(path);
            _cgfx_curxy(path, 0, line);
            write(path, s, strlen(s));
            _Flush();

            if (ch == 0x0a && index < numfiles)
            {
                index++;
                line++;
                if (line > 7)
                {
                    _cgfx_curhome(path);
                    _cgfx_delline(path);
                    line = 7;
                }
            }
            else if (ch == 0x0c && index > -1)
            {
                index--;
                line--;
                if (line < 0)
                {
                    _cgfx_curhome(path);
                    _cgfx_insline(path);
                    line = 0;
                }
            }
            else if (ch == 0x0d)
            {
                _ss_opt(path, &oldopts);
                close(dpath);
                if (index == -1)
                {
                    _cgfx_clear(path);
                    _cgfx_curxy(path, 1, 4);
                    write(path, "Filename?", 9);
                    _cgfx_curxy(path, 1, 5);
                    _cgfx_curon(path);
                    line = readln(path, _FName, 30);
                    if (line < 1)
                    {
                        _cgfx_owend(path);
                        return 0;
                    }
                    _FName[line - 1] = 0;
                    _ss_opt(path, &newopts);
                    _cgfx_curoff(path);
                }
                if (chdir(_FName) == -1)
                {
                    _cgfx_owend(path);
                    return _FName;
                }
                break;
            }
            else if (ch == 0x05)
            {
                _cgfx_owend(path);
                _ss_opt(path, &oldopts);
                close(dpath);
                return 0;
            }
            else
                _cgfx_bell(path);
        }
    }
}
