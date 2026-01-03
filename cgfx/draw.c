#include <cgfx.h>

asm error_code
_cgfx_setdptr(path_id path, int x, int y)
{
    asm
    {
_cwrite EXTERNAL
        ldd #$1b40
        bra send6
    }
}

asm error_code
_cgfx_rsetdptr(path_id path, int xo, int yo)
{
    asm
    {
        ldd #$1b41
        bra send6
    }
}

asm error_code
_cgfx_point(path_id path, int x, int y)
{
    asm
    {
        ldd #$1b42
        bra send6
    }
}

asm error_code
_cgfx_rpoint(path_id path, int xo, int yo)
{
    asm
    {
        ldd #$1b43
        bra send6
    }
}

asm error_code
_cgfx_line(path_id path, int x, int y)
{
    asm
    {
        ldd #$1b44
        bra send6
    }
}

asm error_code
_cgfx_rline(path_id path, int xo, int yo)
{
    asm
    {
        ldd #$1b45
        bra send6
    }
}

asm error_code
_cgfx_linem(path_id path, int x, int y)
{
    asm
    {
        ldd #$1b46
        bra send6
    }
}

asm error_code
_cgfx_rlinem(path_id path, int xo, int yo)
{
    asm
    {
        ldd #$1b47
        bra send6
    }
}

asm error_code
_cgfx_box(path_id path, int x, int y)
{
    asm
    {
        ldd #$1b48
        bra send6
    }
}

asm error_code
_cgfx_rbox(path_id path, int xo, int yo)
{
    asm
    {
        ldd #$1b49
        bra send6
    }
}

asm error_code
_cgfx_bar(path_id path, int x, int y)
{
    asm
    {
        ldd #$1b4a
        bra send6
    }
}

asm error_code
_cgfx_rbar(path_id path, int xo, int yo)
{
    asm
    {
        ldd #$1b4b
        bra send6
    }
}

asm error_code
_cgfx_ffill(path_id path)
{
    asm
    {
        ldd #$1b4f

send2   pshs u,d
        lda 7,s
        leax ,s
        ldu #2
        lbsr _cwrite
        leas 2,s
        bra os9err0
    }
}

asm error_code
_cgfx_circle(path_id path, int radius)
{
    asm
    {
        pshs u
        ldd 6,s
        pshs d
        ldd #$1b50
        pshs d
        lda 9,s
        leax ,s
        ldu #4
        lbsr _cwrite
        leas 4,s
        bra os9err0
    }
}

asm error_code
_cgfx_ellipse(path_id path, int xrad, int yrad)
{
    asm
    {
        ldd #$1b51
        bra send6
    }
}

asm error_code
_cgfx_putgc(path_id path, int x, int y)
{
    asm
    {
_sysret EXTERNAL
        ldd #$1b4e

send6   pshs u
        leas -6,s
        std ,s
        ldd 12,s
        std 2,s
        ldd 14,s
        std 4,s
        lda 11,s
        leax ,s
        ldu #6
        lbsr _cwrite
        leas 6,s

os9err0 puls u
		lbra	_sysret
    }
}

asm error_code
_cgfx_arc(path_id path, int xrad, int yrad, int xo1, int yo1, int xo2, int yo2)
{
    asm
    {
        pshs u
        leax 4,s
        ldu #$1b52
        lda 5,s
        stu ,x
        ldu #14
        lbsr _cwrite
        bra os9err0
    }
}
