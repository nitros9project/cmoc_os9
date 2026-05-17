                    section   code      ; begin code section

_pffloat            EXPORT              ; export this symbol
_pffloat
                    leax      >Label_01,pcr ; compute effective address into X from >Label_01,pcr
                    tfr       x,d       ; transfer X,D
                    rts                 ; return to caller

Label_01            fcb       $00       ; define byte data $00

                    endsect             ; end current section
