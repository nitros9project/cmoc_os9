#include <unistd.h>
#include <string.h>

/*
 * Copy s2 to s1, stopping if character c is copied.
 * Copy no more than n bytes.
 * Return a pointer to the byte after character c in the copy,
 * or NULL if c is not found in the first n bytes.
 *
 *
 * char *
 * memccpy(s1, s2, c, n)
 * register char *s1, *s2;
 * int           c, n;
 *    {
 *    while (n-- > 0)
 *       if ((*s1++ = *s2++) == c)
 *          return (s1);
 *    return (0);
 *    }
 */
__norts__ asm void *
memccpy(char *s1, char *s2, int c, int n)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = destination address
*	4,s = source address
*	6,s = character to stop at
*	8,s = maximum bytes to copy
        pshs        y,u
        ldu         4+4,s               get source address in U
        ldx         4+2,s               get destination address in X
        ldy         4+8,s               get maximum bytes to copy in Y
        beq         anull               handle NULL case
copylp  lda         ,u+                 get byte from source
        sta         ,x+                 store in destination
        cmpa        4+6+1,s             is this character the one to stop?
        bne         noteq               branch if not
        tfr         u,d                 else copy updated source to D
        bra         ex                  exit
noteq   leay        -1,y                back up one
        bne         copylp
anull   tfr         y,d                 return NULL
ex      puls        y,u,pc              restore and exit
    }
}
