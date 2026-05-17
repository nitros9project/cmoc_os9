* Adapted from Deek's KLibc strucmp.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strucmp            EXPORT              ; export this symbol

toupper             EXTERN              ; import external symbol

_strucmp
                    pshs      u         ; save U on the hardware stack
                    ldx       4,s       ; load X from stack-relative value 4,s
                    ldu       6,s       ; load U from stack-relative value 6,s
                    bra       Continue_01 ; branch unconditionally to Continue_01
Loop_01             ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
Continue_01         ldb       ,u        ; load B from memory pointed to by U
                    clra                ; clear A
                    pshs      d,x       ; save D,X on the hardware stack
                    lbsr      toupper   ; long branch to subroutine to toupper
                    leas      2,s       ; adjust S using 2,s
                    ldx       ,s        ; load X from memory pointed to by S
                    std       ,s        ; store D to memory pointed to by S
                    ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    clra                ; clear A
                    pshs      d,x       ; save D,X on the hardware stack
                    lbsr      toupper   ; long branch to subroutine to toupper
                    leas      2,s       ; adjust S using 2,s
                    puls      x         ; restore X from the hardware stack
                    subd      ,s++      ; subtract memory pointed to by S+, then advance S+ from D
                    beq       Loop_01   ; branch if equal/zero to Loop_01
BranchTarget_01     puls      u,pc      ; restore registers and return

                    endsect             ; end current section
