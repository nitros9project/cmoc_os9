#include <cgfx.h>
#include <stdlib.h>

static int polysize(VERTEX *polygon)
{
    int n;
    register VERTEX *temp;

    for (n = 2, temp = polygon + 1;
         temp->p_xcor != polygon->p_xcor || temp->p_ycor != polygon->p_ycor;
         temp++, n++)
        ;

    return n;
}

void PolyBox(VERTEX *polygon, int *left, int *right, int *top, int *bottom)
{
    register VERTEX *temp = polygon + 1;

    *left = *right = polygon->p_xcor;
    *top = *bottom = polygon->p_ycor;

    while (temp->p_xcor != polygon->p_xcor || temp->p_ycor != polygon->p_ycor)
    {
        if (temp->p_xcor < *left)
            *left = temp->p_xcor;
        else if (temp->p_xcor > *right)
            *right = temp->p_xcor;

        if (temp->p_ycor < *top)
            *top = temp->p_ycor;
        else if (temp->p_ycor > *bottom)
            *bottom = temp->p_ycor;

        temp++;
    }
}

VERTEX *PolyRot(VERTEX *polygon, int cx, int cy, int angle)
{
    register VERTEX *temp, *temp2;
    int n = polysize(polygon);

    temp2 = malloc(sizeof(VERTEX) * n);
    if (temp2)
    {
        temp = temp2;
        while (n > 0)
        {
            temp->p_xcor = cx + Cosine(polygon->p_xcor - cx, angle) - Sine(polygon->p_ycor - cy, angle);
            temp->p_ycor = cy + Cosine(polygon->p_ycor - cy, angle) + Sine(polygon->p_xcor - cx, angle);
            temp++;
            polygon++;
            n--;
        }
    }

    return temp2;
}

VERTEX *PolyScal(VERTEX *polygon, int cx, int cy, int xmult, int ymult, int div)
{
    int n = polysize(polygon);
    register VERTEX *temp, *temp2;

    temp2 = malloc(sizeof(VERTEX) * n);
    if (temp2)
    {
        temp = temp2;
        while (n > 0)
        {
            temp->p_xcor = cx + (polygon->p_xcor - cx) * xmult / div;
            temp->p_ycor = cy + (polygon->p_ycor - cy) * ymult / div;
            temp++;
            polygon++;
            n--;
        }
    }

    return temp2;
}

VERTEX *PolyTran(VERTEX *polygon, int xoff, int yoff)
{
    register VERTEX *temp, *temp2;
    int n = polysize(polygon);

    temp2 = malloc(sizeof(VERTEX) * n);
    if (temp2)
    {
        temp = temp2;
        while (n > 0)
        {
            temp->p_xcor = polygon->p_xcor + xoff;
            temp->p_ycor = polygon->p_ycor + yoff;
            temp++;
            polygon++;
            n--;
        }
    }

    return temp2;
}
