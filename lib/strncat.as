* Adapted from Deek's KLibc strncat for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strncat            EXPORT              ; export this symbol

_strncat
                    pshs      y,u       ; save Y,U on the hardware stack
                    ldu       8,s       ; load U from stack-relative value 8,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldy       10,s      ; load Y from stack-relative value 10,s
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
Loop_01             ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    bne       Loop_01   ; branch if not equal to Loop_01
                    leax      -1,x      ; compute effective address into X from -1,x
Loop_02             ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    stb       ,x+       ; store B to memory pointed to by X, then advance X
                    leay      -1,y      ; compute effective address into Y from -1,y
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    tstb                ; test B and update condition codes
                    bne       Loop_02   ; branch if not equal to Loop_02
BranchTarget_01     clr       ,x        ; clear memory pointed to by X
BranchTarget_02     ldd       6,s       ; load D from stack-relative value 6,s
                    puls      y,u,pc    ; restore registers and return

                    endsect             ; end current section
