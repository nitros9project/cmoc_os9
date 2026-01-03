#include <string.h>

__norts__ asm
char  *strclr(char *str, int cnt)
{
	asm {
strclr EXPORT
strclr: pshs  u
 ldu   4,s *s
 clrb
 ldx   6,s cnt
 beq   @done
@loop stb   ,u+
 leax  -1,x
 bne   @loop
@done ldd   4,s
 puls  u,pc
 	}
}
