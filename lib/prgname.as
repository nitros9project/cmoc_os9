                    section   code      ; begin code section

argv                EXTERN              ; import external symbol

__prgname           EXPORT              ; export this symbol
__prgname
                    ldd       argv,y    ; load D from indexed value argv,y
                    rts                 ; return to caller

                    endsect             ; end current section
