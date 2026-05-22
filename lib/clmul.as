* CMOC long multiply helper ABI: X points at one 32-bit operand, the other
* 32-bit operand is on the caller stack, and the product is written to _flacc.
* Tail-call _lbexit to restore the caller's long stack frame and return X=_flacc.

                    section   code      ; begin code section

_flacc              EXTERNAL  ;         import external symbol
_lbexit             EXTERNAL  ;         import external symbol

_lmul               EXPORT    ;         export this symbol

_lmul:
stk_lmul_ret        equ       0         ; caller return address
stk_lmul_lhs_hi     equ       2         ; stacked left operand, bits 31-16
stk_lmul_lhs_lo     equ       4         ; stacked left operand, bits 15-0
stk_lmul_rhs_hi     equ       0         ; right operand high word after both PSHS D operations
stk_lmul_rhs_lo     equ       2         ; right operand low word after both PSHS D operations
                    ldd       2,x       ; copy right operand low word before X is repurposed
                    pshs      d         ; save right operand low word; stack shifts by 2 bytes
                    ldd       ,x        ; copy right operand high word
                    pshs      d         ; save right operand high word; original frame is now +4 bytes
                    leax      _flacc,y  ; accumulate the product in the shared result buffer
                    clr       ,x        ; clear product byte 0
                    clr       1,x       ; clear product byte 1
                    lda       stk_lmul_lhs_lo+5,s ; left byte 3 after saved right operand
                    ldb       stk_lmul_rhs_lo+1,s ; right byte 3 from saved right operand
                    mul                 ; multiply A by B and leave the product in D
                    std       2,x       ; seed product bytes 2-3
                    lda       stk_lmul_lhs_lo+5,s ; left byte 3 after saved right operand
                    ldb       stk_lmul_rhs_lo,s ; right byte 2 from saved right operand
                    mul                 ; multiply A by B and leave the product in D
                    addd      1,x       ; add partial product into bytes 1-2
                    std       1,x       ; store updated bytes 1-2
                    bcc       BranchTarget_01 ; skip carry propagation when byte 1 did not overflow
                    inc       ,x        ; propagate carry into product byte 0
BranchTarget_01     lda       stk_lmul_lhs_lo+4,s ; left byte 2 after saved right operand
                    ldb       stk_lmul_rhs_lo+1,s ; right byte 3 from saved right operand
                    mul                 ; multiply A by B and leave the product in D
                    addd      1,x       ; add partial product into bytes 1-2
                    std       1,x       ; store updated bytes 1-2
                    bcc       BranchTarget_02 ; skip carry propagation when byte 1 did not overflow
                    inc       ,x        ; propagate carry into product byte 0
BranchTarget_02     lda       stk_lmul_lhs_lo+5,s ; left byte 3 after saved right operand
                    ldb       stk_lmul_rhs_hi+1,s ; right byte 1 from saved right operand
                    mul                 ; multiply A by B and leave the product in D
                    addd      ,x        ; add partial product into bytes 0-1
                    std       ,x        ; store updated bytes 0-1
                    lda       stk_lmul_lhs_lo+4,s ; left byte 2 after saved right operand
                    ldb       stk_lmul_rhs_lo,s ; right byte 2 from saved right operand
                    mul                 ; multiply A by B and leave the product in D
                    addd      ,x        ; add partial product into bytes 0-1
                    std       ,x        ; store updated bytes 0-1
                    lda       stk_lmul_lhs_hi+5,s ; left byte 1 after saved right operand
                    ldb       stk_lmul_rhs_lo+1,s ; right byte 3 from saved right operand
                    mul                 ; multiply A by B and leave the product in D
                    addd      ,x        ; add partial product into bytes 0-1
                    std       ,x        ; store updated bytes 0-1
                    lda       stk_lmul_lhs_lo+5,s ; left byte 3 after saved right operand
                    ldb       stk_lmul_rhs_hi,s ; right byte 0 from saved right operand
                    mul                 ; multiply A by B and leave the product in D
                    addb      ,x        ; add high-byte contribution into product byte 0
                    stb       ,x        ; store updated product byte 0
                    lda       stk_lmul_lhs_lo+4,s ; left byte 2 after saved right operand
                    ldb       stk_lmul_rhs_hi+1,s ; right byte 1 from saved right operand
                    mul                 ; multiply A by B and leave the product in D
                    addb      ,x        ; add high-byte contribution into product byte 0
                    stb       ,x        ; store updated product byte 0
                    lda       stk_lmul_lhs_hi+5,s ; left byte 1 after saved right operand
                    ldb       stk_lmul_rhs_lo,s ; right byte 2 from saved right operand
                    mul                 ; multiply A by B and leave the product in D
                    addb      ,x        ; add high-byte contribution into product byte 0
                    stb       ,x        ; store updated product byte 0
                    lda       stk_lmul_lhs_hi+4,s ; left byte 0 after saved right operand
                    ldb       stk_lmul_rhs_lo+1,s ; right byte 3 from saved right operand
                    mul                 ; multiply A by B and leave the product in D
                    addb      ,x        ; add high-byte contribution into product byte 0
                    stb       ,x        ; store updated product byte 0
                    leas      stk_lmul_lhs_lo,s ; discard saved right operand and restore original helper frame
                    lbra      _lbexit   ; repair caller stack and return X=_flacc

                    endsect   ;         end current section
