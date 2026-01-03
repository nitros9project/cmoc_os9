#include <fcntl.h>
#include <unistd.h>
#include <os.h>

__norts__ asm int
access(const char *pathname, int mode)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = pathname pointer
*	4,s = mode
        ldx     2,s
        lda     4+1,s

        os9     I$Open

        bcs     access10
        os9     I$Close
access10
_sysret EXTERNAL
        lbra    _sysret
    }
}

__norts__ asm int
mknod(const char *pathname, int mode)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = pathname pointer
*	4,s = mode
        ldx     2,s
        ldb     4+1,s
        os9     I$MakDir
        lbra    _sysret
    }
}

__norts__ asm int
unlinkx(const char *pathname, int mode)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = pathname pointer
*	4,s = mode
        lda     4+1,s           get mode
        ldx     2,s             get pathname
        bra     unlink2
    }
}

__norts__ asm int
unlink(const char *pathname)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = pathname pointer
        ldx     2,s             get pathname
        lda     #FAM_WRITE      write permission
unlink2
        os9     I$DeletX
        lbra    _sysret
    }
}

asm int
dup(int fd)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = file descriptor
        lda     2+1,s
        os9     I$Dup
_os9err EXTERNAL
        lbcs    _os9err
        tfr     a,b
        clra
    }
}
