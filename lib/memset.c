#include <stdlib.h>
#include <sys/types.h>
#include <string.h>

__norts__ asm void *
memset(void *dst, int src, size_t len)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = destination pointer
*	4,s = source byte
*	6,s = count of bytes to copy
memset:
    pshs  u
    ldu   2+2,s         get destination pointer
    ldx   2+6,s         get number of bytes to copy
    beq   leave         if zero, leave
    ldb   4+2+1,s       get source byte
setloop
    stb   ,u+
    leax  -1,x
    bne   setloop
leave
    ldd   2+2,s         get destination pointer
    puls  u,pc
    }
}
