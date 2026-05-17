                    section   code      ; begin code section

_flacc              EXTERNAL            ; import external symbol
_lbexit             EXTERNAL            ; import external symbol

_ladd               EXPORT              ; export this symbol
_lsub               EXPORT              ; export this symbol

_ladd:              ldd       4,s       ; load D from stack-relative value 4,s
                    addd      2,x       ; add indexed value 2,x into D
                    std       _flacc+2,y ; store D to indexed value _flacc+2,y
                    ldd       2,s       ; load D from stack-relative value 2,s
                    adcb      1,x       ; add indexed value 1,x into B
                    adca      ,x        ; add memory pointed to by X into A
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    lbra      _lbexit   ; long branch unconditionally to _lbexit
_lsub:              ldd       4,s       ; load D from stack-relative value 4,s
                    subd      2,x       ; subtract indexed value 2,x from D
                    std       _flacc+2,y ; store D to indexed value _flacc+2,y
                    ldd       2,s       ; load D from stack-relative value 2,s
                    sbcb      1,x       ; subtract indexed value 1,x from B
                    sbca      ,x        ; subtract memory pointed to by X from A
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    lbra      _lbexit   ; long branch unconditionally to _lbexit

                    endsect             ; end current section

