                    section   bss       ; begin bss section

* Uninitialized data (class B)
B0000               rmb       1         ; reserve 1 bytes
B0001               rmb       2         ; reserve 2 bytes
* Initialized Data (class G)

                    endsect             ; end current section

                    section   code      ; begin code section

ccdiv               EXTERNAL            ; import external symbol
ccudiv              EXTERNAL            ; import external symbol

ccumod              EXPORT              ; export this symbol
ccmod               EXPORT              ; export this symbol

ccumod:             clr       B0000,y   ; clear indexed value B0000,y
                    leax      ccudiv,pcr ; compute the address of the unsigned division helper
                    stx       B0001,y   ; remember which division routine this entry point should call
                    bra       BranchTarget_01 ; share the common division/modulus body
ccmod:              leax      ccdiv,pcr ; compute effective address into X from ccdiv,pcr
                    stx       B0001,y   ; remember which signed division helper should be called
                    clr       B0000,y   ; clear the sign-adjust flag before inspecting the dividend
                    tst       2,s       ; test stack-relative value 2,s and update condition codes
                    bpl       BranchTarget_01 ; skip sign correction when the dividend is already non-negative
                    inc       B0000,y   ; record that the final remainder needs sign correction
BranchTarget_01     subd      #0        ; test whether the divisor in D is zero
                    bne       BranchTarget_02 ; branch to the shared division path when the divisor is non-zero
                    puls      x         ; discard the return address saved for the helper trampoline
                    ldd       ,s++      ; load D from memory pointed to by S+, then advance S+
                    jmp       ,x        ; tail-jump to the caller's divide-by-zero handler
BranchTarget_02     ldx       2,s       ; load X from stack-relative value 2,s
                    pshs      x         ; preserve the original dividend pointer for the helper call
                    jsr       [B0001,y] ; call the selected signed or unsigned division routine
                    ldd       ,s        ; load D from memory pointed to by S
                    std       2,s       ; write the computed quotient back into the caller's stack frame
                    tfr       x,d       ; move the remainder from X into D for the final return value
                    tst       B0000,y   ; test whether the remainder must be negated to match a signed dividend
                    beq       BranchTarget_03 ; leave the remainder alone for unsigned or non-negative input
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; propagate the two-byte negation carry into the high byte
BranchTarget_03     std       ,s++      ; store the final remainder into the caller's saved D slot
                    rts                 ; return to caller

                    endsect             ; end current section
