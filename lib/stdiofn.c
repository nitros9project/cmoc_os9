#include <stdio.h>

#undef feof
#undef fileno

int feof(FILE *fp)
{
    return fp->_flag & _EOF;
}

int fileno(FILE *fp)
{
    return fp->_fd;
}
