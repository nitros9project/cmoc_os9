#include <cmoc.h>
#include <coco.h>

#define I$ReadLn            0x8B

/* This is a Mame Emulator break */
#define BREAK asm{ fdb $113e }

/* Long Pring heX */
void LPX(long l)
{
       	/* cmoc seems confused with this:
	unsigned int *p;
        p=(unsigned int *)&l;
	printf("%x", *p);
	printf(":%x\n", *(p+1));
	*/

	// Use int vars to save high and low words of long
	unsigned int *p, lh,ll;
        p=(unsigned int *)&l;
        lh = *p;
        ll = *(p+1);
        printf("%x",lh);
        printf(":%x",ll);
        printf("L\n");
}

void PAUSE()
{
	printf("Press Enter to continue...\n");
	// I$ReadLn to puase
	asm {
		pshs y
		lda #0       stdin
		ldy  #5      buf len
		leas -5,s    buf
		leax ,s
		* fdb $113e
		os9 I$ReadLn read line
		* fdb $113e
		leas 5,s     clean up buf
		puls y
	}
}


/* Debugging aid: Print useful cpu regs and wait for Enter */
asm __norts__ void DEBUG(void)
{
	asm {
_printf EXTERNAL
_PAUSE  EXTERNAL

* lower addresses
*       +-------------------------------+ <- S
*       |              A                |
*       +-------------------------------+ <- 1,S
*       |              B                |
*       +-------------------------------+ <- 2,S
*       |                               |
*       +-             X               -+
*       |                               |
*       +-------------------------------+ <- 4,S
*       |                               |
*       +-             Y               -+
*       |                               |
*       +-------------------------------+ <- 6,S
*       |                               |
*       +-         s_caller            -+
*       |                               |
*  S -> +-------------------------------+ <- 8,S
*       |                               |
*       +-             U               -+
*       |                               |
* 2,S-> +-------------------------------+ <- 10,S
*       |                               |
*       +-           *rts              -+
*       |                               |
* 4,S-> +-------------------------------+ <- 12,S
* higher addresses */

 pshs u          save u
 leau 4,s        get s_caller
 pshs u,y,x,b,a  save s_caller,y,x,b,a
 leau format,pcr printf format string
 pshs u
 lbsr _printf
 lbsr _PAUSE
 leas 2,s       dump format string param
 puls a,b,x,y restore a,b,x,y
 leas 2,s       dump s_caller
 puls u         restore u
 rts

 section rodata

format
 fcc /D=%x X=%x Y=%x S=%x U=%x PC=%x/
 fcb $0A,$0

 endsection

 section code
	}
}
