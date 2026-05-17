* Adapted from Deek's KLibc strncmp.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strncmp            EXPORT              ; export this symbol

_strncmp
                    pshs      y,u       ; save Y,U on the hardware stack
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldu       8,s       ; load U from stack-relative value 8,s
                    ldy       10,s      ; load Y from stack-relative value 10,s
                    beq       ReturnZero_01 ; branch if equal/zero to ReturnZero_01
                    bra       Continue_01 ; branch unconditionally to Continue_01
Loop_01             leay      -1,y      ; compute effective address into Y from -1,y
                    beq       ReturnZero_01 ; branch if equal/zero to ReturnZero_01
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    beq       ReturnZero_01 ; branch if equal/zero to ReturnZero_01
Continue_01         ldb       ,u        ; load B from memory pointed to by U
                    subb      ,x+       ; subtract memory pointed to by X, then advance X from B
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    negb                ; negate B
                    sex                 ; sign-extend B into A to form D
                    bra       Continue_02 ; branch unconditionally to Continue_02
ReturnZero_01       clra                ; clear A
                    clrb                ; clear B
Continue_02         puls      y,u,pc    ; restore registers and return

                    endsect             ; end current section
