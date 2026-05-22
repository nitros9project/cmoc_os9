                    section   code      ; begin code section

ccmult              EXPORT    ;         export this symbol

ccmult:
stk_ccmult_ret      equ       0         ; caller return address
stk_ccmult_rhs      equ       2         ; stacked 16-bit right operand
stk_ccmult_acc_hi   equ       0         ; high word of 32-bit product after scratch frame is built
stk_ccmult_acc_lo   equ       2         ; low word of 32-bit product after scratch frame is built
stk_ccmult_lhs      equ       4         ; saved left operand after scratch frame is built
stk_ccmult_saved_ret equ       6         ; caller return address after scratch frame is built
stk_ccmult_rhs_work equ       8         ; stacked right operand after scratch frame is built
                    tsta                ; use faster 8x8 path when left high byte is zero
                    bne       BranchTarget_01 ; use full multiply when left operand exceeds 8 bits
                    tst       stk_ccmult_rhs,s ; use full multiply when right high byte is non-zero
                    bne       BranchTarget_01 ; use full multiply for a 16-bit right operand
                    lda       stk_ccmult_rhs+1,s ; load right low byte for 8x8 multiply
                    mul                 ; multiply right low byte by left low byte in B
                    ldx       stk_ccmult_ret,s ; fetch caller return address
                    stx       stk_ccmult_rhs,s ; move return address over consumed right operand
                    ldx       #0        ; high word of 8x8 product is zero
                    std       stk_ccmult_ret,s ; place low product word for final PULS D,PC
                    puls      d,pc      ; return X:D 32-bit product
BranchTarget_01     pshs      d         ; save left operand; original frame shifts by 2 bytes
                    ldd       #0        ; clear D for product accumulator initialization
                    pshs      d         ; allocate and clear product low word
                    pshs      d         ; allocate and clear product high word
                    lda       stk_ccmult_lhs+1,s ; left low byte
                    ldb       stk_ccmult_rhs_work+1,s ; right low byte
                    mul                 ; compute low-byte partial product
                    std       stk_ccmult_acc_lo,s ; store low product word
                    lda       stk_ccmult_lhs+1,s ; left low byte
                    ldb       stk_ccmult_rhs_work,s ; right high byte
                    mul                 ; compute cross product for middle bytes
                    addd      stk_ccmult_acc_hi+1,s ; add into product bytes 1-2
                    std       stk_ccmult_acc_hi+1,s ; store updated middle product bytes
                    bcc       BranchTarget_02 ; branch if carry is clear to BranchTarget_02
                    inc       stk_ccmult_acc_hi,s ; propagate carry into product high byte
BranchTarget_02     lda       stk_ccmult_lhs,s ; left high byte
                    ldb       stk_ccmult_rhs_work+1,s ; right low byte
                    mul                 ; compute other cross product for middle bytes
                    addd      stk_ccmult_acc_hi+1,s ; add into product bytes 1-2
                    std       stk_ccmult_acc_hi+1,s ; store updated middle product bytes
                    bcc       BranchTarget_03 ; branch if carry is clear to BranchTarget_03
                    inc       stk_ccmult_acc_hi,s ; propagate carry into product high byte
BranchTarget_03     lda       stk_ccmult_lhs,s ; left high byte
                    ldb       stk_ccmult_rhs_work,s ; right high byte
                    mul                 ; compute high-byte partial product
                    addd      stk_ccmult_acc_hi,s ; add into high product word
                    std       stk_ccmult_acc_hi,s ; store final high product word
                    ldx       stk_ccmult_saved_ret,s ; fetch caller return address
                    stx       stk_ccmult_rhs_work,s ; move return address over consumed right operand
                    ldx       stk_ccmult_acc_hi,s ; return high product word in X
                    ldd       stk_ccmult_acc_lo,s ; return low product word in D
                    leas      stk_ccmult_rhs_work,s ; discard scratch frame and saved left operand
                    rts                 ; return to caller

                    endsect   ;         end current section
