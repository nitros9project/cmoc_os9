/*
 *  printf(format, expr1, expr2, .... exprn)
 *  fprintf(stream, format, expr1, expr2, .... exprn)
 *  sprintf(buffer, format, expr1, expr2, .... exprn)
 *
 * 12-05-2005 tjl Fixed a bug where sprintf( s, "" ) would
 *                not put a null in the string s.
*/
#include <stdio.h>
#include <os.h>

FILE *fpmp;
char buf1[10];
int dectbl[4]= {10000,1000,100,10};

__norts__ asm int
printf(const char *fmt, ...)
{
    asm
    {
_chcodes	EXTERNAL
_putc		EXTERNAL
_pflong		EXTERNAL
_pffloat	EXTERNAL
_strlen		EXTERNAL
__iob		EXTERNAL

* stack:
*	0,s = return address
*	2,s = format string
*	4,s = pointer to param
			pshs  u
			leau  2+4,s                     point U to parameters referenced by format string
			leax  __iob+13,y                get pointer to stdout FILE structure
			ldd   2+2,s			            get format string
			bra   printf1
	}
}

__norts__ asm int
fprintf(FILE *fp, const char *fmt, ...)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = FILE pointer
*	4,s = format string
*	6,s = pointer to param
			pshs  u
			leau  2+6,s                     point U to parameters referenced by format string
			ldx   2+2,s 					get FILE ptr param
			ldd   2+4,s 					get format string
printf1		stx   _fpmp,y					save FILE ptr to static
			leax  >put_to_file,pcr       	ptr to output routine
			bra   L002e
 	}
 }


