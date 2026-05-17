* Adapted from Deek's KLibc memccpy.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_memccpy            EXPORT              ; export this symbol

_memccpy
                    pshs      y,u       ; save Y,U on the hardware stack
                    ldu       8,s       ; load U from stack-relative value 8,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldy       12,s      ; load Y from stack-relative value 12,s
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
Loop_01             lda       ,u+       ; load A from memory pointed to by U, then advance U
                    sta       ,x+       ; store A to memory pointed to by X, then advance X
                    cmpa      11,s      ; compare A against stack-relative value 11,s
                    bne       BranchTarget_01 ; branch if not equal to BranchTarget_01
                    tfr       u,d       ; transfer U,D
                    bra       Continue_01 ; branch unconditionally to Continue_01
BranchTarget_01     leay      -1,y      ; compute effective address into Y from -1,y
                    bne       Loop_01   ; branch if not equal to Loop_01
BranchTarget_02     tfr       y,d       ; transfer Y,D
Continue_01         puls      y,u,pc    ; restore registers and return

                    endsect             ; end current section
