                    use       ../include/ctype.d ; shared character-class flag constants

                    section   code      ; begin code section

_chcodes            EXTERNAL  ;         import character classification table

_htoi               EXPORT    ;         export C-callable entry point
htoi                EXPORT    ;         export this symbol

_htoi:
htoi:
stk_htoi_accum      equ       0         ; saved D reused as the 16-bit accumulated result
stk_htoi_saved_u    equ       2         ; saved U after entry prologue
stk_htoi_ret        equ       4         ; caller return address after entry prologue
stk_htoi_string     equ       6         ; input string pointer after entry prologue
ascii_space         equ       $20       ; leading space accepted by this parser
ascii_tab           equ       $09       ; leading horizontal tab accepted by this parser
ascii_zero          equ       $30       ; ASCII base used to convert a digit character
hex_digit_max       equ       9         ; largest decimal digit value before A-F adjustment
hex_alpha_adjust    equ       7         ; gap between ASCII '9' and 'A'
hex_nibble_max      equ       $0f       ; largest value accepted for one hexadecimal digit
hex_case_adjust     equ       $20       ; gap between uppercase and lowercase hex letters
                    clra                ; seed the 16-bit accumulator high byte with zero
                    clrb                ; seed the 16-bit accumulator low byte with zero
                    pshs      d,u       ; save accumulator scratch and caller U
                    ldu       stk_htoi_string,s ; point U at the input string
                    leax      _chcodes,pcr ; point X at the ctype flag table
htoi_skip_ws        ldb       ,u        ; inspect the next input byte without consuming it
                    cmpb      #ascii_space ; skip leading spaces
                    beq       htoi_advance_ws ; consume this leading space
                    cmpb      #ascii_tab ; skip leading tabs
                    bne       htoi_check_digit ; stop skipping when the byte is not whitespace
htoi_advance_ws     leau      1,u       ; advance past accepted leading whitespace
                    bra       htoi_skip_ws ; continue scanning for the first hex digit
htoi_accumulate_digit
                    ldd       stk_htoi_accum,s ; load the accumulated 16-bit value
                    lslb                ; shift accumulator left one bit
                    rola                ; propagate carry into the high byte
                    lslb                ; shift accumulator left a second bit
                    rola                ; propagate carry into the high byte
                    lslb                ; shift accumulator left a third bit
                    rola                ; propagate carry into the high byte
                    lslb                ; shift accumulator left a fourth bit
                    rola                ; make room for the next hex nibble
                    std       stk_htoi_accum,s ; save shifted accumulator
                    ldb       ,u+       ; consume the current hex digit
                    subb      #ascii_zero ; convert ASCII digit baseline to binary
                    cmpb      #hex_digit_max ; is it in the '0'..'9' range?
                    ble       htoi_add_nibble ; decimal digit conversion is complete
                    subb      #hex_alpha_adjust ; adjust 'A'..'F' into 10..15
                    cmpb      #hex_nibble_max ; did uppercase conversion produce a nibble?
                    ble       htoi_add_nibble ; uppercase hex conversion is complete
                    subb      #hex_case_adjust ; adjust lowercase 'a'..'f' into 10..15
htoi_add_nibble     clra                ; extend the nibble in B to 16 bits
                    addd      stk_htoi_accum,s ; add nibble into the shifted accumulator
                    std       stk_htoi_accum,s ; save updated accumulator
                    ldb       ,u        ; inspect the next byte before deciding whether to continue
htoi_check_digit    ldb       b,x       ; load ctype flags for the current byte
                    andb      #_HEXDIG  ; keep only the hexadecimal-digit class bit
                    bne       htoi_accumulate_digit ; consume another digit while it is hexadecimal
                    puls      d,u,pc    ; return accumulated value in D and restore U

                    endsect   ;         end current section
