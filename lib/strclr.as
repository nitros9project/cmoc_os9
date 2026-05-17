* Adapted from Deek's KLibc strclr_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strclr             EXPORT              ; export this symbol

_strclr
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    clrb                ; clear B
                    ldx       6,s       ; load X from stack-relative value 6,s
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
Loop_01             stb       ,u+       ; store B to memory pointed to by U, then advance U
                    leax      -1,x      ; compute effective address into X from -1,x
                    bne       Loop_01   ; branch if not equal to Loop_01
BranchTarget_01     ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
