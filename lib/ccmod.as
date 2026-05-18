                    section   bss       ; begin bss section

* Uninitialized data (class B)
mod_sign_adjust     rmb       1         ; remember when signed remainder needs negation
mod_div_helper      rmb       2         ; selected 16-bit division helper entry point
* Initialized Data (class G)

                    endsect   ;         end current section

                    section   code      ; begin code section

ccdiv               EXTERNAL  ;         import external symbol
ccudiv              EXTERNAL  ;         import external symbol

ccumod              EXPORT    ;         export this symbol
ccmod               EXPORT    ;         export this symbol

ccumod:
stk_ccmod_ret       equ       0         ; caller return address
stk_ccmod_dividend  equ       2         ; stacked dividend operand
                    clr       mod_sign_adjust,y ; unsigned remainder never needs sign correction
                    leax      ccudiv,pcr ; compute the address of the unsigned division helper
                    stx       mod_div_helper,y ; remember which division routine this entry point should call
                    bra       BranchTarget_01 ; share the common division/modulus body
ccmod:              leax      ccdiv,pcr ; select signed division helper
                    stx       mod_div_helper,y ; remember which signed division helper should be called
                    clr       mod_sign_adjust,y ; clear the sign-adjust flag before inspecting the dividend
                    tst       stk_ccmod_dividend,s ; inspect dividend sign
                    bpl       BranchTarget_01 ; skip sign correction when the dividend is already non-negative
                    inc       mod_sign_adjust,y ; record that the final remainder needs sign correction
BranchTarget_01     subd      #0        ; test whether the divisor in D is zero
                    bne       BranchTarget_02 ; branch to the shared division path when the divisor is non-zero
                    puls      x         ; discard the return address saved for the helper trampoline
                    ldd       ,s++      ; remove dividend and leave S at the caller's caller frame
                    jmp       ,x        ; tail-jump to the caller's divide-by-zero handler
BranchTarget_02     ldx       stk_ccmod_dividend,s ; copy dividend for the selected divide helper
                    pshs      x         ; pass copied dividend as helper's stacked operand
                    jsr       [mod_div_helper,y] ; call the selected signed or unsigned division routine
                    ldd       stk_ccmod_ret,s ; reload caller return address after helper restored the stack
                    std       stk_ccmod_dividend,s ; move return address over original dividend
                    tfr       x,d       ; move the remainder from X into D for the final return value
                    tst       mod_sign_adjust,y ; test whether the remainder must be negated to match a signed dividend
                    beq       BranchTarget_03 ; leave the remainder alone for unsigned or non-negative input
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; propagate the two-byte negation carry into the high byte
BranchTarget_03     std       ,s++      ; store remainder at stk_ccmod_ret and advance to relocated return address
                    rts                 ; return to caller

                    endsect   ;         end current section
