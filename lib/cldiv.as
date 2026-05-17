
                    section   bss       ; begin bss section

* Uninitialized data (class B)
B0000               rmb       1         ; reserve 1 bytes
* Initialized Data (class G)

                    endsect             ; end current section

                    section   code      ; begin code section

_flacc              EXTERNAL            ; import external symbol
_rpterr             EXTERNAL            ; import external symbol
_lnegx              EXTERNAL            ; import external symbol
_lbexit             EXTERNAL            ; import external symbol

_ldiv               EXPORT              ; export this symbol
_lmod               EXPORT              ; export this symbol

_ldiv:              bsr       Subroutine_01 ; branch to subroutine to Subroutine_01
                    lda       1,s       ; load A from stack-relative value 1,s
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
Loop_01             lbsr      _lnegx    ; long branch to subroutine to _lnegx
BranchTarget_01     leas      8,s       ; adjust S using 8,s
                    lbra      _lbexit   ; long branch unconditionally to _lbexit
_lmod:              lda       ,x        ; load A from memory pointed to by X
                    ora       1,x       ; OR A with indexed value 1,x
                    ora       2,x       ; OR A with indexed value 2,x
                    ora       3,x       ; OR A with indexed value 3,x
                    bne       BranchTarget_02 ; branch if not equal to BranchTarget_02
                    ldd       ,x        ; load D from memory pointed to by X
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    ldd       2,x       ; load D from indexed value 2,x
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       2,x       ; store D to indexed value 2,x
                    lbra      _lbexit   ; long branch unconditionally to _lbexit
BranchTarget_02     lda       2,s       ; load A from stack-relative value 2,s
                    sta       B0000,y   ; store A to indexed value B0000,y
                    bsr       Subroutine_02 ; branch to subroutine to Subroutine_02
                    ldd       10,s      ; load D from stack-relative value 10,s
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       ,x        ; store D to memory pointed to by X
                    ldd       12,s      ; load D from stack-relative value 12,s
                    std       2,x       ; store D to indexed value 2,x
                    tst       B0000,y   ; test indexed value B0000,y and update condition codes
                    bmi       Loop_01   ; branch if minus to Loop_01
                    leas      8,s       ; adjust S using 8,s
                    lbra      _lbexit   ; long branch unconditionally to _lbexit
Subroutine_01       lda       ,x        ; load A from memory pointed to by X
                    ora       1,x       ; OR A with indexed value 1,x
                    ora       2,x       ; OR A with indexed value 2,x
                    ora       3,x       ; OR A with indexed value 3,x
                    bne       Subroutine_02 ; branch if not equal to Subroutine_02
                    ldd       2,s       ; load D from stack-relative value 2,s
                    std       6,s       ; store D to stack-relative value 6,s
                    leas      6,s       ; adjust S using 6,s
                    ldd       #$002d    ; load D from immediate value $002d
                    lbra      _rpterr   ; long branch unconditionally to _rpterr
Subroutine_02       ldd       ,x        ; load D from memory pointed to by X
                    ldx       2,x       ; load X from indexed value 2,x
                    pshs      d,x       ; save D,X on the hardware stack
                    ldd       #0        ; load D from immediate value 0
                    pshs      d         ; save D on the hardware stack
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    std       _flacc+2,y ; store D to indexed value _flacc+2,y
                    tst       2,s       ; test stack-relative value 2,s and update condition codes
                    bpl       BranchTarget_03 ; branch if plus to BranchTarget_03
                    leax      2,s       ; compute effective address into X from 2,s
                    lbsr      _lnegx    ; long branch to subroutine to _lnegx
                    inc       1,s       ; increment stack-relative value 1,s
BranchTarget_03     tst       10,s      ; test stack-relative value 10,s and update condition codes
                    bpl       BranchTarget_04 ; branch if plus to BranchTarget_04
                    leax      10,s      ; compute effective address into X from 10,s
                    lbsr      _lnegx    ; long branch to subroutine to _lnegx
                    com       1,s
BranchTarget_04     leax      _flacc,y  ; compute effective address into X from _flacc,y
                    lda       #1        ; load A from immediate value 1
Loop_02             inca                ; increment A
                    asl       5,s       ; shift stack-relative value 5,s left by one bit
                    rol       4,s       ; rotate stack-relative value 4,s left through carry
                    rol       3,s       ; rotate stack-relative value 3,s left through carry
                    rol       2,s       ; rotate stack-relative value 2,s left through carry
                    bpl       Loop_02   ; branch if plus to Loop_02
                    sta       ,s        ; store A to memory pointed to by S
Loop_03             ldd       12,s      ; load D from stack-relative value 12,s
                    subd      4,s       ; subtract stack-relative value 4,s from D
                    std       12,s      ; store D to stack-relative value 12,s
                    ldd       10,s      ; load D from stack-relative value 10,s
                    sbcb      3,s       ; subtract stack-relative value 3,s from B
                    sbca      2,s       ; subtract stack-relative value 2,s from A
                    std       10,s      ; store D to stack-relative value 10,s
                    bcc       BranchTarget_05 ; branch if carry is clear to BranchTarget_05
                    ldd       12,s      ; load D from stack-relative value 12,s
                    addd      4,s       ; add stack-relative value 4,s into D
                    std       12,s      ; store D to stack-relative value 12,s
                    ldd       10,s      ; load D from stack-relative value 10,s
                    adcb      3,s       ; add stack-relative value 3,s into B
                    adca      2,s       ; add stack-relative value 2,s into A
                    std       10,s      ; store D to stack-relative value 10,s
                    andcc     #254      ; clear condition-code bits with mask #254
                    bra       Continue_01 ; branch unconditionally to Continue_01
BranchTarget_05     orcc      #1        ; set condition-code bits with mask #1
Continue_01         rol       3,x       ; rotate indexed value 3,x left through carry
                    rol       2,x       ; rotate indexed value 2,x left through carry
                    rol       1,x       ; rotate indexed value 1,x left through carry
                    rol       ,x        ; rotate memory pointed to by X left through carry
                    lsr       2,s       ; logical shift stack-relative value 2,s right by one bit
                    ror       3,s       ; rotate stack-relative value 3,s right through carry
                    ror       4,s       ; rotate stack-relative value 4,s right through carry
                    ror       5,s       ; rotate stack-relative value 5,s right through carry
                    dec       ,s        ; decrement memory pointed to by S
                    bne       Loop_03   ; branch if not equal to Loop_03
                    jmp       [6,s]     ; jump to [6,s]

                    endsect             ; end current section
