                    section   code      ; begin code section

_flacc              EXTERNAL            ; import external symbol
_ltoacc             EXTERNAL            ; import external symbol

_lneg               EXPORT              ; export this symbol
_lnegx              EXPORT              ; export this symbol
_lcompl             EXPORT              ; export this symbol

_lneg:              lbsr      _ltoacc   ; long branch to subroutine to _ltoacc
_lnegx:             ldd       #0        ; load D from immediate value 0
                    subd      2,x       ; subtract indexed value 2,x from D
                    std       2,x       ; store D to indexed value 2,x
                    ldd       #0        ; load D from immediate value 0
                    sbcb      1,x       ; subtract indexed value 1,x from B
                    sbca      ,x        ; subtract memory pointed to by X from A
                    std       ,x        ; store D to memory pointed to by X
                    rts                 ; return to caller
_lcompl:            ldd       ,x        ; load D from memory pointed to by X
                    coma
                    comb
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    ldd       2,x       ; load D from indexed value 2,x
                    coma
                    comb
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       2,x       ; store D to indexed value 2,x
                    rts                 ; return to caller

                    endsect             ; end current section

