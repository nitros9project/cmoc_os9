* CMOC long increment/decrement helper ABI: X points at the 32-bit lvalue to
* update in place. The helper does not consume a stacked long operand.

                    section   code      ; begin code section

_linc               EXPORT    ;         export this symbol
_ldec               EXPORT    ;         export this symbol

_linc:              ldd       #1        ; start a one-count increment for the low word
                    addd      2,x       ; add one to the low word and set carry on wrap
                    std       2,x       ; store the updated low word
                    ldd       ,x        ; load the high word for carry propagation
                    adcb      #0        ; add the low-word carry into the high word low byte
                    adca      #0        ; propagate carry through the high word high byte
                    std       ,x        ; store the updated high word
                    rts                 ; return to caller
_ldec:              ldd       2,x       ; load the low word for decrement
                    subd      #1        ; subtract one and set borrow on underflow
                    std       2,x       ; store the updated low word
                    ldd       ,x        ; load the high word for borrow propagation
                    sbcb      #0        ; subtract the low-word borrow from the high word low byte
                    sbca      #0        ; propagate borrow through the high word high byte
                    std       ,x        ; store the updated high word
                    rts                 ; return to caller

                    endsect   ;         end current section
