* Compact assembly implementation of abs().

                    section   code      ; begin code section

_abs                EXPORT              ; export this symbol

_abs
stk_abs_ret         equ       0         ; caller return address
stk_abs_value       equ       2         ; signed 16-bit input value
                    ldd       stk_abs_value,s ; fetch the signed argument
                    bpl       L_abs_done ; non-negative values are already absolute
                    nega                ; begin 16-bit two's-complement negation
                    negb                ; negate the low byte
                    sbca      #0        ; fold the low-byte borrow into the high byte
L_abs_done
                    rts                 ; return to caller

                    endsect             ; end current section
