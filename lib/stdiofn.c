#include <stdio.h>

#undef feof
#undef fileno
#undef putchar

int feof(FILE *fp)
{
    return fp->_flag & _EOF;
}

int fileno(FILE *fp)
{
    return fp->_fd;
}

int putchar(int c)
{
    return putc(c, stdout);
}
