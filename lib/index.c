#include <string.h>

__norts__ asm
const char *strchr(const char *str, int c)
{
	asm {
_index EXPORT
_index: ldx   2,s
@strchr1 ldb   ,x+
 beq   @strchr2  if end of string
 cmpb  5,s
 bne   @strchr1 if not the same
 tfr   x,d copy pointer (past)
 bra   strrchr3
@strchr2 clra
 rts
 	}
}

__norts__ asm
const char *strrchr(const char *str, int c)
{
	asm {
_rindex EXPORT
_rindex: ldx   2,s
 ldd   #1 preset 0+1
 pshs  d
 bra   @strrchr2
@strrchr1 cmpb  7,s
 bne   @strrchr2 if not the same
 stx   ,s save pointer+1
@strrchr2 ldb   ,x+
 bne   @strrchr1 if not end
 puls  d recover pointer
strrchr3 subd  #1 adjust for post incr
 rts
	}
}
