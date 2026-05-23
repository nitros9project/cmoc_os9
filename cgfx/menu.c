#include <string.h>
#include <cgfx.h>

int Menu(int path, char *title, ITEM itemptr[], int fg, int bg)
{
    int length, width, temp;
    int maxwidth;
    int index;

    _cgfx_gs_scsz(path, &width, &length);

    index = 0;
    maxwidth = strlen(title);

    while (itemptr[index].i_name)
    {
        temp = strlen(itemptr[index].i_name);
        if (temp > maxwidth)
            maxwidth = temp;
        index++;
    }

    return MenuXY(path, title, itemptr, (width - maxwidth - 2) / 2, (length - index - 4) / 2, fg, bg);
}
