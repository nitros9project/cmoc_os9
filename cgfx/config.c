#include <cgfx.h>

asm error_code
_cgfx_pset(path_id path, int grpnum, int bufnum)
{
    asm
    {
_cwrite EXTERNAL
        ldd #$1b2e
        bra send4
    }
}

asm error_code
_cgfx_lset(path_id path, int mode)
{
    asm
    {
        ldd #$1b2f
        bra send3
    }
}

asm error_code
_cgfx_defcolr(path_id path)
{
    asm
    {
        ldd #$1b30
        pshs d,u
        leax ,s
        lda 7,s
        ldu #2
        lbsr _cwrite
        leas 2,s
        bra os9err0
    }
}

asm error_code
_cgfx_palette(path_id path, int prn, int colno)
{
    asm
    {
        ldd #$1b31
        bra send4
    }
}

asm error_code
_cgfx_fcolor(path_id path, int prn)
{
    asm
    {
        ldd #$1b32
        bra send3
    }
}

asm error_code
_cgfx_bcolor(path_id path, int prn)
{
    asm
    {
        ldd #$1b33
        bra send3
    }
}

asm error_code
_cgfx_border(path_id path, int prn)
{
    asm
    {
        ldd #$1b34
        bra send3
    }
}

asm error_code
_cgfx_scalesw(path_id path, int bsw)
{
    asm
    {
        ldd #$1b35

send3   pshs u
        leas -3,s
        std ,s
        lda 10,s
        sta 2,s
        ldu #3
        leax ,s
        lda 8,s
        lbsr _cwrite
        leas 3,s
        bra os9err0
    }
}

asm error_code
_cgfx_setgc(path_id path, int grpnum, int bufnum)
{
    asm
    {
_sysret EXTERNAL
        ldd #$1b39

send4   pshs u
        leas -4,s
        std ,s
        lda 11,s
        ldb 13,s
        std 2,s
        ldu #4
        leax ,s
        lda 9,s
        lbsr _cwrite
        leas 4,s

os9err0 puls u
		lbra	_sysret
    }
}
