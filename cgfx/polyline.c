#include <cgfx.h>

int PolyLine(path_id path, VERTEX *polygon)
{
    int status;
    register VERTEX *temp = polygon;

    status = _cgfx_setdptr(path, temp->p_xcor, temp->p_ycor);

    do
    {
        temp++;
        status |= _cgfx_linem(path, temp->p_xcor, temp->p_ycor);
    } while (temp->p_xcor != polygon->p_xcor || temp->p_ycor != polygon->p_ycor);

    return status;
}
