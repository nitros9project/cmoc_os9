                    SECTION   code      ; begin code section

MUL168              EXPORT              ; export this symbol

* Multiply unsigned 8-bit b by unsigned 16-bit x and return the 16-bit product in d.
* The routine preserves x by saving it on the stack and uses the saved bytes as scratch.
MUL168              pshs      x,b,a     ; save x and b, and reserve one scratch byte at ,s
                    lda       2,s       ; load the high byte of the saved x value
                    mul                 ; multiply b by the high byte and leave the partial product in d
                    stb       ,s        ; keep the low byte of the high-byte partial product as the carry-in
                    ldb       1,s       ; reload the original multiplier from the saved b byte
                    lda       3,s       ; load the low byte of the saved x value
                    mul                 ; multiply b by the low byte and leave the main product in d
                    adda      ,s        ; add in the shifted high-byte partial product
                    leas      4,s       ; discard the saved registers and scratch byte
                    rts                 ; return with the 16-bit product in d

                    ENDSECTION           ; end current section
