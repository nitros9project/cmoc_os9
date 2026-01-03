#include <unistd.h>
#include <string.h>

__norts__ asm void *
memchr(void *data, int c, size_t len)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = data pointer
*	4,s = byte to locate
*	6,s = number of bytes to search
        pshs        x,u
        ldu         4+2,s           get data pointer
        ldx         4+6,s           get number of bytes to search
        beq         donothing
searchloop
        lda         ,u+             get next byte from data pointer
        cmpa        4+4+1,s         same as byte we want?
        bne         notsame         branch if not
        leau        -1,u            else found, back up one
        tfr         u,d             put pointer in D
        bra         bye
notsame
        leax        -1,x            decrement pointer
        bne         searchloop      continue if not zero
donothing
        clra
        clrb
bye
        puls        x,u,pc
    }
}
