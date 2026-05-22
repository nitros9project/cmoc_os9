/*      setbuf.c        */
#include <stdio.h>
#include "tools.h"
#include "ed.h"

void relink(LINE *a, LINE *x, LINE *y, LINE *b)
{
  x->l_prev = a;
  y->l_next = b;
}

void clrbuf(void)
{
  del(1, lastln);
}

void set_buf(void)
{
  relink(&line0, &line0, &line0, &line0);
  curln = lastln = 0;
}
