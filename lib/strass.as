* Adapted from Deek's KLibc strass_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

__strass            EXPORT              ; export this symbol

__strass
                    pshs      y,u       ; save Y,U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    ldy       8,s       ; load Y from stack-relative value 8,s
                    ldd       10,s      ; load D from stack-relative value 10,s
                    lsra                ; logical shift A right by one bit
                    rorb                ; rotate B right through carry
                    tfr       d,x       ; transfer D,X
                    bcc       BranchTarget_01 ; branch if carry is clear to BranchTarget_01
                    lda       ,y+       ; load A from memory pointed to by Y, then advance Y
                    sta       ,u+       ; store A to memory pointed to by U, then advance U
BranchTarget_01     stx       -2,s      ; store X to stack-relative value -2,s
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
Loop_01             ldd       ,y++      ; load D from memory pointed to by Y+, then advance Y+
                    std       ,u++      ; store D to memory pointed to by U+, then advance U+
                    leax      -1,x      ; compute effective address into X from -1,x
                    bne       Loop_01   ; branch if not equal to Loop_01
BranchTarget_02     puls      y,u,pc    ; restore registers and return

                    endsect             ; end current section
