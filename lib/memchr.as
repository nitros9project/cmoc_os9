* Adapted from Deek's KLibc memchr.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_memchr             EXPORT              ; export this symbol

_memchr
                    pshs      x,u       ; save X,U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    ldx       10,s      ; load X from stack-relative value 10,s
                    beq       ReturnZero_01 ; branch if equal/zero to ReturnZero_01
Loop_01             lda       ,u+       ; load A from memory pointed to by U, then advance U
                    cmpa      9,s       ; compare A against stack-relative value 9,s
                    bne       BranchTarget_01 ; branch if not equal to BranchTarget_01
                    leau      -1,u      ; compute effective address into U from -1,u
                    tfr       u,d       ; transfer U,D
                    bra       Continue_01 ; branch unconditionally to Continue_01
BranchTarget_01     leax      -1,x      ; compute effective address into X from -1,x
                    bne       Loop_01   ; branch if not equal to Loop_01
ReturnZero_01       clra                ; clear A
                    clrb                ; clear B
Continue_01         puls      x,u,pc    ; restore registers and return

                    endsect             ; end current section
