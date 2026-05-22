
* CMOC signed long divide/modulo helper ABI: X points at the divisor long,
* the dividend long is on the caller stack, quotient is returned in _flacc,
* and modulo returns the remainder through _flacc.

                    section   bss       ; begin bss section

* Uninitialized data (class B)
dividend_sign       rmb       1         ; original dividend sign for signed modulo correction
* Initialized Data (class G)

                    endsect   ;         end current section

                    section   code      ; begin code section

_flacc              EXTERNAL  ;         import external symbol
_rpterr             EXTERNAL  ;         import external symbol
_lnegx              EXTERNAL  ;         import external symbol
_lbexit             EXTERNAL  ;         import external symbol

_ldiv               EXPORT    ;         export this symbol
_lmod               EXPORT    ;         export this symbol

EDIVERR             equ       45        ; divide-by-zero runtime error
Carry               equ       %00000001 ; condition-code carry bit

_ldiv:
stk_ldiv_ret        equ       0         ; caller return address in the original helper frame
stk_ldiv_dividend_hi equ       2         ; stacked dividend, bits 31-16
stk_ldiv_dividend_lo equ       4         ; stacked dividend, bits 15-0
stk_ldiv_divzero_ret equ       6         ; caller return slot after BSR frame is discarded
stk_ldiv_work_count equ       0         ; division loop count after Subroutine_01 builds work frame
stk_ldiv_work_sign  equ       1         ; quotient sign flag in the temporary work frame
stk_ldiv_work_divisor_hi equ       2         ; normalized divisor, bits 31-16
stk_ldiv_work_divisor_lo equ       4         ; normalized divisor, bits 15-0
stk_ldiv_work_resume equ       6         ; return address back into _ldiv after BSR
stk_ldiv_work_dividend_hi equ       10        ; normalized dividend, bits 31-16
stk_ldiv_work_dividend_lo equ       12        ; normalized dividend, bits 15-0
                    bsr       Subroutine_01 ; build division work frame and compute quotient/remainder
                    lda       stk_ldiv_work_sign,s ; test whether quotient must be negated
                    beq       BranchTarget_01 ; skip negation for positive quotient
Loop_01             lbsr      _lnegx    ; negate _flacc result in place
BranchTarget_01     leas      stk_ldiv_work_dividend_hi-2,s ; discard work frame and BSR return address
                    lbra      _lbexit   ; repair caller stack and return X=_flacc
_lmod:
stk_lmod_ret        equ       0         ; caller return address in the original helper frame
stk_lmod_dividend_hi equ       2         ; stacked dividend, bits 31-16
stk_lmod_dividend_lo equ       4         ; stacked dividend, bits 15-0
stk_lmod_work_count equ       0         ; division loop count after Subroutine_02 builds work frame
stk_lmod_work_sign  equ       1         ; dividend sign flag in the temporary work frame
stk_lmod_work_divisor_hi equ       2         ; normalized divisor, bits 31-16
stk_lmod_work_divisor_lo equ       4         ; normalized divisor, bits 15-0
stk_lmod_work_resume equ       6         ; return address back into _lmod after BSR
stk_lmod_work_dividend_hi equ       10        ; normalized dividend/remainder, bits 31-16
stk_lmod_work_dividend_lo equ       12        ; normalized dividend/remainder, bits 15-0
                    lda       ,x        ; test divisor high byte for zero-divisor handling
                    ora       1,x       ; include divisor high-word low byte
                    ora       2,x       ; include divisor low-word high byte
                    ora       3,x       ; include divisor low-word low byte
                    bne       BranchTarget_02 ; run divide when divisor is non-zero
                    ldd       ,x        ; preserve original zero divisor high word
                    std       _flacc,y  ; return original high word for legacy zero-divisor modulo
                    ldd       2,x       ; preserve original zero divisor low word
                    leax      _flacc,y  ; return X pointing at the result buffer
                    std       2,x       ; return original low word for legacy zero-divisor modulo
                    lbra      _lbexit   ; repair caller stack and return X=_flacc
BranchTarget_02     lda       stk_lmod_dividend_hi,s ; remember original dividend sign
                    sta       dividend_sign,y ; remember the original dividend sign byte
                    bsr       Subroutine_02 ; build division work frame and compute remainder
                    ldd       stk_lmod_work_dividend_hi,s ; copy remainder high word from work frame
                    leax      _flacc,y  ; point X at the result buffer
                    std       ,x        ; store remainder high word
                    ldd       stk_lmod_work_dividend_lo,s ; copy remainder low word from work frame
                    std       2,x       ; store remainder low word
                    tst       dividend_sign,y ; restore signed modulo polarity from original dividend
                    bmi       Loop_01   ; negate remainder when original dividend was negative
                    leas      stk_lmod_work_dividend_hi-2,s ; discard work frame and BSR return address
                    lbra      _lbexit   ; repair caller stack and return X=_flacc
