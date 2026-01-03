#include <fcntl.h>

__norts__ asm int
abs(int v)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = value
        ldd         2,s
        bpl         absex
        nega
        negb
        sbca        #0
absex   rts
    }
}
