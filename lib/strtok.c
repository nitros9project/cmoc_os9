#include <string.h>

/*
* char  *
* strtok(string, sepset)
* char  *string, *sepset;
*    {
*    register char  *p;
*    static   char  *save;
*/
__norts__ asm
char *strtok(char *str, const char *sep)
{
	asm {
_strspn EXTERN
_strpbrk EXTERN

 clra
 clrb
 pshs  d,u Save u, *p
*
*    if ((p = (string == NULL) ? save : string) == NULL)
*       return (NULL);                            /* no tokens remain */
 ldu   6,s *str
 bne   @strtok1
 ldu   save,y get saved ptr
 beq   @nomore if no more left
*
*    p += strspn(p, sepset);               /* skip leading seperators */
@strtok1 ldx   8,s *sepset
 pshs  x set for call
 pshs  u
 lbsr  _strspn
 leas  4,s
 leau  d,u
*
*    if (*p == '\0')
*       return (NULL);                            /* no tokens remain */
 ldb   ,u check for end of string
 beq   @nomore
 stu   ,s finally something to return
*
*    if ((save = strpbrk(p, sepset)) != NULL)  /* find next seperator */
*       *save++ = '\0';                       /* terminate this token */
 ldx   8,s
 pshs  x set for call
 pshs  u
 lbsr  _strpbrk
 leas  4,s
 std   save,y update save past end
 beq   @nomore
 tfr   d,x
 clr   ,x+
 stx   save,y
*
*    return (p);
*    %>
@nomore
 puls  d,u,pc

 endsect

 section rwdata

* Initialized Data (class G)
save fdb 0 safe string pointer
	}
}
