* Adapted from Deek's KLibc memset.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_memset             EXPORT              ; export this symbol

_memset
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldx       8,s       ; load X from stack-relative value 8,s
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    ldb       7,s       ; load B from stack-relative value 7,s
Loop_01             stb       ,u+       ; store B to memory pointed to by U, then advance U
                    leax      -1,x      ; compute effective address into X from -1,x
                    bne       Loop_01   ; branch if not equal to Loop_01
BranchTarget_01     ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
