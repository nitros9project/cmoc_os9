__norts__ asm long
atol(char *str)
{
	asm
	{
        pshs  u
        ldu   4,s
        clra
        clrb
        pshs  d
        pshs  b
L000a   ldb   ,u+
        cmpb  #' '          space?
        beq   L000a
        cmpb  #9            tab?
        beq   L000a
        cmpb  #' '
        bne   L001c
        stb   ,s
        bra   L0037
L001c   cmpb  #'+'
        bne   L0039
        bra   L0037
L0022   ldd   1,s
        lslb
        rola
        lslb
        rola
        addd  1,s
        lslb
        rola
        pshs  d
        ldb   -1,u
        clra
        subb  #$30
        addd  ,s++
        std   1,s
L0037   ldb   ,u+
L0039   cmpb  #'0'
        bcs   L0041
        cmpb  #'9'
        bls   L0022
L0041   tst   ,s+
        puls  d
        beq   L004b
        nega
        negb
        sbca  #0
L004b   puls  u,pc
    }
}
