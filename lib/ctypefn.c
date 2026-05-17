#include <ctype.h>

#undef isdigit

int
isdigit(int c)
{
    return _chcodes[c] & _DIGIT;
}
