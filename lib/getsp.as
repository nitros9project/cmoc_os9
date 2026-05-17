* Adapted from cmoc_os9/lib/todo/getsp.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_getsp              EXPORT              ; export this symbol

_getsp
                    leax      2,s       ; above return
                    tfr       x,d       ; get in primary register
                    rts                 ; return to caller

                    endsect             ; end current section
