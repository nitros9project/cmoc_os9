#include <string.h>

/*
* int  strspn(s1, s2)
* char *s1, *s2;

* returns the length of the initial segment of
*  s1 composed entirely of chars from s2
*/

__norts__ asm
size_t strspn(const char *s1, const char *s2)
{
	asm {
_strchr EXTERN

 pshs  x,u save U and s1
 ldx   8,s s2
 ldu   6,s s1
 pshs  x
@loop ldb   ,u+
 beq   sdone end of s1
 stb   3,s
 lbsr  _strchr
 bne   @loop
 bra   sdone
	}
}

/*
* int  strcspn(s1, s2)
* char *s1, *s2;

* returns the length of the initial segment of
*  s1 composed not of chars from s2
*/

__norts__ asm
size_t strcspn(const char *s1, const char *s2)
{
	asm {
 pshs  x,u
 ldx   8,s
 ldu   6,s
 pshs  x
@loop ldb   ,u+
 beq   sdone
 stb   3,s
 lbsr  _strchr
 beq   @loop
sdone leau  -1,u
 tfr   u,d
 subd  8,s
 leas  4,s
 puls  u,pc
	}
}
