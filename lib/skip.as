* Adapted from cmoc_os9/lib/todo/skip.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_skipbl             EXPORT              ; export this symbol
_skipwd             EXPORT              ; export this symbol

_skipbl
                    ldx       2,s       ; load X from stack-relative value 2,s
Loop_01             ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    cmpb      #$20      ; compare B against immediate value $20
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    cmpb      #9        ; compare B against immediate value 9
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    bra       BranchTarget_01 ; branch unconditionally to BranchTarget_01

_skipwd
                    ldx       2,s       ; load X from stack-relative value 2,s
Loop_02             ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    cmpb      #$20      ; compare B against immediate value $20
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    cmpb      #9        ; compare B against immediate value 9
                    bne       Loop_02   ; branch if not equal to Loop_02
BranchTarget_01     leax      -1,x      ; compute effective address into X from -1,x
                    tfr       x,d       ; transfer X,D
                    rts                 ; return to caller

                    endsect             ; end current section
