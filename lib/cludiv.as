* Adapted from cmoc_os9/lib/todo/cludiv.a for the live cmoc_os9 ABI.
* CMOC unsigned long divide/modulo helper ABI: X points at the divisor long,
* the dividend long is on the caller stack, quotient is returned in _flacc,
* and modulo returns the remainder through _flacc.

                    section   bss       ; begin bss section

unused_div_scratch  rmb       1         ; retained reserved byte from original unsigned divide object

                    endsect   ;         end current section

                    section   code      ; begin code section

_flacc              EXTERNAL  ;         import external symbol
_rpterr             EXTERNAL  ;         import external symbol
_lbexit             EXTERNAL  ;         import external symbol

_ludiv              EXPORT    ;         export this symbol
_lumod              EXPORT    ;         export this symbol

EDIVERR             equ       45        ; divide-by-zero runtime error
Carry               equ       %00000001 ; condition-code carry bit

* entry *x = divisor
*       stk_ludiv_dividend_hi,s = dividend
*
* exit  _flacc = quotient
*       *x = remainder

_ludiv:
stk_ludiv_ret       equ       0         ; caller return address in the original helper frame
stk_ludiv_dividend_hi equ       2         ; stacked dividend, bits 31-16
stk_ludiv_dividend_lo equ       4         ; stacked dividend, bits 15-0
stk_ludiv_divzero_ret equ       6         ; caller return slot after BSR frame is discarded
stk_ludiv_work_count equ       0         ; division loop count after div2 builds work frame
stk_ludiv_work_divisor_hi equ       2         ; normalized divisor, bits 31-16
stk_ludiv_work_divisor_lo equ       4         ; normalized divisor, bits 15-0
stk_ludiv_work_resume equ       6         ; return address back into _ludiv after BSR
stk_ludiv_work_dividend_hi equ       10        ; normalized dividend/remainder, bits 31-16
stk_ludiv_work_dividend_lo equ       12        ; normalized dividend/remainder, bits 15-0
                    bsr       _div1     ; validate divisor and build division work frame
                    leas      stk_ludiv_work_dividend_hi-2,s ; discard work frame and BSR return address
                    lbra      _lbexit   ; repair caller stack and return X=_flacc

_lumod:
stk_lumod_ret       equ       0         ; caller return address in the original helper frame
stk_lumod_dividend_hi equ       2         ; stacked dividend, bits 31-16
stk_lumod_dividend_lo equ       4         ; stacked dividend, bits 15-0
stk_lumod_work_count equ       0         ; division loop count after div2 builds work frame
stk_lumod_work_divisor_hi equ       2         ; normalized divisor, bits 31-16
stk_lumod_work_divisor_lo equ       4         ; normalized divisor, bits 15-0
stk_lumod_work_resume equ       6         ; return address back into _lumod after BSR
stk_lumod_work_dividend_hi equ       10        ; normalized dividend/remainder, bits 31-16
stk_lumod_work_dividend_lo equ       12        ; normalized dividend/remainder, bits 15-0
                    lda       0,x       ; start zero-divisor check with high byte
                    ora       1,x       ; include divisor high-word low byte
                    ora       2,x       ; include divisor low-word high byte
                    ora       3,x       ; include divisor low-word low byte
                    bne       _lumod1   ; compute modulo when divisor is non-zero
* zero divisor -- return dividend
                    ldd       0,x       ; preserve original zero divisor high word
                    std       _flacc,y  ; return original high word for legacy zero-divisor modulo
                    ldd       2,x       ; preserve original zero divisor low word
                    leax      _flacc,y  ; return X pointing at the result buffer
                    std       2,x       ; return original low word for legacy zero-divisor modulo
                    lbra      _lbexit   ; repair caller stack and return X=_flacc

_lumod1
                    bsr       div2      ; build work frame and compute unsigned remainder
                    ldd       stk_lumod_work_dividend_hi,s ; copy remainder high word from work frame
                    leax      _flacc,y  ; point X at the result buffer
                    std       0,x       ; store remainder high word
                    ldd       stk_lumod_work_dividend_lo,s ; copy remainder low word from work frame
                    std       2,x       ; store remainder low word
                    leas      stk_lumod_work_dividend_hi-2,s ; discard work frame and BSR return address
                    lbra      _lbexit   ; repair caller stack and return X=_flacc

* check for zero divisor
_div1
                    lda       0,x       ; start zero-divisor check with high byte
                    ora       1,x       ; include divisor high-word low byte
                    ora       2,x       ; include divisor low-word high byte
                    ora       3,x       ; include divisor low-word low byte
                    bne       div2      ; build work frame when divisor is non-zero
