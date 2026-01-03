#include <os.h>

__norts__ asm error_code
_os_modlink(char *modname, int lang, int type, void **modaddr)
{
    asm
    {
_oserr  EXTERNAL
_osret  EXTERNAL
* stack:
*	0,s = return address
*	2,s = module name pointer
*	4,s = language byte
*	6,s = type byte
*	8,s = address of pointer to module address [out]
        pshs    y,u
        ldx     4+2,s         get pointer to module name
        lda     4+4+1,s       get lang byte
        asla
        asla
        asla
        asla
        ora     4+6+1,s       OR with type byte
        os9     F$Link
L000f   tfr     u,d
        puls    y,u
        lblo    _oserr
        std     [8,s]         save off module address
        lbra    _osret
    }
}

__norts__ asm error_code
_os_modload(char *modname, int lang, int type, void **modaddr)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = module name pointer
*	4,s = language byte
*	6,s = type byte
*	8,s = address of pointer to module address [out]
        pshs    y,u
        ldx     4+2,s
        lda     4+4+1,s
        asla
        asla
        asla
        asla
        ora     4+6+1,s
        os9     F$Load
        bra     L000f
    }
}

__norts__ asm error_code
_os_modunlink(void *modaddr)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = module address
        pshs    u
        ldu     2+2,s
        os9     F$UnLink
        puls    u
        lbra    _osret
    }
}

