#include <string.h>

asm __norts__ char *strncpy(char *dst, const char *src, size_t len)
{
	asm {
strncpy: pshs  y,u
 ldu   8,s src
 ldx   6,s dst
 ldy   10,s len
 beq   @done
@loop ldb   ,u+
 stb   ,x+
 leay  -1,y
 beq   @done
 tstb
 bne   @loop
@termfill clr   ,x+ terminate the string or fill dst to len
 leay  -1,y
 bne   @termfill
@done ldd   6,s dst
 puls  y,u,pc
	}
}
