#include <os.h>
#include <fcntl.h>

asm int
open(const char *path, int mode)
{
    asm
    {
* 0,s = return address
* 2,s = path
* 4,s = mode
        ldx     2,s         get path
        lda     4+1,s       get mode

        os9     I$Open
_os9err EXTERNAL
        lbcs    _os9err

        tfr     a,b
        clra
    }
}

__norts__ asm int
close(int fd)
{
    asm
    {
* 0,s = return address
* 2,s = fd
        lda     2+1,s
        os9     I$Close
_sysret EXTERNAL
        lbra    _sysret
    }
}
