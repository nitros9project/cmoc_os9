* Compact assembly implementation of abs().

                    section   code      ; begin code section

_abs                EXPORT              ; export this symbol

_abs
                    ldd       2,s       ; load D from stack-relative value 2,s
                    bpl       L_abs_done ; branch if plus to L_abs_done
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
L_abs_done
                    rts                 ; return to caller

                    endsect             ; end current section
