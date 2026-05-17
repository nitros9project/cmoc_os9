                    section   code      ; begin code section

_flacc              EXTERNAL            ; import external symbol

_litol              EXPORT              ; export this symbol
_lutol              EXPORT              ; export this symbol

_litol:             leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       2,x       ; store D to indexed value 2,x
                    tfr       a,b       ; transfer A,B
                    sex                 ; sign-extend B into A to form D
                    tfr       a,b       ; transfer A,B
                    std       ,x        ; store D to memory pointed to by X
                    rts                 ; return to caller
_lutol:             leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       2,x       ; store D to indexed value 2,x
                    clr       ,x        ; clear memory pointed to by X
                    clr       1,x       ; clear indexed value 1,x
                    rts                 ; return to caller

                    endsect             ; end current section

