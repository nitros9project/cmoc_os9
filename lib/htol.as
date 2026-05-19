                    use       ../include/ctype.d ; shared character-class flag constants

                    section   code      ; begin code section

_flacc              EXTERNAL  ;         shared 32-bit long result accumulator
_chcodes            EXTERNAL  ;         import character classification table

_htol               EXPORT    ;         export C-callable entry point
htol                EXPORT    ;         export this symbol

_htol:
htol:
stk_htol_saved_y    equ       0         ; saved CMOC data pointer after entry prologue
stk_htol_saved_u    equ       2         ; saved U after entry prologue
stk_htol_ret        equ       4         ; caller return address after entry prologue
stk_htol_dest       equ       6         ; hidden long-return destination pointer after entry prologue
stk_htol_string     equ       8         ; input string pointer after entry prologue
ascii_space         equ       $20       ; leading space accepted by this parser
ascii_tab           equ       $09       ; leading horizontal tab accepted by this parser
ascii_zero          equ       $30       ; ASCII base used to convert a digit character
hex_digit_max       equ       9         ; largest decimal digit value before A-F adjustment
hex_alpha_adjust    equ       7         ; gap between ASCII '9' and 'A'
hex_nibble_max      equ       $0f       ; largest value accepted for one hexadecimal digit
hex_case_adjust     equ       $20       ; gap between uppercase and lowercase hex letters
hex_nibble_bits     equ       4         ; number of bits shifted for each hex digit
flacc_low_word      equ       2         ; low word offset inside _flacc
flacc_low_byte      equ       3         ; lowest byte offset inside _flacc
cc_carry_bit        equ       $01       ; carry bit cleared before multi-byte addition
                    pshs      y,u       ; preserve CMOC data pointer and caller U
                    leax      _flacc,y  ; point X at the shared 32-bit result buffer
                    leay      _chcodes,pcr ; point Y at the ctype flag table for this routine
                    ldu       stk_htol_string,s ; point U at the input string
                    clra                ; prepare zero for clearing the accumulator
                    clrb                ; prepare zero for clearing the accumulator
                    std       ,x        ; clear high word of the 32-bit accumulator
                    std       flacc_low_word,x ; clear low word of the 32-bit accumulator
htol_skip_ws        ldb       ,u        ; inspect the next input byte without consuming it
                    cmpb      #ascii_space ; skip leading spaces
                    beq       htol_advance_ws ; consume this leading space
                    cmpb      #ascii_tab ; skip leading tabs
                    bne       htol_check_digit ; stop skipping when the byte is not whitespace
htol_advance_ws     leau      1,u       ; advance past accepted leading whitespace
                    bra       htol_skip_ws ; continue scanning for the first hex digit
htol_accumulate_digit
                    lda       #hex_nibble_bits ; shift the 32-bit accumulator by one hex digit
htol_shift_nibble   asl       flacc_low_byte,x ; shift lowest accumulator byte left
                    rol       flacc_low_word,x ; rotate carry into low word high byte
                    rol       1,x       ; rotate carry through high word low byte
                    rol       ,x        ; rotate carry into high word high byte
                    deca                ; count one bit of the four-bit shift
                    bne       htol_shift_nibble ; continue until the full nibble shift is done
                    ldb       ,u+       ; consume the current hex digit
                    subb      #ascii_zero ; convert ASCII digit baseline to binary
                    cmpb      #hex_digit_max ; is it in the '0'..'9' range?
                    ble       htol_add_nibble ; decimal digit conversion is complete
                    subb      #hex_alpha_adjust ; adjust 'A'..'F' into 10..15
                    cmpb      #hex_nibble_max ; did uppercase conversion produce a nibble?
                    ble       htol_add_nibble ; uppercase hex conversion is complete
                    subb      #hex_case_adjust ; adjust lowercase 'a'..'f' into 10..15
htol_add_nibble     andcc     #^cc_carry_bit ; start nibble addition with carry clear
                    lda       #flacc_low_byte ; add from least significant byte upward
                    bra       htol_add_carry ; add first byte using the converted nibble in B
htol_propagate_carry
                    ldb       #0        ; propagate only carry into higher accumulator bytes
htol_add_carry      adcb      a,x       ; add nibble/carry into this accumulator byte
                    stb       a,x       ; save updated accumulator byte
                    deca                ; move to the next more significant byte
                    bpl       htol_propagate_carry ; continue through all four accumulator bytes
                    ldb       ,u        ; inspect the next byte before deciding whether to continue
htol_check_digit    ldb       b,y       ; load ctype flags for the current byte
                    andb      #_HEXDIG  ; keep only the hexadecimal-digit class bit
                    bne       htol_accumulate_digit ; consume another digit while it is hexadecimal
                    ldu       stk_htol_dest,s ; load caller's hidden long-return destination
                    ldd       ,x        ; copy accumulated high word
                    std       ,u        ; store high word into caller return slot
                    ldd       flacc_low_word,x ; copy accumulated low word
                    std       flacc_low_word,u ; store low word into caller return slot
                    puls      y,u,pc    ; restore registers and return with X still pointing at _flacc

                    endsect   ;         end current section
