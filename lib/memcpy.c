#include <unistd.h>
#include <string.h>

__norts__ asm void *
memcpy(void *dst, const void *src, size_t len)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = destination pointer
*	4,s = source pointer
*	6,s = count of bytes to copy
memcpy export
memcpy
        pshs    y,u
        ldu     2+4,s           get destination pointer in U
        ldy     4+4,s           get source pointer in Y
        ldd     6+4,s           get count
        lsra                    multiply count by 2
        rorb
        tfr     d,x             move count into X
        bcc     savecount       branch if even
        lda     ,y+             else get first byte
        sta     ,u+             and store it
savecount
        stx     -2,s            store in Y on stack
        beq     copydone
copyloop
        ldd     ,y++            get two bytes
        std     ,u++            store two bytes into destination
        leax    -1,x            decrement count
        bne     copyloop        keep going until finished
copydone
        ldd     4+2,s           get destination pointer
        puls    y,u,pc          return
    }
}
