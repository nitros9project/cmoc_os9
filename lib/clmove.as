                    section   code      ; begin code section

_lmove              EXPORT              ; export this symbol

_lmove:             pshs      y         ; save Y on the hardware stack
                    ldy       4,s       ; load Y from stack-relative value 4,s
                    ldd       ,x        ; load D from memory pointed to by X
                    std       ,y        ; store D to memory pointed to by Y
                    ldd       2,x       ; load D from indexed value 2,x
                    std       2,y       ; store D to indexed value 2,y
                    puls      x         ; restore X from the hardware stack
                    exg       y,x       ; exchange Y,X
                    puls      d         ; restore D from the hardware stack
                    std       ,s        ; store D to memory pointed to by S
                    rts                 ; return to caller

                    endsect             ; end current section

