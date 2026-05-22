* CMOC long conversion helper ABI: D holds the 16-bit source value, _flacc is
* the 32-bit result buffer, and X returns pointing at _flacc.

                    section   code      ; begin code section

_flacc              EXTERNAL  ;         import external symbol

_litol              EXPORT    ;         export this symbol
_lutol              EXPORT    ;         export this symbol

_litol:             leax      _flacc,y  ; point X at the shared 32-bit result buffer
                    std       2,x       ; store the 16-bit source as the low word
                    tfr       a,b       ; copy the source sign byte before sign extension
                    sex                 ; expand the sign bit into a full byte
                    tfr       a,b       ; duplicate the sign byte across the high word
                    std       ,x        ; store the sign-filled high word
                    rts                 ; return to caller
_lutol:             leax      _flacc,y  ; point X at the shared 32-bit result buffer
                    std       2,x       ; store the unsigned 16-bit value as the low word
                    clr       ,x        ; zero the high word's most significant byte
                    clr       1,x       ; zero the high word's least significant byte
                    rts                 ; return to caller

                    endsect   ;         end current section
