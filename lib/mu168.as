                    section   code      ; begin code section

MUL168              EXPORT    ;         export this symbol

* Multiply unsigned 8-bit b by unsigned 16-bit x and return the 16-bit product in d.
* Stack after pshs x,b,a:
*   0,s scratch byte for the high-byte partial product
*   1,s saved multiplier byte, originally in B
*   2,s saved multiplicand high byte, originally X high
*   3,s saved multiplicand low byte, originally X low
MUL168:
stk_mul168_partial  equ       0         ; scratch byte holding shifted high-byte partial product
stk_mul168_mult     equ       1         ; saved unsigned 8-bit multiplier
stk_mul168_x_hi     equ       2         ; saved high byte of the unsigned 16-bit multiplicand
stk_mul168_x_lo     equ       3         ; saved low byte of the unsigned 16-bit multiplicand
                    pshs      x,b,a     ; save X and B, and reserve A as one scratch byte
                    lda       stk_mul168_x_hi,s ; multiply B by the high byte of X first
                    mul                 ; compute high-byte partial product in D
                    stb       stk_mul168_partial,s ; keep shifted high-byte partial as carry into result high byte
                    ldb       stk_mul168_mult,s ; reload the original 8-bit multiplier
                    lda       stk_mul168_x_lo,s ; multiply by the low byte of X for the main product
                    mul                 ; compute low-byte partial product in D
                    adda      stk_mul168_partial,s ; add shifted high-byte partial into the result high byte
                    leas      4,s       ; discard saved operands and scratch byte
                    rts                 ; return with the 16-bit product in d

                    endsection ;         end current section
