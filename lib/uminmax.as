* Adapted from cmoc_os9/lib/todo/uminmax.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_umin               EXPORT              ; export this symbol
_umax               EXPORT              ; export this symbol

_umin
                    ldd       2,s       ; load D from stack-relative value 2,s
                    cmpd      4,s       ; compare D against stack-relative value 4,s
                    bls       Return_01 ; branch if lower or same to Return_01
                    ldd       4,s       ; load D from stack-relative value 4,s
Return_01           rts                 ; return to caller

_umax
                    ldd       2,s       ; load D from stack-relative value 2,s
                    cmpd      4,s       ; compare D against stack-relative value 4,s
                    bcc       Return_02 ; branch if carry is clear to Return_02
                    ldd       4,s       ; load D from stack-relative value 4,s
Return_02           rts                 ; return to caller

                    endsect             ; end current section
