*      stack u, ret, c, long

                    section   bss       ; begin bss section
buf1                rmb       20        ; reserve 20 bytes
                    endsect             ; end current section


                    section   rodata    ; begin rodata section
ldectbl             fdb       $3b9a,$ca00 ; define word data $3b9a,$ca00
                    fdb       $05f5,$e100 ; define word data $05f5,$e100
                    fdb       $0098,$9680 ; define word data $0098,$9680
                    fdb       $000f,$4240 ; define word data $000f,$4240
                    fdb       $0001,$86a0 ; define word data $0001,$86a0
                    fdb       $0000,10000 ; define word data $0000,10000
                    fdb       $0000,1000 ; define word data $0000,1000
                    fdb       $0000,100 ; define word data $0000,100
                    fdb       $0000,10  ; define word data $0000,10
                    endsect             ; end current section

                    section   code      ; begin code section

_pflinit            EXPORT              ; export this symbol
_pflinit:           rts                 ; return to caller


_pflong             EXPORT              ; export this symbol
_pflong:            pshs      u         ; save U on the hardware stack
                    leau      buf1,y    ; compute effective address into U from buf1,y
                    pshs      u         ; save U on the hardware stack
                    ldb       4+2+1,s   ; load B from stack-relative value 4+2+1,s
switch              cmpb      #'d
                    beq       case_d    ; branch if equal/zero to case_d
                    cmpb      #'u
                    lbeq      case_u    ; long branch if equal/zero to case_u
                    cmpb      #'o
                    beq       case_o    ; branch if equal/zero to case_o
                    cmpb      #'x
                    beq       case_x    ; branch if equal/zero to case_x
                    cmpb      #'X
                    beq       case_x    ; branch if equal/zero to case_x
                    lda       #'l
                    std       ,u++      ; store D to memory pointed to by U+, then advance U+
pflxit              clr       ,u        ; clear memory pointed to by U
                    puls      d,u,pc    ; restore registers and return
                    pag
case_o              leax      8,s       ; long
case_o1             ldb       3,x       ; load B from indexed value 3,x
                    andb      #$07      ; AND B with immediate value $07
                    addb      #'0
                    stb       ,u+       ; store B to memory pointed to by U, then advance U
                    ldb       #3        ; load B from immediate value 3
                    bsr       fshifts   ; branch to subroutine to fshifts
                    bne       case_o1   ; branch if not equal to case_o1
                    bra       case_x3   ; branch unconditionally to case_x3


fshifts             lsr       0,x       ; logical shift indexed value 0,x right by one bit
                    ror       1,x       ; rotate indexed value 1,x right through carry
                    ror       2,x       ; rotate indexed value 2,x right through carry
                    ror       3,x       ; rotate indexed value 3,x right through carry
                    decb                ; decrement B
                    bne       fshifts   ; branch if not equal to fshifts
                    lda       0,x       ; load A from indexed value 0,x
                    ora       1,x       ; OR A with indexed value 1,x
                    ora       2,x       ; OR A with indexed value 2,x
                    ora       3,x       ; OR A with indexed value 3,x
                    rts                 ; return to caller


case_x              andb      #$20      ; lower case bit
                    pshs      b         ; save B on the hardware stack
                    leax      9,s       ; compute effective address into X from 9,s
case_x1             ldb       3,x       ; load B from indexed value 3,x
                    andb      #$0f      ; AND B with immediate value $0f
                    pshs      b         ; save B on the hardware stack
                    lda       #'0
                    cmpb      #9        ; compare B against immediate value 9
                    ble       case_x2   ; branch if less or equal to case_x2
                    lda       #'A-10
                    adda      1,s       ; add stack-relative value 1,s into A
case_x2             adda      ,s+       ; add memory pointed to by S, then advance S into A
                    sta       ,u+       ; store A to memory pointed to by U, then advance U
                    ldb       #4        ; load B from immediate value 4
                    bsr       fshifts   ; branch to subroutine to fshifts
                    bne       case_x1   ; branch if not equal to case_x1
                    leas      1,s       ; adjust S using 1,s
