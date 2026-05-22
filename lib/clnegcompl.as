* CMOC unary long helper ABI: X points at the source/result long. _lneg first
* copies X into _flacc and then negates in place; _lnegx negates X in place;
* _lcompl writes the one's-complement result to _flacc and returns X=_flacc.

                    section   code      ; begin code section

_flacc              EXTERNAL  ;         import external symbol
_ltoacc             EXTERNAL  ;         import external symbol

_lneg               EXPORT    ;         export this symbol
_lnegx              EXPORT    ;         export this symbol
_lcompl             EXPORT    ;         export this symbol

_lneg:              lbsr      _ltoacc   ; copy the source long into _flacc before negating it
_lnegx:             ldd       #0        ; start two's-complement negation with zero low word
                    subd      2,x       ; compute the negated low word and set borrow as needed
                    std       2,x       ; store the negated low word
                    ldd       #0        ; start the high-word subtract with zero
                    sbcb      1,x       ; subtract high-word low byte plus borrow
                    sbca      ,x        ; subtract high-word high byte plus borrow
                    std       ,x        ; store the negated high word
                    rts                 ; return to caller
_lcompl:            ldd       ,x        ; load the source high word
                    coma                ; invert high byte bits
                    comb                ; invert low byte bits
                    std       _flacc,y  ; store complemented high word in result buffer
                    ldd       2,x       ; load the source low word
                    coma                ; invert high byte of low word
                    comb                ; invert low byte of low word
                    leax      _flacc,y  ; return X pointing at the result buffer
                    std       2,x       ; store complemented low word
                    rts                 ; return to caller

                    endsect   ;         end current section
