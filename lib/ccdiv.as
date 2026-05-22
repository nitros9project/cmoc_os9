                    section   code      ; begin code section

_rpterr             EXTERNAL  ;         import external symbol

ccudiv              EXPORT    ;         export this symbol
ccdiv               EXPORT    ;         export this symbol

EDIVERR             equ       45        ; divide-by-zero runtime error
Carry               equ       %00000001 ; condition-code carry bit

ccudiv:
stk_ccdiv_ret       equ       0         ; caller return address before work frame is built
stk_ccdiv_dividend  equ       2         ; stacked dividend operand before work frame is built
stk_ccdiv_work_size equ       2         ; bytes reserved for count/sign before saved divisor
stk_ccdiv_count     equ       0         ; restoring-division loop count in work frame
stk_ccdiv_sign      equ       1         ; signed quotient-negation flag in work frame
stk_ccdiv_divisor   equ       2         ; normalized divisor in work frame
stk_ccdiv_saved_ret equ       4         ; caller return address in work frame
stk_ccdiv_quotient  equ       6         ; quotient/dividend slot in work frame
                    subd      #0        ; set Z if divisor is zero
                    beq       Loop_01   ; report divide-by-zero when divisor is zero
                    pshs      d         ; save divisor; original frame shifts by 2 bytes
                    leas      -stk_ccdiv_work_size,s ; allocate loop count and sign flag bytes
                    clr       stk_ccdiv_count,s ; clear loop count before normalization
                    clr       stk_ccdiv_sign,s ; unsigned divide never negates quotient
                    bra       BranchTarget_02 ; enter shared unsigned division core
Loop_01             puls      d         ; pull caller return address, leaving S at dividend
                    std       stk_ccdiv_dividend-2,s ; move return address over consumed dividend
                    ldd       #EDIVERR  ; report divide-by-zero through runtime error path
                    lbra      _rpterr   ; transfer control to runtime error handler
ccdiv:              subd      #0        ; set Z if divisor is zero
                    beq       Loop_01   ; report divide-by-zero when divisor is zero
                    pshs      d         ; save divisor; original frame shifts by 2 bytes
                    leas      -stk_ccdiv_work_size,s ; allocate loop count and sign flag bytes
                    clr       stk_ccdiv_count,s ; clear loop count before normalization
                    clr       stk_ccdiv_sign,s ; clear quotient sign flag
                    tsta                ; test divisor sign
                    bpl       BranchTarget_01 ; divisor is already positive
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; finish two-byte negation with borrow
                    com       stk_ccdiv_sign,s ; divisor sign flips final quotient sign
                    std       stk_ccdiv_divisor,s ; store absolute divisor
BranchTarget_01     ldd       stk_ccdiv_quotient,s ; load dividend from work-frame operand slot
                    bpl       BranchTarget_02 ; dividend is already positive
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; finish two-byte negation with borrow
                    com       stk_ccdiv_sign,s ; dividend sign flips final quotient sign
                    std       stk_ccdiv_quotient,s ; store absolute dividend
BranchTarget_02     lda       #1        ; initialize normalization shift count
Loop_02             inca                ; count another divisor left shift
                    asl       stk_ccdiv_divisor+1,s ; shift divisor low byte left
                    rol       stk_ccdiv_divisor,s ; rotate divisor high byte through carry
                    bpl       Loop_02   ; continue until divisor reaches the sign bit
                    sta       stk_ccdiv_count,s ; save number of division iterations
                    ldd       stk_ccdiv_quotient,s ; load normalized dividend as initial remainder
                    clr       stk_ccdiv_quotient,s ; clear quotient high byte
                    clr       stk_ccdiv_quotient+1,s ; clear quotient low byte
Loop_03             subd      stk_ccdiv_divisor,s ; subtract normalized divisor from remainder
                    bcc       BranchTarget_03 ; branch if carry is clear to BranchTarget_03
                    addd      stk_ccdiv_divisor,s ; restore remainder after failed subtract
                    andcc     #^Carry   ; clear quotient bit for this iteration
                    bra       Continue_01 ; merge with quotient rotation
BranchTarget_03     orcc      #Carry    ; set quotient bit for this iteration
Continue_01         rol       stk_ccdiv_quotient+1,s ; rotate quotient low byte through carry
                    rol       stk_ccdiv_quotient,s ; rotate quotient high byte through carry
                    lsr       stk_ccdiv_divisor,s ; shift divisor high byte right
                    ror       stk_ccdiv_divisor+1,s ; rotate divisor low byte through carry
                    dec       stk_ccdiv_count,s ; one restoring-division bit completed
                    bne       Loop_03   ; continue until all quotient bits are generated
                    std       stk_ccdiv_divisor,s ; keep final remainder in divisor slot for return
                    tst       stk_ccdiv_sign,s ; test whether signed quotient needs negation
                    beq       BranchTarget_04 ; leave unsigned or positive quotient unchanged
                    ldd       stk_ccdiv_quotient,s ; load quotient for two's-complement negation
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; finish two-byte negation with borrow
                    std       stk_ccdiv_quotient,s ; store signed quotient
BranchTarget_04     ldx       stk_ccdiv_saved_ret,s ; fetch caller return address
                    ldd       stk_ccdiv_quotient,s ; load quotient for D return
                    std       stk_ccdiv_saved_ret,s ; park quotient while return address is moved
                    stx       stk_ccdiv_quotient,s ; move return address over consumed dividend
                    ldx       stk_ccdiv_divisor,s ; return remainder in X
                    ldd       stk_ccdiv_saved_ret,s ; return quotient in D
                    leas      stk_ccdiv_quotient,s ; discard work frame up to relocated return address
                    rts                 ; return to caller

                    endsect   ;         end current section
