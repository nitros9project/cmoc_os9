#include <os.h>

__norts__ asm error_code
_os_syscall(int callcode, registers_6809 *registers)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = call code
*	4,s = registers pointer
        pshs    y,u
        lda     2+4+1,s     get call code
        ldb     #$39        rts instruction
        pshs    d
        ldd     #$103F
        pshs    d
        ldu     8+2+2,s     get pointer to registers
        ldd     1,u
        ldx     4,u
        ldy     6,u
        ldu     8,u
        jsr     ,s          do system call
        pshs    cc,u
        ldu     8+2+2+3,s   get registers pointer
        leau    8,u
        pshu    d,dp,x,y
        puls    a,x         get CC into A, and U into X
        sta     ,-u
        stx     8,u
        leas    4,s
        puls    y,u
        bita    #1          carry set?
_osret  EXTERNAL
_oserr  EXTERNAL
        lbeq    _osret
        lbra    _oserr
	}
}

