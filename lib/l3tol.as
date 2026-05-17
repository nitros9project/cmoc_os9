* Adapted from cmoc_os9/lib/todo/l3tol.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_l3tol              EXPORT              ; export this symbol

_l3tol
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldd       6,s       ; load D from stack-relative value 6,s
                    addd      #1        ; add immediate value 1 into D
                    bra       Continue_01 ; branch unconditionally to Continue_01
Loop_01             clra                ; clear A
                    clrb                ; clear B
                    stb       ,u        ; store B to memory pointed to by U
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldb       -1,x      ; load B from indexed value -1,x
                    stb       1,u       ; store B to indexed value 1,u
                    ldd       [6,s]     ; load D from indirect address [6,s]
                    std       2,u       ; store D to indexed value 2,u
                    leau      4,u       ; compute effective address into U from 4,u
                    ldd       6,s       ; load D from stack-relative value 6,s
                    addd      #3        ; add immediate value 3 into D
Continue_01         std       6,s       ; store D to stack-relative value 6,s
                    ldd       8,s       ; load D from stack-relative value 8,s
                    addd      #-1       ; add immediate value -1 into D
                    std       8,s       ; store D to stack-relative value 8,s
                    subd      #-1       ; subtract immediate value -1 from D
                    bgt       Loop_01   ; branch if greater than to Loop_01
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
