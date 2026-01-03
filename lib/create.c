#include <os.h>
#include <fcntl.h>

__norts__ asm int
creat(const char *path, int mode)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = pathname pointer
*	4,s = mode
pmode   equ         FAP_READ|FAP_WRITE|FAP_PREAD    r/w for owner, r for others

        pshs        u
        ldx         2+2,s           get pathname pointer
        lda         2+4+1,s         get mode
        tfr         a,b             work in B
        andb        #FAP_PEXEC|FAP_EXEC     preserve any exec bits
        orb         #pmode          OR in default modes
        os9         I$Create
        bcc         crret
        cmpb        #E$CEF          already there?
        bne         errout          no - cannot cope

        lda         2+4+1,s         get mode
        bita        #FAP_DIR        trying to create a directory?
        bne         errout          yes, forget it

        anda        #7              access mode bits
        ldx         2+2,s           get the name again
        os9         I$Open          try to open it
        bcs         errout

        pshs        a,u
        ldx         #0
        leau        ,x
        ldb         #SS_Size
        os9         I$SetStt        set the file size to zero
        puls        a,u
        bcc         crret

        pshs        b
        os9         I$Close
        puls        b
errout  leas        2,s
_os9err EXTERNAL
        lbra        _os9err
    }
}


__norts__ asm int
create(const char *path, int mode, int perm)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = pathname pointer
*	4,s = mode
*	6,s = permissions
        pshs        u
        ldx         2+2,s           get pathname pointer
        lda         2+4+1,s         get mode
        ldb         2+6+1,s         get permissions
        os9         I$Create
        bcs         errout
        bra         crret

creat10 cmpb        #E$CEF          already there?
        bne         errout          no - cannot cope
        ldx         2+2,s           get pathname pointer
        os9         I$Delete
        bcs         errout          cannot cope
        puls        u
        bra         _ocreat
    }
}

asm int
ocreat(const char *path, int mode, int perm)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = pathname pointer
*	4,s = mode
*   6,s = permissions
        pshs        u
        ldx         2+2,s           get pathname pointer
        lda         2+4+1,s         get mode
        ldb         2+6+1,s         get permissions
        os9         I$Create
        bcs         creat10
crret   leas        2,s
        tfr         a,b
        clra
    }
}
