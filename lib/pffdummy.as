                    section   code      ; begin code section

_pffloat            EXPORT    ;         export no-float printf formatter stub
_pffloat:
stk_pffloat_ret     equ       0         ; caller return address
stk_pffloat_spec    equ       2         ; unused format specifier argument
stk_pffloat_args    equ       4         ; unused vararg pointer argument
                    leax      >empty_float_string,pcr ; return pointer to an empty replacement string
                    tfr       x,d       ; place string pointer in D for the C caller
                    rts                 ; return no float-format text

empty_float_string  fcb       $00       ; empty C string returned when float support is absent

                    endsect   ;         end current section
