#include <os.h>

unsigned char G0000[4] = { 0, 0, 0, 0 };

__norts__ asm int
rand(void)
{
	asm
	{
_lmul	EXTERNAL
_ladd	EXTERNAL
        pshs  u
        leax  _G0000,y
        ldd   ,x
        ldu   2,x
        pshs  d,u
        leax  >L003d,pcr
        lbsr  _lmul
        ldd   ,x
        ldu   2,x
        pshs  d,u
        leax  >L0041,pcr
        lbsr  _ladd
        leau  _G0000,y
        ldd   ,x
        ldx   2,x
        std   ,u
        stx   2,u
        anda  #$7f
        puls  u,pc
    }
}

asm int
srand(unsigned int seed)
{
	asm
	{
        leax  _G0000,y
        ldd   2,s
        std   2,x
        clra
        clrb
        std   ,x
        rts
L003d   fcb $41
        ldb   #$4e
        fcb $6d
L0041   neg   $0000
        leax  -7,y

    }
}
