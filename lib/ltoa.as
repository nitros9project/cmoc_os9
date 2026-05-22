*
* Compact standalone assembly implementation for the live cmoc_os9 ABI.
* Writes digits into the caller's buffer in reverse order, then calls
* reverse() once at the end, which keeps the stack footprint small.
*

                    section   code      ; begin code section

_ltoa               EXPORT    ;         export this symbol

_lnegx              EXTERNAL  ;         import external symbol
_reverse            EXTERNAL  ;         import external symbol
divDWordDWord       EXTERNAL  ;         import external symbol
isDWordZero         EXTERNAL  ;         import external symbol
modDWordDWord       EXTERNAL  ;         import external symbol

_ltoa:
stk_ltoa_saved_u    equ       0         ; saved U register at U after prologue
stk_ltoa_ret        equ       2         ; caller return address at U after prologue
stk_ltoa_value_hi   equ       4         ; high word of signed long input
stk_ltoa_value_lo   equ       6         ; low word of signed long input
stk_ltoa_buffer     equ       8         ; caller output buffer pointer
stk_ltoa_sign       equ       -11       ; local sign flag
stk_ltoa_orig_buffer equ       -10       ; local original buffer pointer
stk_ltoa_current_hi equ       -8        ; local current absolute value high word
stk_ltoa_current_lo equ       -6        ; local current absolute value low word
stk_ltoa_remainder_hi equ       -4        ; local division remainder high word
stk_ltoa_remainder_lo equ       -2        ; local division remainder low word
                    pshs      u         ; preserve caller's U register
                    leau      ,s        ; use U as a stable frame pointer at saved U
                    leas      -11,s     ; allocate sign, original pointer, current, and remainder locals

* locals relative to U:
*  stk_ltoa_sign,u         sign flag
*  stk_ltoa_orig_buffer,u  original output buffer pointer
*  stk_ltoa_current_hi,u   current absolute value, high word
*  stk_ltoa_current_lo,u   current absolute value, low word
*  stk_ltoa_remainder_hi,u division remainder, high word
*  stk_ltoa_remainder_lo,u division remainder, low word

* orig = buffer;
                    ldx       stk_ltoa_buffer,u ; load caller output buffer pointer
                    stx       stk_ltoa_orig_buffer,u ; remember original buffer for reverse/return

* current = value;
                    ldd       stk_ltoa_value_hi,u ; copy input high word into current value
                    std       stk_ltoa_current_hi,u ; store current high word
                    ldd       stk_ltoa_value_lo,u ; copy input low word into current value
                    std       stk_ltoa_current_lo,u ; store current low word

* sign = 0;
                    clr       stk_ltoa_sign,u ; assume non-negative until high bit says otherwise

* if (value < 0) { sign = 1; current = -current; }
                    tst       stk_ltoa_value_hi,u ; check sign bit of input high byte
                    bpl       ltoa_positive ; skip negation for non-negative values
                    inc       stk_ltoa_sign,u ; remember that a '-' must be appended later
                    leax      stk_ltoa_current_hi,u ; pass current dword to negation helper
                    lbsr      _lnegx    ; convert current value to its absolute magnitude

ltoa_positive
* do {
ltoa_digit_loop
*     rem = current % 10;
                    leax      ltoa_ten,pcr ; point at divisor constant 10
                    pshs      x         ; pass divisor pointer
                    leax      stk_ltoa_current_hi,u ; point at current dividend
                    pshs      x         ; pass dividend pointer
                    leax      stk_ltoa_remainder_hi,u ; pass destination for remainder
                    lbsr      modDWordDWord ; compute current % 10 into remainder local
                    leas      4,s       ; discard divisor and dividend pointer arguments

*     *buffer++ = rem + '0';
                    ldx       stk_ltoa_buffer,u ; load current output cursor
                    ldb       stk_ltoa_remainder_lo+1,u ; use low byte of remainder
                    addb      #$30      ; convert binary digit to ASCII '0'..'9'
                    stb       ,x+       ; append digit and advance cursor
                    stx       stk_ltoa_buffer,u ; save updated output cursor

*     current /= 10;
                    leax      ltoa_ten,pcr ; point at divisor constant 10
                    pshs      x         ; pass divisor pointer
                    leax      stk_ltoa_current_hi,u ; point at current dividend
                    pshs      x         ; pass dividend pointer
                    leax      stk_ltoa_current_hi,u ; quotient overwrites current value
                    lbsr      divDWordDWord ; compute current / 10 into current local
                    leas      4,s       ; discard divisor and dividend pointer arguments

* } while (current != 0);
                    leax      stk_ltoa_current_hi,u ; point at updated current value
                    lbsr      isDWordZero ; test whether quotient reached zero
                    bne       ltoa_digit_loop ; keep extracting digits while current != 0

* if (sign) *buffer++ = '-';
                    tst       stk_ltoa_sign,u ; was the original value negative?
                    beq       ltoa_terminate ; skip '-' for non-negative values
                    ldx       stk_ltoa_buffer,u ; load current output cursor
                    ldb       #$2d      ; ASCII '-'
                    stb       ,x+       ; append minus sign before reversing the string
                    stx       stk_ltoa_buffer,u ; save updated output cursor

ltoa_terminate
* *buffer = '\0';
                    ldx       stk_ltoa_buffer,u ; load current output cursor
                    clr       ,x        ; terminate reversed digit string

* reverse(orig);
                    ldd       stk_ltoa_orig_buffer,u ; pass original buffer pointer
                    pshs      d         ; push reverse() argument
                    lbsr      _reverse  ; reverse digits into printable order
                    leas      2,s       ; discard reverse() argument

* return orig;
                    ldd       stk_ltoa_orig_buffer,u ; return original output buffer pointer
                    leas      ,u        ; discard local frame by restoring S to saved U
                    puls      u,pc      ; restore registers and return

ltoa_ten            fcb       $00,$00,$00,$0a ; 32-bit divisor constant 10

                    endsect   ;         end current section
