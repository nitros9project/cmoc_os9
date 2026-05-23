#include <cgfx.h>
#include <stdlib.h>

OBJECT *Objects = 0;

error_code _Flush(void);

OBJECT *AddObj(int path, int group, int buffer, int xcor, int ycor, int (*border)())
{
    OBJECT *temp;

    temp = (OBJECT *) malloc(sizeof(OBJECT));
    if (temp == 0)
        return 0;

    temp->group = (char) group;
    temp->buffer = (char) buffer;
    temp->xcor = xcor;
    temp->ycor = ycor;
    temp->border = border;
    temp->deltax = 0;
    temp->deltay = 0;
    temp->xaccel = 0;
    temp->yaccel = 0;
    temp->prev = 0;
    temp->next = Objects;
    if (Objects)
        Objects->prev = temp;

    Objects = temp;
    if (group)
        _cgfx_putblk(path, group, buffer, xcor >> 5, ycor >> 5);
    else
    {
        _cgfx_fcolor(path, buffer);
        _cgfx_point(path, xcor >> 5, ycor >> 5);
    }
    _Flush();
    return temp;
}

void MoveObj(int path)
{
    OBJECT *temp;

    temp = Objects;
    while (temp)
    {
        if (temp->group)
            _cgfx_putblk(path, temp->group, temp->buffer, temp->xcor >> 5, temp->ycor >> 5);
        else
        {
            _cgfx_fcolor(path, temp->buffer);
            _cgfx_point(path, temp->xcor >> 5, temp->ycor >> 5);
        }

        if (temp->border)
        {
            if ((*temp->border)(temp))
                DelObj(-1, temp);
        }
        else
        {
            temp->xcor += temp->deltax;
            temp->ycor += temp->deltay;
            temp->deltay += temp->yaccel;
            temp->deltax += temp->xaccel;
            if (temp->xcor < 0 || temp->xcor > 20479)
            {
                temp->xcor -= temp->deltax;
                temp->deltax = -temp->deltax;
            }
            if (temp->ycor < 0 || temp->ycor > 6143)
            {
                temp->ycor -= temp->deltay;
                temp->deltay = -temp->deltay;
            }
        }

        if (temp->group)
            _cgfx_putblk(path, temp->group, temp->buffer, temp->xcor >> 5, temp->ycor >> 5);
        else
        {
            _cgfx_fcolor(path, temp->buffer);
            _cgfx_point(path, temp->xcor >> 5, temp->ycor >> 5);
        }

        temp = temp->next;
    }
    _Flush();
}

void DelObj(int path, OBJECT *objptr)
{
    if (objptr->next)
        objptr->next->prev = objptr->prev;
    if (objptr->prev)
        objptr->prev->next = objptr->next;
    else
        Objects = objptr->next;

    if (path != -1)
    {
        if (objptr->group)
            _cgfx_putblk(path, objptr->group, objptr->buffer, objptr->xcor >> 5, objptr->ycor >> 5);
        else
        {
            _cgfx_fcolor(path, objptr->buffer);
            _cgfx_point(path, objptr->xcor >> 5, objptr->ycor >> 5);
        }
        _Flush();
    }

    free(objptr);
}
