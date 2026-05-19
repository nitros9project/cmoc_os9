                    section   bss       ; begin bss section

_flacc              EXPORT    ;         export this symbol
_flacc:             rmb       8         ; shared floating-point and long accumulator storage

                    endsect   ;         end current section
