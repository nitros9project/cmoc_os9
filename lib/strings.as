* Adapted from Deek's KLibc strings_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strcat             EXPORT              ; export this symbol
_strcpy             EXPORT              ; export this symbol
_strend             EXPORT              ; export this symbol

_strcat
                    pshs      u         ; save U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    ldx       4,s       ; load X from stack-relative value 4,s
                    bsr       Subroutine_01 ; branch to subroutine to Subroutine_01
                    tfr       d,x       ; transfer D,X
                    bra       Loop_01   ; branch unconditionally to Loop_01

_strcpy
                    pshs      u         ; save U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    ldx       4,s       ; load X from stack-relative value 4,s
Loop_01             ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    stb       ,x+       ; store B to memory pointed to by X, then advance X
                    bne       Loop_01   ; branch if not equal to Loop_01
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

_strend
                    ldx       2,s       ; load X from stack-relative value 2,s
Subroutine_01       ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    bne       Subroutine_01 ; branch if not equal to Subroutine_01
                    leax      -1,x      ; compute effective address into X from -1,x
                    tfr       x,d       ; transfer X,D
                    rts                 ; return to caller

                    endsect             ; end current section
