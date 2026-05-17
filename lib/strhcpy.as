* Adapted from Deek's KLibc strhcpy_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strhcpy            EXPORT              ; export this symbol

_strhcpy
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldx       6,s       ; load X from stack-relative value 6,s
Loop_01             ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    stb       ,u+       ; store B to memory pointed to by U, then advance U
                    bpl       Loop_01   ; branch if plus to Loop_01
                    andb      #$7f      ; AND B with immediate value $7f
                    stb       -1,u      ; store B to indexed value -1,u
                    clr       ,u        ; clear memory pointed to by U
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
