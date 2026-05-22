* CMOC long helper ABI: X points at one 32-bit operand, the other 32-bit
* operand is on the caller stack, and binary results are written to _flacc.
* Helpers that consume a stacked long tail-call _lbexit to restore the frame.

                    section   code      ; begin code section

_flacc              EXTERNAL  ;         import external symbol
_lbexit             EXTERNAL  ;         import external symbol

_land               EXPORT    ;         export this symbol
_lor                EXPORT    ;         export this symbol
_lxor               EXPORT    ;         export this symbol
_lnot               EXPORT    ;         export this symbol

_land:
stk_land_ret        equ       0         ; caller return address
stk_land_lhs_hi     equ       2         ; stacked left operand, bits 31-16
stk_land_lhs_lo     equ       4         ; stacked left operand, bits 15-0
                    ldd       stk_land_lhs_hi,s ; fetch high word of stacked operand
                    anda      ,x        ; combine high-word high bytes
                    andb      1,x       ; combine high-word low bytes
                    std       _flacc,y  ; store result high word
                    ldd       stk_land_lhs_lo,s ; fetch low word of stacked operand
                    anda      2,x       ; combine low-word high bytes
                    andb      3,x       ; combine low-word low bytes
                    std       _flacc+2,y ; store result low word
                    lbra      _lbexit   ; repair caller stack and return X=_flacc
_lor:
stk_lor_ret         equ       0         ; caller return address
stk_lor_lhs_hi      equ       2         ; stacked left operand, bits 31-16
stk_lor_lhs_lo      equ       4         ; stacked left operand, bits 15-0
                    ldd       stk_lor_lhs_hi,s ; fetch high word of stacked operand
                    ora       ,x        ; combine high-word high bytes
                    orb       1,x       ; combine high-word low bytes
                    std       _flacc,y  ; store result high word
                    ldd       stk_lor_lhs_lo,s ; fetch low word of stacked operand
                    ora       2,x       ; combine low-word high bytes
                    orb       3,x       ; combine low-word low bytes
                    std       _flacc+2,y ; store result low word
                    lbra      _lbexit   ; repair caller stack and return X=_flacc
_lxor:
stk_lxor_ret        equ       0         ; caller return address
stk_lxor_lhs_hi     equ       2         ; stacked left operand, bits 31-16
stk_lxor_lhs_lo     equ       4         ; stacked left operand, bits 15-0
                    ldd       stk_lxor_lhs_hi,s ; fetch high word of stacked operand
                    eora      ,x        ; combine high-word high bytes
                    eorb      1,x       ; combine high-word low bytes
                    std       _flacc,y  ; store result high word
                    ldd       stk_lxor_lhs_lo,s ; fetch low word of stacked operand
                    eora      2,x       ; combine low-word high bytes
                    eorb      3,x       ; combine low-word low bytes
                    std       _flacc+2,y ; store result low word
                    lbra      _lbexit   ; repair caller stack and return X=_flacc
_lnot:              lda       ,x        ; start zero test with high byte
                    ora       1,x       ; include high-word low byte
                    ora       2,x       ; include low-word high byte
                    ora       3,x       ; include low-word low byte
                    beq       BranchTarget_01 ; return true when every byte is zero
                    clrb                ; return false low byte
                    clra                ; return false high byte
                    rts                 ; return to caller
BranchTarget_01     ldd       #1        ; return true for logical not of zero
                    rts                 ; return to caller

                    endsect   ;         end current section