__norts__ asm int
sprintf(char *str, const char *fmt, ...)
{
    asm
    {
*	0,s = return address
*	2,s = destination string
*	4,s = format string
*	6,s = pointer to param
		pshs    u
		ldd     2+2,s                       get destination string
		std     _fpmp,y
        clr     [_fpmp,y]                   write an initial zero to the buffer
		leau    2+6,s                       point U to parameters referenced by format string
		ldd     2+4,s                       get format string
		leax    >put_to_mem,pcr             ptr to output routine
L002e 	pshs    d,u                         stack *expr and *fmt string
		pshs    x
		bsr     printf_common
		leas    6,s
		puls    u,pc


*       local offsets
vstart  set         0
fraccnt set         0           ; 2 frac cnt for strings and floats
fracflg set         2           ; 1
fldsiz  set         3           ; 2 field width
upflg   set         5           ; 1 upper case in hex and floats
fill    set         6           ; 1 fill character
ljust   set         7           ; 1 if left just string
vlen    set         8
*        rmb         2 ret addr
prthnd  set         10          ; 2
prtfmt  set         12          ; 2
prtvar  set         14          ; 2

printf_common_exit
     	leas    vlen,s
 		rts

*    entry:  variables  fpmp  destination - string address or FILE pointer
*            stack            file or memory pointer (2)
*                             expr list start (2)
*                             format string pnt (2)
*                             handler addr (2)
*                             return (2)
*       local:                u (2)
*                             ljust (1)
*                             fill (1)
*                             upper case flag (1)
*                             field width (2)
*                             fraction spec flag (1)
*                             fraction count (2)
printf_common
 	    ldu     4,s             get format string
 		leas    -vlen,s         make room on stack
 		bra     L004a
case_c 	ldx     prtvar,s
 		ldd     ,x++
 		stx     prtvar,s
L0047
        jsr     [prthnd,s]      all handler
L004a 	ldb     ,u+             get next character from format
 		beq     printf_common_exit
 		cmpb    #'%'
 		bne     L0047
 		clrb
 		lda     #$7D            32,000 chars
 		std     fraccnt,s
 		stb     ljust,s         assume no left justification
 		stb     fracflg,s       assume no factional part
		ldb     ,u+             get next character
		cmpb    #'-'
		bne     L0065
		stb     ljust,s         set left justification
		ldb     ,u+
L0065 	cmpb    #'0'
		beq     L006b
		ldb     #' '
L006b 	stb     fill,s
		ldb     -1,u
		lbsr    getdec          always try for fldsiz
		std     fldsiz,s
		ldb     ,u+
		cmpb    #'.'
		bne     switch
		stb     fracflg,s
		ldb     ,u+
		lbsr    getdec
		std     fraccnt,s
		ldb     ,u+
switch 	cmpb    #'c'            char
		beq     case_c
		pshs    u
		cmpb    #'f'            double (normal)
		beq     case_f
		cmpb    #'e'            float (double in scientific)
		beq     case_f
		cmpb    #'g'            shorter of e or f
		beq     case_f
		cmpb    #'E'            with uppercase e
		beq     case_f
		cmpb    #'G'            with uppercase g
		beq     case_f
		cmpb    #'l'            long decimal or hex
		beq     case_l
		cmpb    #'s'            string
		beq     case_s
		cmpb    #'d'            decimal
		beq     case_d
		cmpb    #'o'            octal
		lbeq    case_o
		cmpb    #'x'            hex
		lbeq    case_h
		cmpb    #'X'            hex
		lbeq    case_h
		cmpb    #'u'            unsigned
		beq     case_u
		puls    u               get format string
		bra     L0047           default -- just print

* print a float
case_f 	ldd     fldsiz+2,s
		pshs    d               stack field width
		leax    prtvar+4,s
		ldd     fraccnt+4,s
		tst     fracflg+4,s
		bne     case_f1
		ldd     #6
case_f1 pshs    d,x             stack precision & *variable
		ldd     #$7d00
		std     fraccnt+8,s     wipe old value
		ldb     -1,u
		clra
		pshs    d
		lbsr    _pffloat
		leas    8,s
		lbra    case_x8

* print a long
case_l 	pshs    u               extra space
		ldx     prtvar+4,s
		ldd     2,x
		pshs    d               stack lsw
		ldd     ,x
		pshs    d               stack msw
		leax    4,x
		stx     prtvar+8,s      update *variable
		ldb     ,u+             get print spec
		stu     6,s             patch up line pointer
		pshs    d               print spec (d,x)
		lbsr    _pflong
        leas    8,s             clean up our earlier pushes
		tfr     d,u
		lbra    case_x8

* print a string
case_s 	bsr     load_reg1       get *s in D
		tfr     d,u             transfer to U
		pshs    u
		lbsr    _strlen
		leas    2,s
		tst     fracflg+2,s
		beq     L011e           no string trunc
		cmpd    fraccnt+2,s
		bhi     L011e           if len(s) > fractional count
 		std     fraccnt+2,s     update to shorter value
L011e 	lbsr    L01e9           D has chars to print
 		lbra    L01b6           clean up

* print signed decimal
case_d 	bsr     load_regs
		pshs    d,x,y,u
		tsta
		bpl     L013b
		nega
		negb
		sbca    #0
		std     ,s               overwrite with new
		ldb     #'-'
		stb     ,u+
		bra     L013b

* print unsigned decimal
case_u 	bsr     load_regs
 		pshs    d,x,y,u
L013b 	ldd     #5
		std     2,s              digit, count
		sta     4,s
		leax    _dectbl,y
		puls    d
		bra     L0167

L014a 	inc     ,s
L014c 	subd    ,x
		bcc     L014a
		addd    ,x++
		pshs    b
		ldb     1,s             get count
		tst     3,s             non zero yet?
		bne     L015f
		tstb                    is this non zero?
		beq     L0163
		inc     3,s
L015f 	addb    #'0'
 		stb     ,u+
L0163 	clr     1,s
 		puls    b
L0167 	dec     1,s
		bne     L014c
		addb    #'0'
		stb     ,u+
		clr     ,u
		leas    4,s              clean off temps
		bra     L01b2

* point U at buffer, get a number in D
load_regs
     	leau    _buf1,y
load_reg1
     	ldx     prtvar+4,s
		ldd     ,x++
		stx     prtvar+4,s
		rts

* print a hex number
case_h 	andb    #$20                lower case bit
		stb     upflg+2,s           true if lower case
		bsr     load_regs
		pshs    d,u                 n, *s
L018a 	andb    #$0f
		pshs    b
		lda     #'0'
		cmpb    #9
		ble     L0198
		lda     #'A'-10
		adda    upflg+7,s
L0198 	adda    ,s+
		sta     ,u+
		ldd     ,s
		lsra                        /2
		rorb
		lsra                        /4
		rorb
		lsra                        /8
		rorb
		lsra                        /16
		rorb
		std     ,s
		bne     L018a

* entry for octal
L01aa	clr     ,u
		ldx     2,s
		bsr     frevers
		leas    2,s                 clean off number

* entry for decimal & unsigned
L01b2 	puls    u                   *our string

* entry for float and long
case_x8 bsr     fmt_prt
L01b6 	puls    u                   *format string
 		lbra    L004a               .. and go for more

* reverse a string
frev1 	ldb     ,x
		lda     ,-u
		sta     ,x+
		stb     ,u

frevers EXPORT
frevers: pshs   u
		cmpx    ,s++
		bcs     frev1
		rts

* print an octal number
case_o 	bsr     load_regs
 		pshs    d,u
L01ce 	andb    #7
		addb    #'0'
		stb     ,u+
		ldd     ,s
		lsra                        /2
		rorb
		lsra                        /4
		rorb
		lsra                        /8
		rorb
		std   ,s
		bne   L01ce
		bra   L01aa

* universal formatter
* expects u = *s
fmt_prt	pshs    u
		lbsr    _strlen
		leas    2,s
L01e9 	nega
		negb
		sbca    #0
		addd    fldsiz+4,s            compute number of blanks
		std     fldsiz+4,s
		tst     ljust+4,s
		bne     L0200                 if want left justification
		bsr     L0215                 lead blanks
		bra     L0200
L01f9 	ldb     ,u+
		beq     L0209                   if EOS
		jsr     [prthnd+4,s]            call handler
L0200 	ldd     fraccnt+4,s
		subd    #1
		std     fraccnt+4,s
		bpl     L01f9                   if not EOS
L0209 	tst     ljust+4,s
		beq     L020f                   if we want left justification
		bsr     L0215                   trailing blanks
L020f 	rts

* put out (fldsiz) blanks
L0210 	ldb     fill+6,s
 		jsr     [prthnd+6,s]            call handler
L0215 	ldd     fldsiz+6,s
		subd    #1
		std     fldsiz+6,s
		bpl     L0210
		rts

* converts decmimal ascii into hex
* expects u -> next char
*         b = first char
getdec 	clr     ,-s
		clr     ,-s
		leau    -1,u                 back up to char
		leax    _chcodes,pcr
		bra     getdec2
getdec1	ldd     ,s
		aslb
		rola
		std     ,s
		aslb
		rola
		aslb
		rola
		addd    ,s
		addb    ,u+
		adca    #0
		subd    #$0030
		std     ,s
		ldb     ,u
getdec2	lda     b,x
_DIGIT  equ     $08
		anda    #_DIGIT
		bne     getdec1
		puls    d,pc

* B = character to put
put_to_file
     	ldx     _fpmp,y
		pshs    d,x
		lbsr    putc
		leas    4,s
		rts

* B = character to put
put_to_mem
     	ldx     _fpmp,y
		stb     ,x+
		stx     _fpmp,y
		clr     ,x
		rts
	}
}
