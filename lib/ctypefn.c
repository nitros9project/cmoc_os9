#include <ctype.h>

#undef isdigit
#undef isalpha
#undef isprint
#undef isspace
#undef toupper
#undef tolower

int
isdigit(int c)
{
    return _chcodes[c] & _DIGIT;
}

int
isalpha(int c)
{
    return _chcodes[c] & (_UPPER | _LOWER);
}

int
isprint(int c)
{
    return _chcodes[c] & (_PUNCT | _UPPER | _LOWER | _DIGIT);
}

int
isspace(int c)
{
    return _chcodes[c] & _WHITE;
}

int
toupper(int c)
{
    return c & 0xdf;
}

int
tolower(int c)
{
    return c | 0x20;
}
