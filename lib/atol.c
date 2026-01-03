__norts__ asm long
atol(char *str)
{
	asm
	{
_lmul EXTERNAL
_lneg EXTERNAL
_flacc EXTERNAL
_lmove EXTERNAL
_chcodes EXTERNAL
        pshs  u
        ldu   2+2,s             get pointer to string
        clra
        clrb
        pshs  b
        pshs  d
        pshs  d
charloop
        ldb   ,u+
        cmpb  #' '              space?
        beq   charloop
        cmpb  #9                tab?
        beq   charloop
        cmpb  #'-'              negative?
        bne   L001e
        stb   4,s
        bra   L0045
L001e   cmpb  #'+'
        bne   L0047
        bra   L0045
L0024   ldd   2,s
        pshs  d
        ldd   2,s
        pshs  d
        leax  >L006c,pcr
        lbsr  _lmul
        ldb   -1,u
        clra
        subb  #$30
        addd  2,x
        std   2,s
        ldd   #0
        adcb  1,x
        adca  ,x
        std   ,s
L0045   ldb   ,u+
L0047   clra
        leax  _chcodes,y
        ldb   d,x
        andb  #8
        bne   L0024
        tst   4,s
        beq   L005d
        leax  ,s
        lbsr  _lneg
        bra   L005f
L005d   leax  ,s
L005f   leau  _flacc,y
        pshs  u
        lbsr  _lmove
        leas  5,s
        puls  u,pc

L006c   fcb $07,$00,$00
        fcb $07,$00,$0A
    }
}
