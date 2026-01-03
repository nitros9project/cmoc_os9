#include <cgfx.h>

asm error_code
_cgfx_dfngpbuf(path_id path, int grp, int buf, int bl)
{
    asm
    {
_cwrite	EXTERNAL
		pshs u
		leas -6,s
		ldu #6
		ldd #$1b29
		std ,s
		lda 8+2+2+1,s		get group number
		ldb 8+2+2+3,s		get buffer number
		std 2,s
		ldd 8+2+2+4,s		get buffer length
		std 4,s
		lda 8+2+1,s			get path
		leax ,s
		lbsr _cwrite
		leas 6,s
		bra os9err0
	}
}

asm error_code
_cgfx_kilbuf(path_id path, int grp, int buf)
{
    asm
    {
		pshs u
		lda 2+2+3,s		get group number
		ldb 2+2+5,s		get buffer number
		pshs d
		ldd #$1b2a
		pshs d
		lda 6+2+1,s		get path
		ldu #4
		leax ,s
		lbsr _cwrite
		leas 4,s
		bra os9err0
	}
}

asm error_code
_cgfx_gpload(path_id path, int grp, int buf, int sty, int sx, int sy, int bl)
{
    asm
    {
_sysret	EXTERNAL
		pshs u
		leas -11,s
		lda 11+2+2+3,s		get group number
		ldb 11+2+2+5,s		get buffer number
		std 2,s
		lda 11+2+2+7,s		get sty
		sta 4,s
		ldd 11+2+2+8,s		get sx
		std 5,s
		ldd 11+2+2+10,s		get sy
		std 7,s
		ldd 11+2+2+12,s		get buffer length
		std 9,s
		ldd #$1b2b
		std ,s
		leax ,s
		ldu #11
		lda 16,s
		lbsr _cwrite
		leas 11,s
os9err0 puls u
		lbra	_sysret
	}
}

asm error_code
_cgfx_getblk(path_id path, int grp, int buf, int bx, int by, int sx, int sy)
{
    asm
    {
		pshs u
		leas -12,s
		lda 12+2+2+3,s		get group number
		ldb 12+2+2+5,s		get buffer number
		std 2,s
		ldd 12+2+2+6,s		get bx
		std 4,s
		ldd 12+2+2+8,s		get by
		std 6,s
		ldd 12+2+2+10,s		get sx
		std 8,s
		ldd 12+2+2+12,s		get sy
		std 10,s
		ldd #$1b2c
		std ,s
		leax ,s
		ldu #12
		lda 17,s
		lbsr _cwrite
		leas 12,s
		bra os9err0
	}
}

asm error_code
_cgfx_putblk(path_id path, int grp, int buf, int bx, int by)
{
    asm
    {
		pshs u
		leas -8,s
		lda 8+2+2+3,s		get group number
		ldb 8+2+2+5,s		get buffer number
		std 2,s
		ldd 8+2+2+6,s		get bx
		std 4,s
		ldd 8+2+2+8,s		get by
		std 6,s
		ldd #$1b2d
		std ,s
		leax ,s
		ldu #8
		lda 13,s
		lbsr _cwrite
		leas 8,s
		bra os9err0
	}
}