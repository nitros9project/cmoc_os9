* Adapted from cmoc_os9/lib/todo/uminmax.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_umin               EXPORT    ;         export unsigned minimum helper
_umax               EXPORT    ;         export unsigned maximum helper

_umin:
stk_umin_ret        equ       0         ; caller return address
stk_umin_lhs        equ       2         ; first unsigned int argument
stk_umin_rhs        equ       4         ; second unsigned int argument
                    ldd       stk_umin_lhs,s ; start with the first candidate
                    cmpd      stk_umin_rhs,s ; compare candidates as unsigned values
                    bls       Return_01 ; keep first value when it is lower or equal
                    ldd       stk_umin_rhs,s ; otherwise return the second value
Return_01           rts                 ; return selected unsigned minimum

_umax:
stk_umax_ret        equ       0         ; caller return address
stk_umax_lhs        equ       2         ; first unsigned int argument
stk_umax_rhs        equ       4         ; second unsigned int argument
                    ldd       stk_umax_lhs,s ; start with the first candidate
                    cmpd      stk_umax_rhs,s ; compare candidates as unsigned values
                    bcc       Return_02 ; keep first value when it is higher or equal
                    ldd       stk_umax_rhs,s ; otherwise return the second value
Return_02           rts                 ; return selected unsigned maximum

                    endsect   ;         end current section
