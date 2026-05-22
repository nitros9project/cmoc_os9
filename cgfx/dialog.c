#include <cgfx.h>
#include <dialog.h>
#include <os.h>
#include <string.h>
#include <unistd.h>

#define WT_DBOX 4
#define WR_CNTNT 0

error_code _Flush(void);

static void estr(char *s, int *pos, int ch)
{
    int len = strlen(s);

    if (ch == 8)
    {
        if (*pos > 0)
            (*pos)--;
        return;
    }

    if (ch == 9)
    {
        if (*pos < len)
            (*pos)++;
        return;
    }

    if (ch == 0x18)
    {
        *pos = 0;
        return;
    }

    if (ch == 0x19)
    {
        *pos = len - 1;
        if (*pos < 0)
            *pos = 0;
        return;
    }

    if (ch == 0x10)
    {
        if (*pos < len)
            movemem(&s[*pos], &s[*pos + 1], len - *pos);
        return;
    }

    if (ch == 0x11)
    {
        if (*pos <= len)
        {
            movemem(&s[*pos + 1], &s[*pos], len - *pos + 1);
            s[*pos] = ' ';
        }
        return;
    }

    if (ch < 0x20 || ch > 0x7f)
        return;

    s[*pos] = (char) ch;
    if (*pos < len)
        (*pos)++;
}

int Dialog(int path, DIALOG *dlgptr, int column, int row, int width, int length, int fg, int bg)
{
    DIALOG *temp;
    DIALOG *temp2, *textptr;
    int ch;
    MSRET mp;
    int textpos, textnum, xcor, ycor, event;
    int n;

    _cgfx_owset(path, 1, column, row, width, length, fg, bg);
    _cgfx_curoff(path);
    _cgfx_setgc(path, GRP_PTR, PTR_ARR);
    _cgfx_scalesw(path, 0);
    _cgfx_tcharsw(path, 0);
    _cgfx_font(path, GRP_FONT, FNT_S8X8);
    _cgfx_ss_wnset(path, WT_DBOX, 0);

    textptr = 0;
    textpos = 0;

    for (n = 0, temp = dlgptr; temp->d_type != D_END; temp++, n++)
        switch (temp->d_type)
        {
        case D_TEXT:
        case D_STRING:
            _cgfx_curxy(path, temp->d_column, temp->d_row);
            cwrite(path, temp->d_string, 80);
            if (temp->d_type == D_STRING)
            {
                _cgfx_setdptr(path, temp->d_column * 8 - 2, temp->d_row * 8 - 2);
                _cgfx_rbox(path, strlen(temp->d_string) * 8 + 3, 11);
                if (!textptr)
                {
                    textptr = temp;
                    textnum = n;
                }
            }
            break;
        case D_BUTTON:
            BUp(path, temp->d_column, temp->d_row, temp->d_string, fg, bg);
            break;
        case D_RADIO:
            if (temp->d_val)
                RBDown(path, temp->d_column, temp->d_row, fg, bg);
            else
                RBUp(path, temp->d_column, temp->d_row, fg, bg);
            break;
        }

    if (textptr)
    {
        _cgfx_curon(path);
        _cgfx_curxy(path, textptr->d_column, textptr->d_row);
    }

    while (1)
    {
        _Flush();
        ch = MouseKey(path);
        event = -1;

        if (ch > 0 && textptr)
        {
            if (ch == 13)
            {
                _cgfx_curoff(path);
                if (textptr->d_val)
                {
                    _cgfx_mvowend(path);
                    return textptr->d_val;
                }
                textptr = 0;
            }
            else if (ch == 10)
            {
                for (n = textnum + 1, temp = textptr + 1; temp->d_type != D_END; n++, temp++)
                    if (temp->d_type == D_STRING)
                        break;
                if (temp->d_type == D_STRING)
                    event = n;
            }
            else if (ch == 12)
            {
                for (temp = textptr - 1, n = textnum; n >= 0; temp--, n--)
                    if (temp->d_type == D_STRING)
                        break;
                if (n >= 0)
                    event = n;
            }
            else
            {
                estr(textptr->d_string, &textpos, ch);
                _cgfx_curxy(path, textptr->d_column, textptr->d_row);
                cwrite(path, textptr->d_string, 80);
                _cgfx_curxy(path, textptr->d_column + textpos, textptr->d_row);
            }
        }
        else
        {
            if (ch < 0)
            {
                _cgfx_gs_mouse(path, &mp);
                if (mp.pt_stat != WR_CNTNT)
                    break;
                xcor = mp.pt_wrx / 8;
                ycor = mp.pt_wry / 8;
            }
            else if (ch > 0x5f)
                ch &= 0x5f;

            for (temp = dlgptr, n = 0; temp->d_type != D_END; temp++, n++)
                switch (temp->d_type)
                {
                case D_STRING:
                case D_BUTTON:
                    if (((ch < 0) && (ycor == temp->d_row) && (xcor >= temp->d_column) &&
                         (xcor < (temp->d_column + strlen(temp->d_string)))) ||
                        (ch == temp->d_key))
                        event = n;
                    break;
                case D_RADIO:
                    if (((ch < 0) && (ycor == temp->d_row) && (xcor == temp->d_column)) ||
                        (ch == temp->d_key))
                        event = n;
                    break;
                }
        }

        if (event < 0)
            continue;

        temp = &dlgptr[event];

        if (temp->d_type == D_BUTTON)
        {
            BDown(path, temp->d_column, temp->d_row, temp->d_string);
            _Flush();
            tsleep(10);
            _cgfx_mvowend(path);
            return temp->d_val;
        }
        else if (temp->d_type == D_RADIO)
        {
            if (textptr)
            {
                _cgfx_curoff(path);
                textptr = 0;
            }
            if (temp->d_string)
            {
                if (!temp->d_val)
                {
                    temp->d_val = 1;
                    for (n = 0; temp->d_string[n]; n++)
                        if ((temp2 = &dlgptr[temp->d_string[n] - 1])->d_val)
                        {
                            temp2->d_val = 0;
                            RBUp(path, temp2->d_column, temp2->d_row, fg, bg);
                        }
                    RBDown(path, temp->d_column, temp->d_row, fg, bg);
                }
            }
            else
            {
                if (temp->d_val)
                    RBUp(path, temp->d_column, temp->d_row, fg, bg);
                else
                    RBDown(path, temp->d_column, temp->d_row, fg, bg);
                temp->d_val = !temp->d_val;
            }
        }
        else if (temp->d_type == D_STRING)
        {
            _cgfx_curon(path);
            textptr = temp;
            textpos = 0;
            _cgfx_curxy(path, temp->d_column, temp->d_row);
        }
        else if (temp->d_val)
        {
            _cgfx_mvowend(path);
            return temp->d_val;
        }
    }

    return 0;
}
