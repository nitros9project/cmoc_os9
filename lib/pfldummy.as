_pflong             EXPORT              ; export non-float long-format helper
_pfldata            EXPORT              ; export default format suffix buffer

                    section   rwdata    ; begin writable data section

_pfldata
                    fcc       "lx"      ; default "long hexadecimal" suffix text
                    fcb       $00       ; null terminator for the suffix string

                    endsect             ; end writable data section

                    section   code      ; begin code section

_pflong
                    leax      _pfldata+2,y ; point X just past the default suffix
                    cmpb      #'d'      ; accept decimal long specifier unchanged
                    beq       L000f     ; keep default pointer for known format
                    cmpb      #'o'      ; accept octal long specifier unchanged
                    beq       L000f     ; keep default pointer for known format
                    cmpb      #'x'      ; accept lowercase hex long specifier unchanged
                    beq       L000f     ; keep default pointer for known format
                    cmpb      #'X'      ; accept uppercase hex long specifier unchanged
                    beq       L000f     ; keep default pointer for known format
                    leax      -2,x      ; fall back to the start of the suffix buffer
                    stb       1,x       ; patch the requested format letter into the buffer
L000f               tfr       x,d       ; return pointer to selected suffix string
                    rts                 ; return to caller

                    endsect             ; end code section
