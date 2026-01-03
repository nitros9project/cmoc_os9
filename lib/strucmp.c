#include <string.h>

__norts__ asm
int strucmp(const char *s1, const char *s2)
{
	asm {
toupper EXTERN

 pshs  u
 ldx   4,s register char *s1
 ldu   6,s register char *s2
 bra   @compare first compare chars
@loop ldb   ,u+ was it a null?
 beq   @done
@compare ldb   ,u s2 char
 clra
 pshs  d,x
 lbsr  toupper
 leas  2,s
 ldx   ,s recover X
 std   ,s save fixed up char
 ldb   ,x+ s1 char
 clra
 pshs  d,x
 lbsr  toupper
 leas  2,s
 puls  x recover X
 subd  ,s++ see if same
 beq   @loop
@done puls  u,pc
	}
}
