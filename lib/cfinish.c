#include <stdlib.h>
#include <os.h>

#if 0
__norts__ asm int
exit(int code)
{
    asm
    {
__dumprof EXTERNAL
_tidyup EXTERNAL

        lbsr        __dumprof
        lbsr        _tidyup
        bra         _exit
    }
}

__norts__ asm int
_exit(int code)
{
    asm
    {
        ldd         2,s
        os9         F$Exit
    }
}
#endif
