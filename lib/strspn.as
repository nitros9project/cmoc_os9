* Adapted from Deek's KLibc strspn.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strspn             EXPORT              ; export this symbol
_strcspn            EXPORT              ; export this symbol

_strchr             EXTERN              ; import external symbol

_strspn
                    pshs      x,u       ; save X,U on the hardware stack
                    ldx       8,s       ; load X from stack-relative value 8,s
                    ldu       6,s       ; load U from stack-relative value 6,s
                    pshs      x         ; save X on the hardware stack
Loop_01             ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    stb       3,s       ; store B to stack-relative value 3,s
                    lbsr      _strchr   ; long branch to subroutine to _strchr
                    bne       Loop_01   ; branch if not equal to Loop_01
                    bra       BranchTarget_01 ; branch unconditionally to BranchTarget_01

_strcspn
                    pshs      x,u       ; save X,U on the hardware stack
                    ldx       8,s       ; load X from stack-relative value 8,s
                    ldu       6,s       ; load U from stack-relative value 6,s
                    pshs      x         ; save X on the hardware stack
Loop_02             ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    stb       3,s       ; store B to stack-relative value 3,s
                    lbsr      _strchr   ; long branch to subroutine to _strchr
                    beq       Loop_02   ; branch if equal/zero to Loop_02
BranchTarget_01     leau      -1,u      ; compute effective address into U from -1,u
                    tfr       u,d       ; transfer U,D
                    subd      8,s       ; subtract stack-relative value 8,s from D
                    leas      4,s       ; adjust S using 4,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
