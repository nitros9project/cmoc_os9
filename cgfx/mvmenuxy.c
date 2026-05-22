#include <cgfx.h>
#include <menu.h>
#include <os.h>
#include <string.h>
#include <unistd.h>

#define WT_SBOX 3

static int levels = 0;
static MSRET mp;
static struct sgbuf oldopts, newopts;

error_code _Flush(void);

static void mvmenu_remove(int path)
{
    while (levels > 0)
    {
        _cgfx_mvowend(path);
        levels--;
    }
}

int MVMenuXY(int path, char *title, ITEM itemptr[], int column, int row, int fg, int bg)
{
    int index, numitems;
    int width, newindex, offset;
    char ch, onwindow;

    if (levels == 0)
    {
        _gs_opt(path, &oldopts);
        _gs_opt(path, &newopts);
        newopts.sg_echo = newopts.sg_kbach = newopts.sg_kbich = newopts.sg_psch = 0;
        _ss_opt(path, &newopts);
    }

    numitems = 0;
    width = strlen(title);
    while (itemptr[numitems].i_name)
    {
        index = strlen(itemptr[numitems].i_name);
        if (width < index)
            width = index;
        numitems++;
    }

    if (title)
    {
        offset = 2;
        _cgfx_owset(path, 1, column, row, width + 3, numitems + 4, fg, bg);
        _cgfx_curoff(path);
        _cgfx_ss_wnset(path, WT_SBOX, 0);
        _cgfx_font(path, GRP_FONT, FNT_S8X8);
        _cgfx_curxy(path, (width - strlen(title)) / 2, 0);
        cwrite(path, title, 80);
    }
    else
    {
        offset = 0;
        _cgfx_owset(path, 1, column, row, width + 3, numitems + 2, fg, bg);
        _cgfx_curoff(path);
        _cgfx_ss_wnset(path, WT_SBOX, 0);
        _cgfx_font(path, GRP_FONT, FNT_S8X8);
    }

    levels++;

    for (index = 0; index < numitems; index++)
    {
        _cgfx_curxy(path, 0, index + offset);
        _cgfx_boldsw(path, itemptr[index].i_enabled);
        cwrite(path, itemptr[index].i_name, 80);
    }

    for (index = 0; !itemptr[index].i_enabled; index++)
        ;

    _cgfx_boldsw(path, 1);
    _cgfx_curxy(path, 0, index + offset);
    _cgfx_revon(path);
    cwrite(path, itemptr[index].i_name, 80);
    _Flush();

    onwindow = 0;
    while (1)
    {
        _cgfx_gs_mouse(path, &mp);

        if (_gs_rdy(path) != -1)
            read(path, &ch, 1);
        else
            ch = 0;

        if ((mp.pt_stat == WR_OFWIN) && (ch == 0))
        {
            if (!onwindow)
                continue;

            mvmenu_remove(path);
            _ss_opt(path, &oldopts);
            return 0;
        }

        if ((onwindow = (mp.pt_stat != WR_OFWIN)) != 0)
            newindex = mp.pt_wry / 8 - offset;
        else
            newindex = index;

        if (newindex < 0 || !itemptr[newindex].i_enabled)
            newindex = index;

        if (ch == 10)
        {
            newindex = index;
            do
            {
                newindex++;
                if (newindex >= numitems)
                    newindex = 0;
            }
            while (!itemptr[newindex].i_enabled);
        }
        else if (ch == 12)
        {
            newindex = index;
            do
            {
                newindex--;
                if (newindex < 0)
                    newindex = numitems - 1;
            }
            while (!itemptr[newindex].i_enabled);
        }

        if (index != newindex)
        {
            _cgfx_curxy(path, 0, index + offset);
            _cgfx_revoff(path);
            cwrite(path, itemptr[index].i_name, 80);
            index = newindex;
            _cgfx_curxy(path, 0, index + offset);
            _cgfx_revon(path);
            cwrite(path, itemptr[index].i_name, 80);
            _Flush();
        }

        if (mp.pt_cbsa || (ch == 13))
        {
            if (itemptr[index].i_enabled == MN_SUBMN)
            {
                index += 1 + 16 * MVMenuXY(path, 0, (ITEM *) itemptr[index].i_func, column + width - 1, row + index + offset + 1, fg, bg);
                return index;
            }

            mvmenu_remove(path);
            _ss_opt(path, &oldopts);
            if (itemptr[index].i_func)
                (*itemptr[index].i_func)();
            return index + 1;
        }

        if (ch == 5)
        {
            mvmenu_remove(path);
            _ss_opt(path, &oldopts);
            return 0;
        }

        tsleep(1);
    }
}
