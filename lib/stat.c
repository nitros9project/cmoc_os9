#include <fcntl.h>

__norts__ asm int
getstat(int stat, int path, void *p1, void *p2)
{
    asm
    {
		pshs    y,u 		    save off params
		lda     4+2+3,s 		get path
		ldb     4+2+1,s 		get stat code
_os9err	EXTERNAL
_sysret	EXTERNAL
		beq     L003c 		    branch if zero (SS_Opt)
		cmpb    #SS_Ready
		beq     L003e
		cmpb    #SS_Size
		beq     L0024
		cmpb    #SS_Pos
		beq     L0024
		cmpb    #SS_EOF
		beq     L003e
		cmpb    #SS_DevNm
		beq     L003c
		cmpb    #SS_FD
		beq     L0039
		ldb     #E$UnkSvc
		bra     gsbye
L0024 	os9     I$GetStt
 		bcs     gsbye
L002e 	stx     [4+2+4,s]
		ldx     4+2+4,s
		stu     2,x
		clrb
		clra
		bra     gsbye
L0039 	ldy     4+2+6,s
L003c 	ldx     4+2+4,s
L003e  	os9     I$GetStt
gsbye   puls    y,u
		lbra    _sysret
	}
}

__norts__ asm int
setstat(int stat, int param)
{
    asm
    {
        pshs  y,u
		lda   9,s
		ldb   7,s
		beq   L0096         branch if zero (SS_Opt)
		cmpb  #SS_Size
		beq   L0094
		cmpb  #SS_Reset
		beq   L0096
		cmpb  #SS_WTrk
		beq   L0091
		cmpb  #SS_Frz
		beq   L00a6
		cmpb  #SS_SPT
		beq   L0096
		cmpb  #SS_SQD
		beq   L00a6
		cmpb  #SS_DCmd
		beq   L009a
		cmpb  #SS_FD
		beq   L0096
		cmpb  #SS_Ticks
		beq   L0096
		cmpb  #SS_Lock
		beq   L0094
		cmpb  #SS_BlkRd
		beq   L0091
		cmpb  #SS_BlkWr
		beq   L0091
		cmpb  #SS_ELog
		beq   L0091
		cmpb  #SS_SSig
		beq   L0096
		cmpb  #SS_Relea
		beq   L00a6
		ldb   #E$UnkSvc
		puls  y,u
		lbra  _os9err
L0091 	ldy   14,s
L0094 	ldu   12,s
L0096 	ldx   10,s
 		bra   L00a6
L009a 	tfr   a,b
		lda   11,s
		ldx   12,s
		ldy   14,s
		ldu   16,s
L00a6 	os9 I$SetStt
 		puls  y,u
 		lbra  _sysret
 	}
}
