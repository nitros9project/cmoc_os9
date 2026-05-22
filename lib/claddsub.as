* CMOC long helper ABI: X points at one 32-bit operand, the other 32-bit
* operand is on the caller stack, and the result is written to _flacc.
* Tail-call _lbexit to restore the caller's long stack frame and return X=_flacc.

                    section   code      ; begin code section

_flacc              EXTERNAL  ;         import external symbol
_lbexit             EXTERNAL  ;         import external symbol

_ladd               EXPORT    ;         export this symbol
_lsub               EXPORT    ;         export this symbol

_ladd:
stk_ladd_ret        equ       0         ; caller return address
stk_ladd_lhs_hi     equ       2         ; stacked left operand, bits 31-16
stk_ladd_lhs_lo     equ       4         ; stacked left operand, bits 15-0
                    ldd       stk_ladd_lhs_lo,s ; add low words first
                    addd      2,x       ; add right operand low word
                    std       _flacc+2,y ; store result low word
                    ldd       stk_ladd_lhs_hi,s ; add high words with carry from low word
                    adcb      1,x       ; add right operand high-word low byte plus carry
                    adca      ,x        ; add right operand high-word high byte plus carry
                    std       _flacc,y  ; store result high word
                    lbra      _lbexit   ; repair caller stack and return X=_flacc
_lsub:
stk_lsub_ret        equ       0         ; caller return address
stk_lsub_lhs_hi     equ       2         ; stacked left operand, bits 31-16
stk_lsub_lhs_lo     equ       4         ; stacked left operand, bits 15-0
                    ldd       stk_lsub_lhs_lo,s ; subtract low words first
                    subd      2,x       ; subtract right operand low word
                    std       _flacc+2,y ; store result low word
                    ldd       stk_lsub_lhs_hi,s ; subtract high words with borrow from low word
                    sbcb      1,x       ; subtract right operand high-word low byte plus borrow
                    sbca      ,x        ; subtract right operand high-word high byte plus borrow
                    std       _flacc,y  ; store result high word
                    lbra      _lbexit   ; repair caller stack and return X=_flacc

                    endsect   ;         end current section
