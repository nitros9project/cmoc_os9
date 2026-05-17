                    section   bss       ; begin bss section

_flacc              EXPORT              ; export this symbol
_flacc:             rmb       8         ; reserve 8 bytes for the shared floating-point and long accumulator

                    endsect             ; end current section
