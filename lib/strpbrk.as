* Adapted from Deek's KLibc strpbrk.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strpbrk            EXPORT              ; export this symbol

_index              EXTERN              ; import external symbol

_strpbrk
                    pshs      x,u       ; save X,U on the hardware stack
                    ldx       8,s       ; load X from stack-relative value 8,s
                    ldu       6,s       ; load U from stack-relative value 6,s
                    pshs      x         ; save X on the hardware stack
Loop_01             clra                ; clear A
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
Label_01            beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    stb       3,s       ; store B to stack-relative value 3,s
                    lbsr      _index    ; long branch to subroutine to _index
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    leau      -1,u      ; compute effective address into U from -1,u
                    tfr       u,d       ; transfer U,D
BranchTarget_01     leas      4,s       ; adjust S using 4,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
