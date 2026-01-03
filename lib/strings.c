#include <string.h>

/*** strcat(s1,s2)
*    append s2 to s1 thru null on s2
*    returns s1
*    stack   s2
*            s1
*           ret
*            u
*/
__norts__ asm
char  *strcat(char *s1, const char *s2)
{
	asm {
strcat EXPORT
strcat:
 pshs  u
 ldu   6,s s2
 ldx   4,s s1
 bsr   strend1
 tfr   d,x
 bra   strcpy1
	 }
}

/*** strcpy(s1,s2)
*    copy s2 to s1 thru null on s2
*    returns s1
*    stack   s2
*            s1
*           ret
*            u
*/
__norts__ asm
char  *strcpy(char *dst, const char *src)
{
	asm {
strcpy EXPORT
strcpy:
 pshs  u
 ldu   6,s src
 ldx   4,s dst
strcpy1 ldb   ,u+
 stb   ,x+
 bne   strcpy1
 ldd   4,s
 puls  u,pc
 	}
}

/*** strend(s)
*    returns pointer to null on s
*/
__norts__ asm
const char *strend(const char *str)
{
	asm {
strend EXPORT
strend:
 ldx   2,s str
strend1 ldb   ,x+
 bne   strend1
 leax  -1,x
 tfr   x,d
 rts
 	}
}
