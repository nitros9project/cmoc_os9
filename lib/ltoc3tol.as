* Adapted from cmoc_os9/lib/todo/ltoc3tol.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_c3tol              EXPORT              ; export this symbol
_ltoc3              EXPORT              ; export this symbol

_c3tol
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    clra                ; clear A
                    ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    std       ,u++      ; store D to memory pointed to by U+, then advance U+
                    ldd       ,x++      ; load D from memory pointed to by X+, then advance X+
                    std       ,u++      ; store D to memory pointed to by U+, then advance U+
                    puls      u,pc      ; restore registers and return

_ltoc3
                    pshs      u         ; save U on the hardware stack
                    leau      7,s       ; compute effective address into U from 7,s
                    ldx       4,s       ; load X from stack-relative value 4,s
                    lda       ,u+       ; load A from memory pointed to by U, then advance U
                    sta       ,x+       ; store A to memory pointed to by X, then advance X
                    ldd       ,u++      ; load D from memory pointed to by U+, then advance U+
                    std       ,x++      ; store D to memory pointed to by X+, then advance X+
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
