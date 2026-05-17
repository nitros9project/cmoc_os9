* Adapted from Deek's KLibc stringsu_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strucat            EXPORT              ; export this symbol
_strucpy            EXPORT              ; export this symbol

toupper             EXTERN              ; import external symbol

_strucat
                    pshs      u         ; save U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    ldx       4,s       ; load X from stack-relative value 4,s
Loop_01             ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    bne       Loop_01   ; branch if not equal to Loop_01
                    leax      -1,x      ; compute effective address into X from -1,x
                    bra       Loop_02   ; branch unconditionally to Loop_02

_strucpy
                    pshs      u         ; save U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    ldx       4,s       ; load X from stack-relative value 4,s
Loop_02             ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    clra                ; clear A
                    pshs      d,x       ; save D,X on the hardware stack
                    lbsr      toupper   ; long branch to subroutine to toupper
                    leas      2,s       ; adjust S using 2,s
                    puls      x         ; restore X from the hardware stack
                    stb       ,x+       ; store B to memory pointed to by X, then advance X
                    bne       Loop_02   ; branch if not equal to Loop_02
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