case_x3             ldx       ,s        ; load X from memory pointed to by S
                    clr       ,u        ; clear memory pointed to by U
frevers             EXTERNAL            ; import external symbol
                    lbsr      frevers   ; long branch to subroutine to frevers
                    puls      d,u,pc    ; restore registers and return

case_d              ldb       8,s       ; load B from stack-relative value 8,s
                    bpl       case_d4   ; branch if plus to case_d4
                    ldd       #0        ; load D from immediate value 0
                    subd      10,s      ; subtract stack-relative value 10,s from D
                    std       10,s      ; store D to stack-relative value 10,s
                    ldd       #0        ; load D from immediate value 0
                    sbcb      9,s       ; subtract stack-relative value 9,s from B
                    sbca      8,s       ; subtract stack-relative value 8,s from A
                    std       8,s       ; store D to stack-relative value 8,s
                    cmpd      #$8000    ; compare D against immediate value $8000
                    bne       case_d3   ; branch if not equal to case_d3
                    ldd       2,x       ; load D from indexed value 2,x
                    bne       case_d3   ; branch if not equal to case_d3
                    leax      >tminlong,pcr ; compute effective address into X from >tminlong,pcr
case_d2             lda       ,x+       ; load A from memory pointed to by X, then advance X
                    sta       ,u+       ; store A to memory pointed to by U, then advance U
                    bne       case_d2   ; branch if not equal to case_d2
case_d1             lbra      pflxit    ; long branch unconditionally to pflxit

case_d3             ldb       #'-
                    stb       ,u+       ; store B to memory pointed to by U, then advance U
case_u
case_d4             leax      ldectbl,pcr ; compute effective address into X from ldectbl,pcr
                    clra                ; clear A
                    ldb       #10       ; load B from immediate value 10
                    pshs      a         ; save A on the hardware stack
                    pshs      d         ; save D on the hardware stack
                    bra       case_d11  ; branch unconditionally to case_d11

case_d7             inc       ,s        ; increment memory pointed to by S
case_d8             ldd       13,s      ; load D from stack-relative value 13,s
                    subd      2,x       ; subtract indexed value 2,x from D
                    std       13,s      ; store D to stack-relative value 13,s
                    ldd       11,s      ; load D from stack-relative value 11,s
                    sbcb      1,x       ; subtract indexed value 1,x from B
                    sbca      0,x       ; subtract indexed value 0,x from A
                    std       11,s      ; store D to stack-relative value 11,s
                    bcc       case_d7   ; branch if carry is clear to case_d7
                    ldd       13,s      ; load D from stack-relative value 13,s
                    addd      2,x       ; add indexed value 2,x into D
                    std       13,s      ; store D to stack-relative value 13,s
                    ldd       11,s      ; load D from stack-relative value 11,s
                    adcb      1,x       ; add indexed value 1,x into B
                    adca      0,x       ; add indexed value 0,x into A
                    std       11,s      ; store D to stack-relative value 11,s
                    ldb       ,s        ; load B from memory pointed to by S
                    tst       2,s       ; test stack-relative value 2,s and update condition codes
                    bne       case_d9   ; branch if not equal to case_d9
                    tstb                ; test B and update condition codes
                    beq       case_d10  ; branch if equal/zero to case_d10
                    inc       2,s       ; increment stack-relative value 2,s
case_d9             addb      #'0
                    stb       ,u+       ; store B to memory pointed to by U, then advance U
case_d10            leax      4,x       ; compute effective address into X from 4,x
                    clr       ,s        ; clear memory pointed to by S
case_d11            dec       1,s       ; decrement stack-relative value 1,s
                    bne       case_d8   ; branch if not equal to case_d8
                    ldb       14,s      ; load B from stack-relative value 14,s
                    addb      #'0
                    stb       ,u+       ; store B to memory pointed to by U, then advance U
                    leas      3,s       ; adjust S using 3,s
                    bra       case_d1   ; branch unconditionally to case_d1


tminlong            fcc       '-2147483648' ; define string data '-2147483648'
                    fcb       0         ; define byte data 0

                    endsect             ; end current section