Subroutine_01       lda       ,x        ; test divisor high byte before signed division
                    ora       1,x       ; include divisor high-word low byte
                    ora       2,x       ; include divisor low-word high byte
                    ora       3,x       ; include divisor low-word low byte
                    bne       Subroutine_02 ; build work frame when divisor is non-zero
                    ldd       stk_ldiv_ret+2,s ; fetch caller return address behind BSR return address
                    std       stk_ldiv_dividend_lo+2,s ; move caller return over consumed dividend low word
                    leas      stk_ldiv_divzero_ret,s ; discard BSR frame and consumed dividend high word
                    ldd       #EDIVERR  ; report divide-by-zero through the runtime error path
                    lbra      _rpterr   ; report divide-by-zero to runtime
Subroutine_02       ldd       ,x        ; copy divisor high word into the work frame
                    ldx       2,x       ; load divisor low word for stacked work frame
                    pshs      d,x       ; save divisor high/low words in work frame
                    ldd       #0        ; clear D for sign flag and quotient initialization
                    pshs      d         ; allocate count/sign bytes in work frame
                    std       _flacc,y  ; clear quotient high word
                    std       _flacc+2,y ; clear quotient low word
                    tst       stk_ldiv_work_divisor_hi,s ; test normalized divisor sign byte
                    bpl       BranchTarget_03 ; leave divisor unchanged when already positive
                    leax      stk_ldiv_work_divisor_hi,s ; point X at divisor in work frame
                    lbsr      _lnegx    ; make divisor positive for unsigned core loop
                    inc       stk_ldiv_work_sign,s ; flip quotient sign because divisor was negative
BranchTarget_03     tst       stk_ldiv_work_dividend_hi,s ; test normalized dividend sign byte
                    bpl       BranchTarget_04 ; leave dividend unchanged when already positive
                    leax      stk_ldiv_work_dividend_hi,s ; point X at dividend in work frame
                    lbsr      _lnegx    ; make dividend positive for unsigned core loop
                    com       stk_ldiv_work_sign,s ; flip quotient sign because dividend was negative
BranchTarget_04     leax      _flacc,y  ; use _flacc as quotient accumulator
                    lda       #1        ; initialize normalization shift count
Loop_02             inca                ; increment A
                    asl       stk_ldiv_work_divisor_lo+1,s ; shift divisor left until sign bit is set
                    rol       stk_ldiv_work_divisor_lo,s ; continue shifting divisor low word
                    rol       stk_ldiv_work_divisor_hi+1,s ; continue shifting divisor high word
                    rol       stk_ldiv_work_divisor_hi,s ; finish 32-bit divisor shift
                    bpl       Loop_02   ; continue until divisor reaches the sign bit
                    sta       stk_ldiv_work_count,s ; save number of restoring-division iterations
Loop_03             ldd       stk_ldiv_work_dividend_lo,s ; subtract divisor low word from dividend/remainder
                    subd      stk_ldiv_work_divisor_lo,s ; subtract normalized divisor low word
                    std       stk_ldiv_work_dividend_lo,s ; store tentative low-word remainder
                    ldd       stk_ldiv_work_dividend_hi,s ; subtract divisor high word from dividend/remainder
                    sbcb      stk_ldiv_work_divisor_hi+1,s ; subtract high-word low byte with borrow
                    sbca      stk_ldiv_work_divisor_hi,s ; subtract high-word high byte with borrow
                    std       stk_ldiv_work_dividend_hi,s ; store tentative high-word remainder
                    bcc       BranchTarget_05 ; keep subtract result when dividend covered divisor
                    ldd       stk_ldiv_work_dividend_lo,s ; restore low-word remainder after failed subtract
                    addd      stk_ldiv_work_divisor_lo,s ; add divisor low word back
                    std       stk_ldiv_work_dividend_lo,s ; restore low-word remainder
                    ldd       stk_ldiv_work_dividend_hi,s ; restore high-word remainder
                    adcb      stk_ldiv_work_divisor_hi+1,s ; add high-word low byte with carry
                    adca      stk_ldiv_work_divisor_hi,s ; add high-word high byte with carry
                    std       stk_ldiv_work_dividend_hi,s ; restore high-word remainder
                    andcc     #^Carry   ; clear quotient bit for this division step
                    bra       Continue_01 ; merge with quotient rotation
BranchTarget_05     orcc      #Carry    ; set quotient bit for this division step
Continue_01         rol       3,x       ; rotate quotient byte 3 through carry
                    rol       2,x       ; rotate quotient byte 2 through carry
                    rol       1,x       ; rotate quotient byte 1 through carry
                    rol       ,x        ; rotate quotient byte 0 through carry
                    lsr       stk_ldiv_work_divisor_hi,s ; shift normalized divisor right for next bit
                    ror       stk_ldiv_work_divisor_hi+1,s ; continue divisor right shift
                    ror       stk_ldiv_work_divisor_lo,s ; continue divisor right shift
                    ror       stk_ldiv_work_divisor_lo+1,s ; finish divisor right shift
                    dec       stk_ldiv_work_count,s ; one restoring-division bit completed
                    bne       Loop_03   ; continue until all quotient bits are generated
                    jmp       [stk_ldiv_work_resume,s] ; resume _ldiv/_lmod with work frame still active

                    endsect   ;         end current section
