* Adapted from cmoc_os9/lib/todo/ltol3.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_ltol3              EXPORT              ; export this symbol

_ltol3
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    leau      1,u       ; compute effective address into U from 1,u
                    bra       Continue_01 ; branch unconditionally to Continue_01
Loop_01             ldx       6,s       ; load X from stack-relative value 6,s
                    ldb       1,x       ; load B from indexed value 1,x
                    stb       -1,u      ; store B to indexed value -1,u
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldd       2,x       ; load D from indexed value 2,x
                    std       ,u        ; store D to memory pointed to by U
                    ldd       6,s       ; load D from stack-relative value 6,s
                    addd      #4        ; add immediate value 4 into D
                    std       6,s       ; store D to stack-relative value 6,s
                    leau      3,u       ; compute effective address into U from 3,u
Continue_01         ldd       8,s       ; load D from stack-relative value 8,s
                    addd      #-1       ; add immediate value -1 into D
                    std       8,s       ; store D to stack-relative value 8,s
                    subd      #-1       ; subtract immediate value -1 from D
                    bgt       Loop_01   ; branch if greater than to Loop_01
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
