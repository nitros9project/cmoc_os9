#include <string.h>

/*
 *** strnucmp(s1, s2, n)
 *    compares at most n chars
 *    ret 0 if all s2 match or n goes to 0
 *    else ret s1[i]-s2[i] where i is index at miss
 */

__norts__ asm
int strnucmp(const char *s1, const char *s2, int n)
{
	asm {
toupper EXTERN

strnucmp: pshs  y,u
 ldu   8,s 		* s2
 ldd   10,s 		* check for null count
 beq   strnucmp4 	* if really done
 bra   strnucmp2 	* get to work
strnucmp1 ldd   10,s 	* fetch n
 subd  #1
 std   10,s
 beq   strnucmp3 	* if all n match
 ldb   ,u+ 		* s2 char
 beq   strnucmp3 	* all exhausted
strnucmp2 ldb   ,u 	* s2 char
 clra
 pshs  d
 lbsr  toupper
 std   ,s
 ldx   8,s
 ldb   ,x+
 stx   8,s
 clra
 pshs  d
 lbsr  toupper
 leas  2,s
 subd  ,s++
 beq   strnucmp1 	* if match
 bra   strnucmp4
strnucmp3 clra
 clrb
strnucmp4 puls  y,u,pc
	}
}
