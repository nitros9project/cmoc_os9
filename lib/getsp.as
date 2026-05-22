* Adapted from cmoc_os9/lib/todo/getsp.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_getsp              EXPORT    ;         export this symbol

_getsp:
stk_getsp_ret       equ       0         ; caller return address
                    leax      stk_getsp_ret+2,s ; compute caller's stack pointer above return address
                    tfr       x,d       ; return stack pointer in D
                    rts                 ; return to caller

                    endsect   ;         end current section
