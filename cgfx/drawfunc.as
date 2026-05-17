* Adapted from cmoc_os9/cgfx/todo/drawfunc.a for the live cmoc_os9 ABI.

        section bss
_draw_x1                rmb     2 * reserve 2 bytes
_draw_y1                rmb     2 * reserve 2 bytes
_draw_x2                rmb     2 * reserve 2 bytes
_draw_y2                rmb     2 * reserve 2 bytes
_draw_angle             rmb     1 * reserve 1 bytes
_draw_scale             rmb     1 * reserve 1 bytes
_draw_strings           rmb     2 * reserve 2 bytes
_draw_path              rmb     1 * reserve 1 bytes
_draw_xoff              rmb     2 * reserve 2 bytes
_draw_yoff              rmb     2 * reserve 2 bytes
_draw_nomove            rmb     1 * reserve 1 bytes
_draw_blank             rmb     1 * reserve 1 bytes
        endsect * end current section

        section code

_Draw                   EXPORT * export this symbol

_write                  EXTERNAL * import external symbol

negd    macro
        nega * negate A
        negb * negate B
        sbca    #0 * subtract immediate value 0 from A
        endm

_Draw
        pshs    u
        lda     5,s * load A from stack-relative value 5,s
        sta     _draw_path,y * store A to indexed value _draw_path,y
        leax    6,s * compute effective address into X from 6,s
        stx     _draw_strings,y * store X to indexed value _draw_strings,y
        ldx     ,x * load X from memory pointed to by X
        lbsr    parse
        puls    u,pc

parse   clr     _draw_nomove,y * clear indexed value _draw_nomove,y
        clr     _draw_blank,y * clear indexed value _draw_blank,y

ploop   lda     ,x+ * load A from memory pointed to by X, then advance X
        cmpa    #$20 * compare A against immediate value $20
        beq     ploop
        cmpa    #$3b * compare A against immediate value $3b
        beq     parse
        cmpa    #$5f * compare A against immediate value $5f
        bls     p00
        anda    #$5f * AND A with immediate value $5f
p00     cmpa    #$42 * compare A against immediate value $42
        bne     p10
        inc     _draw_blank,y * increment indexed value _draw_blank,y
        bra     ploop

p10     cmpa    #$4e * compare A against immediate value $4e
        bne     p20
        inc     _draw_nomove,y * increment indexed value _draw_nomove,y
        bra     ploop

p20     cmpa    #$43 * compare A against immediate value $43
        bne     p30
        lbsr    getnum
        pshs    b,x
        ldd     #$1b32 * load D from immediate value $1b32
        pshs    d
        leax    ,s * compute effective address into X from ,s
        ldu     #3 * load U from immediate value 3
        lda     _draw_path,y * load A from indexed value _draw_path,y
        lbsr    _write * long branch to subroutine to _write
        leas    3,s * adjust S using 3,s
        puls    x
        bra     parse

p30     cmpa    #$41 * compare A against immediate value $41
        bne     p40
        lbsr    getnum
        andb    #3 * AND B with immediate value 3
        stb     _draw_angle,y * store B to indexed value _draw_angle,y
        bra     parse

p40     cmpa    #$53 * compare A against immediate value $53
        bne     p50
        lbsr    getnum
        stb     _draw_scale,y * store B to indexed value _draw_scale,y
        bra     parse

p50     cmpa    #$4d * compare A against immediate value $4d
        bne     p60
p50a    lda     ,x+ * load A from memory pointed to by X, then advance X
        cmpa    #$20 * compare A against immediate value $20
        beq     p50a
        leax    -1,x * compute effective address into X from -1,x
        cmpa    #$2b * compare A against immediate value $2b
        beq     p52
        cmpa    #$2d * compare A against immediate value $2d
        beq     p52
        lbsr    getnum
        lslb * shift B left by one bit
        rola * rotate A left through carry
        lslb * shift B left by one bit
        rola * rotate A left through carry
        std     _draw_x2,y * store D to indexed value _draw_x2,y
p51     lda     ,x+ * load A from memory pointed to by X, then advance X
        cmpa    #$20 * compare A against immediate value $20
        beq     p51
        cmpa    #$2c * compare A against immediate value $2c
        lbne    prts
        lbsr    getnum
        lslb * shift B left by one bit
        rola * rotate A left through carry
        lslb * shift B left by one bit
        rola * rotate A left through carry
        std     _draw_y2,y * store D to indexed value _draw_y2,y
        lbsr    moveto
        lbra    parse

p52     lbsr    getnum * long branch to subroutine to getnum
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
p53     lda     ,x+ * load A from memory pointed to by X, then advance X
        cmpa    #$20 * compare A against immediate value $20
        beq     p53
        cmpa    #$2c * compare A against immediate value $2c
        lbne    prts
        lbsr    getnum
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        lbsr    move
        lbra    parse

