* Adapted from cmoc_os9/lib/todo/cludiv.a for the live cmoc_os9 ABI.

                    section   bss       ; begin bss section

B0000               rmb       1         ; reserve 1 bytes

                    endsect             ; end current section

                    section   code      ; begin code section

_flacc              EXTERNAL            ; import external symbol
_rpterr             EXTERNAL            ; import external symbol
_lbexit             EXTERNAL            ; import external symbol

_ludiv              EXPORT              ; export this symbol
_lumod              EXPORT              ; export this symbol

EDIVERR             equ       45        ; define constant as 45
Carry               equ       %00000001 ; define constant as %00000001

* entry *x = divisor
*       *(2,s) = dividend
*
* exit  _flacc = quotient
*       *x = remainder

_ludiv
                    bsr       _div1     ; branch to subroutine to _div1
                    leas      8,s       ; adjust S using 8,s
                    lbra      _lbexit   ; long branch unconditionally to _lbexit

_lumod
                    lda       0,x       ; load A from indexed value 0,x
                    ora       1,x       ; OR A with indexed value 1,x
                    ora       2,x       ; OR A with indexed value 2,x
                    ora       3,x       ; OR A with indexed value 3,x
                    bne       _lumod1   ; branch if not equal to _lumod1
* zero divisor -- return dividend
                    ldd       0,x       ; load D from indexed value 0,x
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    ldd       2,x       ; load D from indexed value 2,x
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       2,x       ; store D to indexed value 2,x
                    lbra      _lbexit   ; long branch unconditionally to _lbexit

_lumod1
                    bsr       div2      ; branch to subroutine to div2
                    ldd       10,s      ; load D from stack-relative value 10,s
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       0,x       ; store D to indexed value 0,x
                    ldd       12,s      ; load D from stack-relative value 12,s
                    std       2,x       ; store D to indexed value 2,x
                    leas      8,s       ; adjust S using 8,s
                    lbra      _lbexit   ; long branch unconditionally to _lbexit

* check for zero divisor
_div1
                    lda       0,x       ; load A from indexed value 0,x
                    ora       1,x       ; OR A with indexed value 1,x
                    ora       2,x       ; OR A with indexed value 2,x
                    ora       3,x       ; OR A with indexed value 3,x
                    bne       div2      ; branch if not equal to div2
* divide by zero error
                    ldd       2,s       ; load D from stack-relative value 2,s
                    std       6,s       ; store D to stack-relative value 6,s
                    leas      6,s       ; adjust S using 6,s
                    ldd       #EDIVERR  ; load D from immediate value EDIVERR
                    lbra      _rpterr   ; long branch unconditionally to _rpterr

* set up our stack
div2
                    ldd       0,x       ; load D from indexed value 0,x
                    ldx       2,x       ; load X from indexed value 2,x
                    pshs      d,x       ; save D,X on the hardware stack
                    ldd       #0        ; load D from immediate value 0
                    pshs      d         ; save D on the hardware stack
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    std       _flacc+2,y ; store D to indexed value _flacc+2,y
                    leax      _flacc,y  ; compute effective address into X from _flacc,y

* shift the divisor left
                    clra                ; clear A
                    tst       2,s       ; test stack-relative value 2,s and update condition codes
                    bmi       div51     ; branch if minus to div51
div5
                    inca                ; increment A
                    asl       5,s       ; shift stack-relative value 5,s left by one bit
                    rol       4,s       ; rotate stack-relative value 4,s left through carry
                    rol       3,s       ; rotate stack-relative value 3,s left through carry
                    rol       2,s       ; rotate stack-relative value 2,s left through carry
                    bpl       div5      ; branch if plus to div5
div51
                    sta       0,s       ; store A to stack-relative value 0,s
                    bra       check     ; branch unconditionally to check

* subtract the divisor from the dividend
div6
                    ldd       12,s      ; load D from stack-relative value 12,s
                    subd      4,s       ; subtract stack-relative value 4,s from D
                    std       12,s      ; store D to stack-relative value 12,s
                    ldd       10,s      ; load D from stack-relative value 10,s
                    sbcb      3,s       ; subtract stack-relative value 3,s from B
                    sbca      2,s       ; subtract stack-relative value 2,s from A
                    std       10,s      ; store D to stack-relative value 10,s
                    bcc       div7      ; branch if carry is clear to div7
                    ldd       12,s      ; load D from stack-relative value 12,s
                    addd      4,s       ; add stack-relative value 4,s into D
                    std       12,s      ; store D to stack-relative value 12,s
                    ldd       10,s      ; load D from stack-relative value 10,s
                    adcb      3,s       ; add stack-relative value 3,s into B
                    adca      2,s       ; add stack-relative value 2,s into A
                    std       10,s      ; store D to stack-relative value 10,s
                    andcc     #^Carry   ; clear condition-code bits with mask #^Carry
                    bra       div8      ; branch unconditionally to div8

* rotate quotient and dividend
div7
                    orcc      #Carry    ; set condition-code bits with mask #Carry
div8
                    rol       3,x       ; rotate indexed value 3,x left through carry
                    rol       2,x       ; rotate indexed value 2,x left through carry
                    rol       1,x       ; rotate indexed value 1,x left through carry
                    rol       0,x       ; rotate indexed value 0,x left through carry
                    lsr       2,s       ; logical shift stack-relative value 2,s right by one bit
                    ror       3,s       ; rotate stack-relative value 3,s right through carry
                    ror       4,s       ; rotate stack-relative value 4,s right through carry
                    ror       5,s       ; rotate stack-relative value 5,s right through carry
                    dec       0,s       ; decrement stack-relative value 0,s
check
                    bpl       div6      ; branch if plus to div6
                    jmp       [6,s]     ; jump to [6,s]

                    endsect             ; end current section
