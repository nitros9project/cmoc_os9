#include <unistd.h>
#include <os.h>

__norts__ asm int
write(int fd, const char *buf, int count)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = fd
*	4,s = buffer pointer
*	6,s = write count
        pshs    y             save data pointer
        ldy     2+6,s         get count
        beq     write10       branch if nothing to do
        lda     2+2+1,s       get fd
        ldx     2+2+2,s       get buffer address

        os9     I$Write

write1  bcc     write10
        puls    y
_os9err EXTERNAL
        lbra    _os9err

write10 tfr     y,d
        puls    y,pc
    }
}

__norts__ asm int
writeln(int fd, const char *buf, int count)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = fd
*	4,s = buffer pointer
*	6,s = write count
        pshs    y               save data pointer
        ldy     2+6,s           get count
        beq     write10
        lda     2+2+1,s         get fd
        ldx     2+4,s           get buffer address

        os9     I$WritLn        call os9
        bra     write1
    }
}
