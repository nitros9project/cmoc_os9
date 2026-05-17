                    section   code      ; begin code section

_flacc              EXTERNAL            ; import external symbol
_lbexit             EXPORT              ; export this symbol
_ltoacc             EXPORT              ; export this symbol

_lbexit:            tfr       cc,a      ; transfer CC,A
                    puls      x         ; restore X from the hardware stack
                    stx       2,s       ; store X to stack-relative value 2,s
                    leas      2,s       ; adjust S using 2,s
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    tfr       a,cc      ; transfer A,CC
                    rts                 ; return to caller
_ltoacc:            ldd       ,x        ; load D from memory pointed to by X
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    ldd       2,x       ; load D from indexed value 2,x
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       2,x       ; store D to indexed value 2,x
                    rts                 ; return to caller

                    endsect             ; end current section

