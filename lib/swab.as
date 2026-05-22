* Adapted from cmoc_os9/lib/ported/swab.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_swab               EXPORT    ;         export byte-swap helper

_swab:
stk_swab_ret        equ       0         ; caller return address
stk_swab_value      equ       2         ; 16-bit value to byte-swap
                    ldd       stk_swab_value,s ; load input value
                    exg       a,b       ; swap high and low bytes
                    rts                 ; return to caller

                    endsect   ;         end current section
