                    section   code      ; begin code section

_tidyup             EXPORT    ;         export runtime cleanup hook

_tidyup:
stk_tidyup_ret      equ       0         ; caller return address
                    rts                 ; no cleanup hooks are registered here

                    endsect   ;         end current section