* divide by zero error
                    ldd       stk_ludiv_ret+2,s ; fetch caller return address behind BSR return address
                    std       stk_ludiv_dividend_lo+2,s ; move caller return over consumed dividend low word
                    leas      stk_ludiv_divzero_ret,s ; discard BSR frame and consumed dividend high word
                    ldd       #EDIVERR  ; report divide-by-zero through runtime error path
                    lbra      _rpterr   ; transfer control to runtime error handler

* set up our stack
div2
                    ldd       0,x       ; copy divisor high word into the work frame
                    ldx       2,x       ; load divisor low word for stacked work frame
                    pshs      d,x       ; save divisor high/low words in work frame
                    ldd       #0        ; clear D for count and quotient initialization
                    pshs      d         ; allocate count byte and padding in work frame
                    std       _flacc,y  ; clear quotient high word
                    std       _flacc+2,y ; clear quotient low word
                    leax      _flacc,y  ; use _flacc as quotient accumulator

* shift the divisor left
                    clra                ; count zero shifts until normalization starts
                    tst       stk_ludiv_work_divisor_hi,s ; stop early if divisor is already normalized
                    bmi       div51     ; branch if minus to div51
div5
                    inca                ; increment A
                    asl       stk_ludiv_work_divisor_lo+1,s ; shift divisor left until sign bit is set
                    rol       stk_ludiv_work_divisor_lo,s ; continue shifting divisor low word
                    rol       stk_ludiv_work_divisor_hi+1,s ; continue shifting divisor high word
                    rol       stk_ludiv_work_divisor_hi,s ; finish 32-bit divisor shift
                    bpl       div5      ; continue until divisor reaches the sign bit
div51
                    sta       stk_ludiv_work_count,s ; save number of restoring-division iterations
                    bra       check     ; enter division loop with normalized divisor

* subtract the divisor from the dividend
div6
                    ldd       stk_ludiv_work_dividend_lo,s ; subtract divisor low word from dividend/remainder
                    subd      stk_ludiv_work_divisor_lo,s ; subtract normalized divisor low word
                    std       stk_ludiv_work_dividend_lo,s ; store tentative low-word remainder
                    ldd       stk_ludiv_work_dividend_hi,s ; subtract divisor high word from dividend/remainder
                    sbcb      stk_ludiv_work_divisor_hi+1,s ; subtract high-word low byte with borrow
                    sbca      stk_ludiv_work_divisor_hi,s ; subtract high-word high byte with borrow
                    std       stk_ludiv_work_dividend_hi,s ; store tentative high-word remainder
                    bcc       div7      ; keep subtract result when dividend covered divisor
                    ldd       stk_ludiv_work_dividend_lo,s ; restore low-word remainder after failed subtract
                    addd      stk_ludiv_work_divisor_lo,s ; add divisor low word back
                    std       stk_ludiv_work_dividend_lo,s ; restore low-word remainder
                    ldd       stk_ludiv_work_dividend_hi,s ; restore high-word remainder
                    adcb      stk_ludiv_work_divisor_hi+1,s ; add high-word low byte with carry
                    adca      stk_ludiv_work_divisor_hi,s ; add high-word high byte with carry
                    std       stk_ludiv_work_dividend_hi,s ; restore high-word remainder
                    andcc     #^Carry   ; clear quotient bit for this division step
                    bra       div8      ; merge with quotient rotation

* rotate quotient and dividend
div7
                    orcc      #Carry    ; set quotient bit for this division step
div8
                    rol       3,x       ; rotate quotient byte 3 through carry
                    rol       2,x       ; rotate quotient byte 2 through carry
                    rol       1,x       ; rotate quotient byte 1 through carry
                    rol       0,x       ; rotate quotient byte 0 through carry
                    lsr       stk_ludiv_work_divisor_hi,s ; shift normalized divisor right for next bit
                    ror       stk_ludiv_work_divisor_hi+1,s ; continue divisor right shift
                    ror       stk_ludiv_work_divisor_lo,s ; continue divisor right shift
                    ror       stk_ludiv_work_divisor_lo+1,s ; finish divisor right shift
                    dec       stk_ludiv_work_count,s ; one restoring-division bit completed
check
                    bpl       div6      ; continue until all quotient bits are generated
                    jmp       [stk_ludiv_work_resume,s] ; resume _ludiv/_lumod with work frame still active

                    endsect   ;         end current section
