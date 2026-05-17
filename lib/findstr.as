* Live cmoc_os9 ABI assembly implementation of findstr()/findnstr().

                    section   code      ; begin code section

_findstr            EXPORT              ; export this symbol
_findnstr           EXPORT              ; export this symbol

* int match_at(const char *hay, const char *needle)
* X = hay, Y = needle
* returns D = 1 on match, 0 on mismatch
match_at
                    pshs      x,y,u     ; save X,Y,U on the hardware stack
                    tfr       x,u       ; transfer X,U
Loop_01             ldb       ,y+       ; load B from memory pointed to by Y, then advance Y
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    cmpb      ,u+       ; compare B against memory pointed to by U, then advance U
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    clra                ; clear A
                    clrb                ; clear B
                    puls      x,y,u,pc  ; restore registers and return
BranchTarget_01     ldd       #1        ; load D from immediate value 1
                    puls      x,y,u,pc  ; restore registers and return

_findstr
                    pshs      y,u       ; save Y,U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    ldb       ,u        ; load B from memory pointed to by U
                    bne       BranchTarget_02 ; branch if not equal to BranchTarget_02
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      y,u,pc    ; restore registers and return
BranchTarget_02     ldx       4,s       ; load X from stack-relative value 4,s
Loop_02             ldb       ,x        ; load B from memory pointed to by X
                    beq       ReturnZero_01 ; branch if equal/zero to ReturnZero_01
                    ldy       6,s       ; load Y from stack-relative value 6,s
                    bsr       match_at  ; branch to subroutine to match_at
                    bne       BranchTarget_03 ; branch if not equal to BranchTarget_03
                    leax      1,x       ; compute effective address into X from 1,x
                    bra       Loop_02   ; branch unconditionally to Loop_02
BranchTarget_03     tfr       x,d       ; transfer X,D
                    puls      y,u,pc    ; restore registers and return
ReturnZero_01       clra                ; clear A
                    clrb                ; clear B
                    puls      y,u,pc    ; restore registers and return

_findnstr
                    pshs      y,u       ; save Y,U on the hardware stack
                    ldu       8,s       ; load U from stack-relative value 8,s
                    ldb       ,u        ; load B from memory pointed to by U
                    bne       BranchTarget_04 ; branch if not equal to BranchTarget_04
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      y,u,pc    ; restore registers and return
BranchTarget_04     ldx       4,s       ; load X from stack-relative value 4,s
                    ldy       10,s      ; load Y from stack-relative value 10,s
                    beq       ReturnZero_02 ; branch if equal/zero to ReturnZero_02
Loop_03             ldb       ,x        ; load B from memory pointed to by X
                    beq       ReturnZero_02 ; branch if equal/zero to ReturnZero_02
                    pshs      x,y       ; save X,Y on the hardware stack
                    ldy       12,s      ; load Y from stack-relative value 12,s
                    bsr       match_at  ; branch to subroutine to match_at
                    puls      x,y       ; restore X,Y from the hardware stack
                    bne       BranchTarget_05 ; branch if not equal to BranchTarget_05
                    leax      1,x       ; compute effective address into X from 1,x
                    leay      -1,y      ; compute effective address into Y from -1,y
                    bne       Loop_03   ; branch if not equal to Loop_03
BranchTarget_05     tfr       x,d       ; transfer X,D
                    puls      y,u,pc    ; restore registers and return
ReturnZero_02       clra                ; clear A
                    clrb                ; clear B
                    puls      y,u,pc    ; restore registers and return

                    endsect             ; end current section
