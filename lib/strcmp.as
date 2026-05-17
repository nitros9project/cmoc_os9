* Adapted from Deek's KLibc strcmp.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strcmp             EXPORT              ; export this symbol

_strcmp
                    pshs      u         ; save U on the hardware stack
                    ldx       4,s       ; load X from stack-relative value 4,s
                    ldu       6,s       ; load U from stack-relative value 6,s
                    bra       Continue_01 ; branch unconditionally to Continue_01
Loop_01             ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
Continue_01         ldb       ,u        ; load B from memory pointed to by U
                    subb      ,x+       ; subtract memory pointed to by X, then advance X from B
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    negb                ; negate B
BranchTarget_01     sex                 ; sign-extend B into A to form D
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
