#include <os.h>

__norts__ asm error_code
_os_send(int pid, int sig)
{
    asm
    {
        lda         2+1,s
        ldb         2+2+1,s
        os9         F$Send
_osret  EXTERNAL
        lbra        _osret
    }
}

__norts__ asm error_code
_os_wait(int *pid)
{
    asm
    {
        clra
        clrb
        os9         F$Wait
        lblo        _oserr
        ldx         2,s
        beq         L001b
        stb         1,x
        clr         ,x
L001b   lbra        _osret
    }
}

__norts__ asm error_code
_os_setpr(int pid, int priority)
{
    asm
    {
        lda         2+1,s
        ldb         2+2+1,s
        os9         F$SPrior
        lbra        _osret
    }
}

asm error_code
_os_chain(void *modaddr, int paramsize, void *paramaddr, int type, int lang, int datasize)
{
    asm
    {
        leau        ,s
        leas        255,y         allocate on stack
        ldx         2,u           get module address
        ldy         2+2,u         get parameter size (in pages)
        lda         2+6+1,u       get type byte
        asla                        shift over 4 bits
        asla
        asla
        asla
        ora         2+9,u         OR with language byte
        ldb         2+11,u        get size of data area (in pages)
        ldu         2+4,u         get address of parameters
        os9         F$Chain
        os9         F$Exit
    }
}

__norts__ asm error_code
_os_fork(void *modaddr, int paramsize, void *paramaddr, int type, int lang, int datasize, int *pid)
{
    asm
    {
        pshs        y,u
        ldx         4+2,s         get module address
        ldy         4+4,s         get parameter size (in pages)
        ldu         4+6,s         get address of parameters
        lda         4+8+1,s       get type byte
        asla                shift over 4 bits
        asla
        asla
        asla
        ora         4+10+1,s      OR with language byte
        ldb         4+12+1,s      get size of data area (in pages)
        os9         F$Fork        fork
        puls        y,u           recover stack
_oserr  EXTERNAL
        lblo        _oserr       branch if error
        tfr         a,b
        clra                put PID in D
        std         [14,s]        save off PID to out parameter
        lbra        _osret
    }
}