p60     cmpa    #$25 * compare A against immediate value $25
        bne     p70
        lda     ,x+ * load A from memory pointed to by X, then advance X
        anda    #$5f * AND A with immediate value $5f
        cmpa    #$53 * compare A against immediate value $53
        lbne    parse
        pshs    x
        ldx     _draw_strings,y * load X from indexed value _draw_strings,y
        leax    2,x * compute effective address into X from 2,x
        stx     _draw_strings,y * store X to indexed value _draw_strings,y
        ldx     ,x * load X from memory pointed to by X
        lbsr    ploop
        puls    x
        lbra    ploop

p70     cmpa    #$55 * compare A against immediate value $55
        bne     p71
        lbsr    getnum
        negd
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        clra * clear A
        clrb * clear B
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
        lbsr    move
        lbra    parse

p71     cmpa    #$44 * compare A against immediate value $44
        bne     p72
        lbsr    getnum
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        clra * clear A
        clrb * clear B
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
        lbsr    move
        lbra    parse

p72     cmpa    #$4c * compare A against immediate value $4c
        bne     p73
        lbsr    getnum
        negd
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
        clra * clear A
        clrb * clear B
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        lbsr    move
        lbra    parse

p73     cmpa    #$52 * compare A against immediate value $52
        bne     p74
        bsr     getnum
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
        clra * clear A
        clrb * clear B
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        lbsr    move
        lbra    parse

p74     cmpa    #$45 * compare A against immediate value $45
        bne     p75
        bsr     getnum
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
        negd
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        lbsr    move
        lbra    parse

p75     cmpa    #$46 * compare A against immediate value $46
        bne     p76
        bsr     getnum
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
        lbsr    move
        lbra    parse

p76     cmpa    #$47 * compare A against immediate value $47
        bne     p77
        bsr     getnum
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        negd
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
        lbsr    move
        lbra    parse

p77     cmpa    #$48 * compare A against immediate value $48
        bne     prts
        bsr     getnum
        negd
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
        lbsr    move
        lbra    parse

prts    rts * return to caller

getnum  lda     ,x+ * load A from memory pointed to by X, then advance X
        cmpa    #$20 * compare A against immediate value $20
        beq     getnum
        cmpa    #$25 * compare A against immediate value $25
        beq     g10
        cmpa    #$39 * compare A against immediate value $39
        bhi     g02
        cmpa    #$2b * compare A against immediate value $2b
        beq     getnum
        cmpa    #$2d * compare A against immediate value $2d
        beq     g20
        cmpa    #$30 * compare A against immediate value $30
        bhs     g00
g02     ldd     #1 * load D from immediate value 1
        rts * return to caller

g00     suba    #$30 * subtract immediate value $30 from A
        pshs    a
        clr     ,-s * clear memory pointed to by -S

gloop0  ldb     ,x+ * load B from memory pointed to by X, then advance X
        cmpb    #$30 * compare B against immediate value $30
        blo     gnext0
        cmpb    #$39 * compare B against immediate value $39
        bhi     gnext0
        subb    #$30 * subtract immediate value $30 from B
        clra * clear A
        pshs    d
        ldd     2,s * load D from stack-relative value 2,s
        lslb * shift B left by one bit
        rola * rotate A left through carry
        lslb * shift B left by one bit
        rola * rotate A left through carry
        addd    2,s * add stack-relative value 2,s into D
        lslb * shift B left by one bit
        rola * rotate A left through carry
        addd    ,s++ * add memory pointed to by S+, then advance S+ into D
        std     ,s * store D to memory pointed to by S
        bra     gloop0

gnext0  leax    -1,x * compute effective address into X from -1,x
        puls    d,pc

g10     lda     ,x+ * load A from memory pointed to by X, then advance X
        anda    #$5f * AND A with immediate value $5f
        cmpa    #$44 * compare A against immediate value $44
        bne     g11
        pshs    x
        ldx     _draw_strings,y * load X from indexed value _draw_strings,y
        leax    2,x * compute effective address into X from 2,x
        stx     _draw_strings,y * store X to indexed value _draw_strings,y
        ldd     ,x * load D from memory pointed to by X
        puls    x,pc

g11     cmpa    #$53 * compare A against immediate value $53
        bne     g02
        pshs    x
        ldx     _draw_strings,y * load X from indexed value _draw_strings,y
        leax    2,x * compute effective address into X from 2,x
        stx     _draw_strings,y * store X to indexed value _draw_strings,y
        ldx     ,x * load X from memory pointed to by X
        bsr     getnum
        puls    x,pc

g20     bsr     getnum * branch to subroutine to getnum
        negd
        rts * return to caller

