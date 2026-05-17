                    section   code      ; begin code section

_linc               EXPORT              ; export this symbol
_ldec               EXPORT              ; export this symbol

_linc:              ldd       #1        ; load D from immediate value 1
                    addd      2,x       ; add indexed value 2,x into D
                    std       2,x       ; store D to indexed value 2,x
                    ldd       ,x        ; load D from memory pointed to by X
                    adcb      #0        ; add immediate value 0 into B
                    adca      #0        ; add immediate value 0 into A
                    std       ,x        ; store D to memory pointed to by X
                    rts                 ; return to caller
_ldec:              ldd       2,x       ; load D from indexed value 2,x
                    subd      #1        ; subtract immediate value 1 from D
                    std       2,x       ; store D to indexed value 2,x
                    ldd       ,x        ; load D from memory pointed to by X
                    sbcb      #0        ; subtract immediate value 0 from B
                    sbca      #0        ; subtract immediate value 0 from A
                    std       ,x        ; store D to memory pointed to by X
                    rts                 ; return to caller

                    endsect             ; end current section

