#include <string.h>

/* like normal except force upper case */

/*** strucat(s1,s2)
*    append s2 to s1 thru null on s2
*    returns s1 */
__norts__ asm
char  *strucat(char *s1, const char *s2)
{
	asm {
 pshs  u
 ldu   6,s *s2
 ldx   4,s *s1
@strucat1 ldb   ,x+
 bne   @strucat1 find end of s1
 leax  -1,x back to null
 bra   strucpy1
 	}
}

/*** strucpy(s1,s2)
*    copy s2 to s1 thru null on s2
*    returns s1 */
__norts__ asm
char  *strucpy(char *dst, const char *src)
{
	asm {
toupper EXTERNAL

 pshs  u
 ldu   6,s *src
 ldx   4,s *dst
strucpy1 ldb   ,u+
 clra
 pshs  d,x
 lbsr  toupper
 leas  2,s
 puls  x
 stb   ,x+
 bne   strucpy1
 ldd   4,s
 puls  u,pc
	}
}

