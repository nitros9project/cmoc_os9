#include <cgfx.h>

/**************************************
 * Graphic Text Functions (MW C)      *
 * Copyright (c) 1989 by Mike Sweet   *
 **************************************/

asm error_code
_cgfx_boldsw(path_id path, int bsw)
{
    asm
    {
_cwrite EXTERNAL
_sysret EXTERNAL
        ldd #$1b3d

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

os9err0 puls u
	lbra	_sysret
    }
}


asm error_code
_cgfx_tcharsw(path_id path, int sw)
{
        asm
        {
        ldd #$1b3c
        bra send3
        }
}
