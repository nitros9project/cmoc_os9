* Adapted from cmoc_os9/lib/ported/swab.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_swab               EXPORT              ; export this symbol

_swab
                    ldd       2,s       ; load D from stack-relative value 2,s
                    exg       a,b       ; exchange A,B
                    rts                 ; return to caller

                    endsect             ; end current section
