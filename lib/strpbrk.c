#include <string.h>

/*
* function to check a string for one of a set of chars
*  char *strpbrk(s1, s2)
*        char *s1, s2;        s1 = string, s2 = char set
*/
__norts__ asm
const char *strpbrk(const char *s1, const char *s2)
{
	asm {
_index EXTERN

 pshs  x,u
 ldx   8,s pointer to s2
 ldu   6,s pointer to s1
 pshs  x
@next clra in case set is null
 ldb   ,u+ get a char from string
 beq   @done if end of string
 stb   3,s
 lbsr  _index
 beq   @next not in string, continue
 leau  -1,u fix overshoot
 tfr   u,d return string ptr
@done leas  4,s
 puls  u,pc

	}
}
