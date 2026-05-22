#include <cgfx.h>
#include <stdlib.h>

#define MAXLINES 192

typedef struct {
    short p_numedges;
    short *p_edges;
} EDGE;

static EDGE edges[MAXLINES];

static int addpt(int x, int y)
{
    int n, n2;
    register short *temp;

    if (x < 0 || x > 639 || y < 0 || y > 191)
        return 0;

    if (edges[y].p_numedges == 0)
    {
        edges[y].p_edges = (short *) malloc(sizeof(short));
        if (edges[y].p_edges)
        {
            *(edges[y].p_edges) = x;
            edges[y].p_numedges = 1;
            return 0;
        }
        return -1;
    }

    temp = (short *) realloc(edges[y].p_edges, sizeof(short) * (edges[y].p_numedges + 1));
    if (temp)
    {
        edges[y].p_edges = temp;
        for (n = 0; n < edges[y].p_numedges; n++, temp++)
            if (x < *temp)
                break;
        movemem(edges[y].p_edges + n + 1, edges[y].p_edges + n, (edges[y].p_numedges - n) * 2);
        edges[y].p_numedges++;
        *temp = x;
        return 0;
    }

    return -1;
}

int PolyFill(path_id path, VERTEX *polygon)
{
    register VERTEX *temp;
    int xcor, ycor;
    int dx, dy;
    int incx, incy, lastincy;
    int halfx, halfy;
    int errterm;
    int status = 0;
    int n, n2;

    for (n = 0; n < MAXLINES; n++)
        edges[n].p_numedges = 0;

    temp = polygon + 1;
    while (temp->p_xcor != polygon->p_xcor || temp->p_ycor != polygon->p_ycor)
        temp++;

    if (((temp - 1)->p_ycor - temp->p_ycor) < 0)
        lastincy = 1;
    else if (((temp - 1)->p_ycor - temp->p_ycor) > 0)
        lastincy = -1;
    else
        lastincy = 0;

    temp = polygon;

    do
    {
        xcor = temp->p_xcor;
        ycor = temp->p_ycor;
        temp++;

        if ((dx = xcor - temp->p_xcor) < 0)
        {
            incx = 1;
            dx = -dx;
        }
        else
            incx = -1;

        if ((dy = ycor - temp->p_ycor) < 0)
        {
            incy = 1;
            dy = -dy;
        }
        else if (dy > 0)
            incy = -1;
        else
            incy = 0;

        halfx = dx / 2;
        halfy = dy / 2;
        errterm = 0;

        if (incy * lastincy < 0)
            addpt(xcor, ycor);

        if (dy == 0)
        {
            if (lastincy * ((temp + 1)->p_ycor - temp->p_ycor) < 0)
                addpt(xcor, ycor);
        }
        else if (dx > dy)
        {
            dx = dx * incx;
            while (xcor != temp->p_xcor)
            {
                if ((status = addpt(xcor, ycor)) != 0)
                    break;
                xcor += (dx + errterm) / dy;
                errterm = (dx + errterm) % dy;
                ycor += incy;
            }
        }
        else
        {
            n = dy;
            while (n > 0)
            {
                if ((status = addpt(xcor, ycor)) != 0)
                    break;
                errterm += dx;
                if (errterm >= halfy)
                {
                    errterm -= dy;
                    xcor += incx;
                }
                ycor += incy;
                n--;
            }
        }
        lastincy = incy;
    } while (temp->p_xcor != polygon->p_xcor || temp->p_ycor != polygon->p_ycor);

    if (status)
    {
        for (n = 0; n < MAXLINES; n++)
            if (edges[n].p_numedges)
                free(edges[n].p_edges);
        return -1;
    }

    for (n = 0; n < MAXLINES; n++)
    {
        register short *temp2;
        if (edges[n].p_numedges)
        {
            for (n2 = edges[n].p_numedges - 1, temp2 = edges[n].p_edges; n2 > 0; n2 -= 2, temp2 += 2)
            {
                status |= _cgfx_setdptr(path, *temp2, n);
                status |= _cgfx_line(path, *(temp2 + 1), n);
            }
            free(edges[n].p_edges);
        }
    }

    return status;
}