move    lda     _draw_angle,y * load A from indexed value _draw_angle,y
        beq     calcmove
        deca * decrement A
        bne     m00
        ldd     _draw_xoff,y * load D from indexed value _draw_xoff,y
        negd
        ldu     _draw_yoff,y * load U from indexed value _draw_yoff,y
        stu     _draw_xoff,y * store U to indexed value _draw_xoff,y
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        bra     calcmove

m00     deca * decrement A
        bne     m10
        ldd     _draw_xoff,y * load D from indexed value _draw_xoff,y
        negd
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
        ldd     _draw_yoff,y * load D from indexed value _draw_yoff,y
        negd
        std     _draw_yoff,y * store D to indexed value _draw_yoff,y
        bra     calcmove

m10     ldd     _draw_yoff,y * load D from indexed value _draw_yoff,y
        negd
        ldu     _draw_xoff,y * load U from indexed value _draw_xoff,y
        std     _draw_xoff,y * store D to indexed value _draw_xoff,y
        stu     _draw_yoff,y * store U to indexed value _draw_yoff,y

calcmove
        lda     _draw_scale,y * load A from indexed value _draw_scale,y
        ldb     _draw_xoff+1,y * load B from indexed value _draw_xoff+1,y
        mul * multiply A by B and leave the product in D
        pshs    d
        lda     _draw_scale,y * load A from indexed value _draw_scale,y
        ldb     _draw_xoff,y * load B from indexed value _draw_xoff,y
        mul * multiply A by B and leave the product in D
        addb    ,s * add memory pointed to by S into B
        stb     ,s * store B to memory pointed to by S
        puls    d
        addd    _draw_x1,y * add indexed value _draw_x1,y into D
        std     _draw_x2,y * store D to indexed value _draw_x2,y

        lda     _draw_scale,y * load A from indexed value _draw_scale,y
        ldb     _draw_yoff+1,y * load B from indexed value _draw_yoff+1,y
        mul * multiply A by B and leave the product in D
        pshs    d
        lda     _draw_scale,y * load A from indexed value _draw_scale,y
        ldb     _draw_yoff,y * load B from indexed value _draw_yoff,y
        mul * multiply A by B and leave the product in D
        addb    ,s * add memory pointed to by S into B
        stb     ,s * store B to memory pointed to by S
        puls    d
        addd    _draw_y1,y * add indexed value _draw_y1,y into D
        std     _draw_y2,y * store D to indexed value _draw_y2,y

moveto  tst     _draw_blank,y * test indexed value _draw_blank,y and update condition codes
        bne     move00
        leas    -6,s * adjust S using -6,s
        ldd     #$1b40 * load D from immediate value $1b40
        std     ,s * store D to memory pointed to by S
        ldd     _draw_x1,y * load D from indexed value _draw_x1,y
        lsra * logical shift A right by one bit
        rorb * rotate B right through carry
        lsra * logical shift A right by one bit
        rorb * rotate B right through carry
        std     2,s * store D to stack-relative value 2,s
        ldd     _draw_y1,y * load D from indexed value _draw_y1,y
        lsra * logical shift A right by one bit
        rorb * rotate B right through carry
        lsra * logical shift A right by one bit
        rorb * rotate B right through carry
        std     4,s * store D to stack-relative value 4,s
        pshs    x
        leax    2,s * compute effective address into X from 2,s
        ldu     #6 * load U from immediate value 6
        lda     _draw_path,y * load A from indexed value _draw_path,y
        lbsr    _write * long branch to subroutine to _write
        ldd     #$1b44 * load D from immediate value $1b44
        std     2,s * store D to stack-relative value 2,s
        ldd     _draw_x2,y * load D from indexed value _draw_x2,y
        lsra * logical shift A right by one bit
        rorb * rotate B right through carry
        lsra * logical shift A right by one bit
        rorb * rotate B right through carry
        std     4,s * store D to stack-relative value 4,s
        ldd     _draw_y2,y * load D from indexed value _draw_y2,y
        lsra * logical shift A right by one bit
        rorb * rotate B right through carry
        lsra * logical shift A right by one bit
        rorb * rotate B right through carry
        std     6,s * store D to stack-relative value 6,s
        leax    2,s * compute effective address into X from 2,s
        ldu     #6 * load U from immediate value 6
        lda     _draw_path,y * load A from indexed value _draw_path,y
        lbsr    _write * long branch to subroutine to _write
        puls    x
        leas    6,s * adjust S using 6,s

move00  tst     _draw_nomove,y * test indexed value _draw_nomove,y and update condition codes
        bne     mrts
        ldd     _draw_x2,y * load D from indexed value _draw_x2,y
        std     _draw_x1,y * store D to indexed value _draw_x1,y
        ldd     _draw_y2,y * load D from indexed value _draw_y2,y
        std     _draw_y1,y * store D to indexed value _draw_y1,y

mrts    rts * return to caller

        endsect * end current section
