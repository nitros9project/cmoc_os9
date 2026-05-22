* CMOC long comparison helper ABI: X points at one 32-bit operand and the
* other 32-bit operand is on the caller stack. The helper returns condition
* codes for the comparison while removing the stacked long operand.

                    section   code      ; begin code section

_lcmpr              EXPORT    ;         export this symbol

_lcmpr:
stk_lcmpr_ret       equ       0         ; caller return address
stk_lcmpr_lhs_hi    equ       2         ; stacked left operand, bits 31-16
stk_lcmpr_lhs_lo    equ       4         ; stacked left operand, bits 15-0
                    ldd       stk_lcmpr_lhs_hi,s ; compare high words first
                    cmpd      ,x        ; compare against right operand high word
                    bne       BranchTarget_02 ; high words decide the comparison
                    ldd       stk_lcmpr_lhs_lo,s ; high words match; compare low words
                    cmpd      2,x       ; compare against right operand low word
                    beq       BranchTarget_02 ; low words matched, so equality is true
                    bcs       BranchTarget_01 ; synthesize negative flags when lhs < rhs
                    lda       #1        ; synthesize positive flags when lhs > rhs
                    andcc     #254      ; clear carry before the synthetic positive compare
                    bra       BranchTarget_02 ; preserve synthetic positive flags
BranchTarget_01     clra                ; prepare a zero value for signed flag synthesis
                    cmpa      #1        ; set negative/carry as if lhs was smaller
BranchTarget_02     pshs      cc        ; save comparison flags while moving the return address
                    ldd       stk_lcmpr_ret+1,s ; fetch caller return address after pushed CC byte
                    std       stk_lcmpr_lhs_lo+1,s ; move return address over consumed stacked long
                    puls      cc        ; restore comparison flags after stack repair
                    leas      stk_lcmpr_lhs_lo,s ; discard consumed stacked long
                    rts                 ; return to caller

                    endsect   ;         end current section
