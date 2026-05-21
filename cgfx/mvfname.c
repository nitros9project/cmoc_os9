#include <cgfx.h>
#include <dialog.h>
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
static char dbuf[32];
static MSRET mp;
static struct sgbuf oldopts, newopts;

error_code _Flush(void);
long _gs_pos(path_id path);

char *MVFName(path_id path, const char *title, int column, int row, int fg, int bg)
{
    int dpath, temp;
    int line, startnum, refresh, index;
    int numfiles;
    char ch;
    char scrlsize, ypos;
    char bflag;

    _gs_opt(path, &oldopts);
    _gs_opt(path, &newopts);
    newopts.sg_echo = 0;
    newopts.sg_kbich = 0;
    newopts.sg_kbach = 0;
    _ss_opt(path, &newopts);

    _cgfx_owset(path, 1, column, row, 22, 10, fg, bg);
    cwrite(path, "\x1b\x3a\xc8\x01\x05 \x1b\x35\x00\x1bH\x00\xaf\x00\x4f\x1b@\x00\xa8\x00\x00\x1bD\x00\xa8\x00\x4f", 27);
    _cgfx_owset(path, 0, column, row, 22, 11, bg, fg);
    cwrite(path, "\x03\x1b\x3a\xc8\x03\x06\xc7\x02\x35!\xc4\x02\x35)\xc3\x02\# \x1b\x3a\xc8\x01", 22);
    cwrite(path, title, 19);
    _cgfx_owend(path);
    column++;
    row++;
    bflag = 0;

    _cgfx_setgc(path, GRP_PTR, PTR_ARR);
    _Flush();

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

        refresh = 1;
        scrlsize = 53 / (numfiles / 8 + 1);
        if (scrlsize < 4)
            scrlsize = 4;

        startnum = -1;
        line = 0;

        while (1)
        {
            if (refresh)
            {
                _cgfx_owset(path, 0, column, row, 20, 8, fg, bg);
                _cgfx_clear(path);
                _cgfx_owend(path);

                for (index = startnum; index < startnum + 8; index++)
                    if (index <= numfiles)
                    {
                        if (index == -1)
                            strcpy(_FName, "[new file]");
                        else
                        {
                            lseek(dpath, (long) files[index], 0);
                            read(dpath, dbuf, 32);
                            strhcpy(_FName, dbuf);
                        }
                        _cgfx_curxy(path, 1, index - startnum + 1);
                        if (index == (startnum + line))
                            _cgfx_revon(path);
                        else
                            _cgfx_revoff(path);
                        cwrite(path, _FName, 19);
                    }
                refresh = 0;
            }

            _cgfx_fcolor(path, bg);
            _cgfx_setdptr(path, 170, 17);
            _cgfx_bar(path, 173, 71);
            temp = 17 + (startnum + line) * (53 - scrlsize) / numfiles;
            if (temp < 17)
                temp = 17;
            _cgfx_setdptr(path, 170, temp);
            _cgfx_fcolor(path, fg);
            _cgfx_rbar(path, 3, scrlsize);

            if ((line + startnum) == -1)
                strcpy(_FName, "[new file]");
            else
            {
                lseek(dpath, (long) files[startnum + line], 0);
                read(dpath, dbuf, 32);
                strhcpy(_FName, dbuf);
            }
            _cgfx_curxy(path, 1, line + 1);
            _cgfx_revon(path);
            cwrite(path, _FName, 19);
            _cgfx_revoff(path);
            _Flush();

            do
            {
                _cgfx_gs_mouse(path, &mp);
                if ((_gs_rdy(path) == -1) && !mp.pt_cbsa)
                    bflag = 0;
            } while ((_gs_rdy(path) == -1) && !(mp.pt_cbsa ^ bflag));

            _cgfx_curxy(path, 1, line + 1);
            cwrite(path, _FName, 19);
            _Flush();

            if (_gs_rdy(path) == -1)
                ch = 0;
            else
                read(path, &ch, 1);
            mp.pt_wrx /= 8;
            ypos = mp.pt_wry / 8;

            if (!mp.pt_valid && ch == 0)
                continue;
            if (ch)
                mp.pt_wrx = ypos = -1;

            if ((((mp.pt_wrx == 21) && (ypos == 9)) || (ch == 10)) && ((line + startnum) < numfiles))
            {
                line++;
                if (line > 7)
                {
                    _cgfx_owset(path, 0, column, row, 20, 8, fg, bg);
                    _cgfx_delline(path);
                    _cgfx_owend(path);
                    line = 7;
                    startnum++;
                }
            }
            else if ((((mp.pt_wrx == 21) && (ypos == 1)) || (ch == 12)) && ((line + startnum) > -1))
            {
                line--;
                if (line < 0)
                {
                    _cgfx_owset(path, 0, column, row, 20, 8, fg, bg);
                    _cgfx_insline(path);
                    _cgfx_owend(path);
                    startnum--;
                    line = 0;
                }
            }
            else if (((ypos > 0) && (ypos < 9) && (mp.pt_wrx < 21)) || (ch == 13))
            {
                if ((ypos == (line + 1)) || (ch == 13))
                {
                    close(dpath);
                    if ((startnum + line) == -1)
                        getstr(path, "Filename? ", _FName, 16, column - 2, row + 4, fg, bg);
                    if (chdir(_FName) == -1)
                    {
                        _cgfx_owend(path);
                        _ss_opt(path, &oldopts);
                        return _FName;
                    }
                    break;
                }
                else if ((startnum + ypos - 1) <= numfiles)
                {
                    line = ypos - 1;
                    bflag = 1;
                }
            }
            else if (((mp.pt_wrx == 1) && (ypos == 0)) || ch == 5)
            {
                _cgfx_owend(path);
                _ss_opt(path, &oldopts);
                close(dpath);
                return 0;
            }
            else if ((mp.pt_wrx == 21) && (ypos > 1) && (ypos < 9))
            {
                temp = startnum;
                startnum = (mp.pt_wry - 16) * numfiles / 56;
                if (temp != startnum)
                    refresh = 1;
            }
        }
    }
}
