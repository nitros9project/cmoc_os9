* Adapted from Deek's KLibc strlen.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strlen             EXPORT              ; export this symbol

_strlen
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
Loop_01             ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    bne       Loop_01   ; branch if not equal to Loop_01
                    leau      -1,u      ; compute effective address into U from -1,u
                    tfr       u,d       ; transfer U,D
                    subd      4,s       ; subtract stack-relative value 4,s from D
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
