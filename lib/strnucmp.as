* Adapted from Deek's KLibc strnucmp_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strnucmp           EXPORT              ; export this symbol

toupper             EXTERN              ; import external symbol

_strnucmp
                    pshs      y,u       ; save Y,U on the hardware stack
                    ldu       8,s       ; load U from stack-relative value 8,s
                    ldd       10,s      ; load D from stack-relative value 10,s
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    bra       Continue_01 ; branch unconditionally to Continue_01
Loop_01             ldd       10,s      ; load D from stack-relative value 10,s
                    subd      #1        ; subtract immediate value 1 from D
                    std       10,s      ; store D to stack-relative value 10,s
                    beq       ReturnZero_01 ; branch if equal/zero to ReturnZero_01
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    beq       ReturnZero_01 ; branch if equal/zero to ReturnZero_01
Continue_01         ldb       ,u        ; load B from memory pointed to by U
                    clra                ; clear A
                    pshs      d         ; save D on the hardware stack
                    lbsr      toupper   ; long branch to subroutine to toupper
                    std       ,s        ; store D to memory pointed to by S
                    ldx       8,s       ; load X from stack-relative value 8,s
                    ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    stx       8,s       ; store X to stack-relative value 8,s
                    clra                ; clear A
                    pshs      d         ; save D on the hardware stack
                    lbsr      toupper   ; long branch to subroutine to toupper
                    leas      2,s       ; adjust S using 2,s
                    subd      ,s++      ; subtract memory pointed to by S+, then advance S+ from D
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    bra       BranchTarget_01 ; branch unconditionally to BranchTarget_01
ReturnZero_01       clra                ; clear A
                    clrb                ; clear B
BranchTarget_01     puls      y,u,pc    ; restore registers and return

                    endsect             ; end current section
