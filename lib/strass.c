#include <string.h>

/* _strass(to, from, count)
* char  *to, *from;
* int   count; */
__norts__ asm
void _strass(char *to, char *from, int count)
{
	asm {
 pshs  y,u
 ldu   6,s *to
 ldy   8,s *from
 ldd   10,s count
 lsra  divide by 2
 rorb
 tfr   d,x copy byte count
 bcc   strass0 if even
 lda   ,y+ odd byte
 sta   ,u+

strass0 stx   -2,s check for zero
 beq   L001f if was 0 or 1

strass1 ldd   ,y++
 std   ,u++
 leax  -1,x
 bne   strass1
L001f puls  y,u,pc

	}
}

