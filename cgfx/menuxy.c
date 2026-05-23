#include <cgfx.h>
#include <os.h>
#include <string.h>
#include <unistd.h>

static int levels = 0;
static struct sgbuf oldopts, newopts;

error_code Flush(void);

static void menu_remove(int path)
{
    while (levels > 0)
    {
        levels--;
        _cgfx_owend(path);
    }
}

int MenuXY(int path, char *title, ITEM itemptr[], int column, int row, int fg, int bg)
{
    int index, numitems;
    char ch;
    int width, offset;

    numitems = 0;
    if (levels == 0)
    {
        _gs_opt(path, &oldopts);
        _gs_opt(path, &newopts);
        newopts.sg_echo = newopts.sg_kbich = newopts.sg_kbach = newopts.sg_psch = 0;
        _ss_opt(path, &newopts);
    }

    width = strlen(title);
    while (itemptr[numitems].i_name)
    {
        index = strlen(itemptr[numitems].i_name);
        if (width < index)
            width = index;
        numitems++;
    }
    width += 2;

    if (title)
    {
        offset = 3;
        _cgfx_owset(path, 1, column, row, width, numitems + 4, fg, bg);
        _cgfx_curxy(path, (width - strlen(title)) / 2, 1);
        cwrite(path, title, 80);
    }
    else
    {
        offset = 1;
        _cgfx_owset(path, 1, column, row, width, numitems + 2, fg, bg);
    }

    levels++;
    _cgfx_curoff(path);

    for (index = 0; index < numitems; index++)
    {
        _cgfx_curxy(path, 1, index + offset);
        cwrite(path, itemptr[index].i_name, 80);
    }

    for (index = 0; !itemptr[index].i_enabled; index++)
        ;

    while (1)
    {
        _cgfx_curxy(path, 1, index + offset);
        _cgfx_revon(path);
        cwrite(path, itemptr[index].i_name, 80);

        read(path, &ch, 1);

        _cgfx_curxy(path, 1, index + offset);
        _cgfx_revoff(path);
        cwrite(path, itemptr[index].i_name, 80);
        Flush();

        if (ch == 0x0a)
        {
            do
            {
                index++;
                if (index == numitems)
                    index = 0;
            }
            while (itemptr[index].i_enabled == 0);
        }
        else if (ch == 0x0c)
        {
            do
            {
                index--;
                if (index < 0)
                    index += numitems;
            }
            while (itemptr[index].i_enabled == 0);
        }
        else if (ch == 0x0d)
        {
            if (itemptr[index].i_enabled == MN_SUBMN)
            {
                index += 1 + 16 * MenuXY(path, 0, (ITEM *) itemptr[index].i_func, column + width - 1, row + offset, bg, fg);
                return index;
            }

            menu_remove(path);
            _ss_opt(path, &oldopts);
            if (itemptr[index].i_func)
                (*itemptr[index].i_func)();
            return index + 1;
        }
        else if (ch == 0x05)
        {
            menu_remove(path);
            _ss_opt(path, &oldopts);
            return 0;
        }
        else
            _cgfx_bell(path);
    }
}
