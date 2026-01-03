#include <string.h>

/*** strhcpy(t, f)
*    copy parity terminated string
*    return s1 */
__norts__ asm
char  *strhcpy(char *dst, const char *src)
{
	asm {
strhcpy EXPORT
strhcpy:
 pshs  u
 ldu   4,s *dst
 ldx   6,s *src
@loop ldb   ,x+
 stb   ,u+
 bpl   @loop
 andb  #$7f
 stb   -1,u patch up
 clr   ,u terminate
 ldd   4,s
 puls  u,pc
	}
}

