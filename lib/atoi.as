* Compact assembly implementation of atoi().

                    section   code      ; begin code section

_atoi               EXPORT              ; export this symbol

_atoi
stk_atoi_ret        equ       0         ; caller return address
stk_atoi_src        equ       2         ; source string pointer
stk_atoi_sign       equ       0         ; local sign flag after workspace allocation
stk_atoi_value      equ       1         ; local 16-bit accumulator after workspace allocation
                    pshs      u         ; save U on the hardware stack
                    ldu       stk_atoi_src+2,s ; load source pointer after saving U
                    clra                ; initialize accumulator high byte to zero
                    clrb                ; initialize accumulator low byte and sign flag to zero
                    pshs      d         ; allocate the 16-bit accumulator
                    pshs      b         ; allocate the sign flag byte
L_atoi_skip
                    ldb       ,u+       ; fetch next character while scanning leading whitespace
                    cmpb      #$20      ; recognize an ASCII space
                    beq       L_atoi_skip ; branch if equal/zero to L_atoi_skip
                    cmpb      #9        ; recognize an ASCII tab
                    beq       L_atoi_skip ; branch if equal/zero to L_atoi_skip
                    cmpb      #'-'      ; check for a leading minus sign
                    bne       L_atoi_plus ; branch if not equal to L_atoi_plus
                    stb       stk_atoi_sign,s ; remember that the final result must be negated
                    bra       L_atoi_next ; branch unconditionally to L_atoi_next

L_atoi_plus
                    cmpb      #'+'      ; accept an optional plus sign
                    bne       L_atoi_check ; branch if not equal to L_atoi_check
                    bra       L_atoi_next ; branch unconditionally to L_atoi_next

L_atoi_accum
                    ldd       stk_atoi_value,s ; load current accumulator value
                    aslb                ; multiply accumulator by 2
                    rola                ; propagate the shift into the high byte
                    aslb                ; multiply accumulator by 4
                    rola                ; propagate the shift into the high byte
                    addd      stk_atoi_value,s ; form accumulator * 5
                    aslb                ; form accumulator * 10
                    rola                ; propagate the shift into the high byte
                    pshs      d         ; stage accumulator * 10 while converting the digit
                    ldb       -1,u      ; reload the digit that passed classification
                    clra                ; extend digit value to 16 bits
                    subb      #'0'      ; convert ASCII digit to binary
                    addd      ,s++      ; add the digit to the staged accumulator
                    std       stk_atoi_value,s ; save the updated accumulator

L_atoi_next
                    ldb       ,u+       ; fetch the next candidate digit

L_atoi_check
                    cmpb      #'0'      ; reject characters below the digit range
                    blo       L_atoi_done ; branch if lower to L_atoi_done
                    cmpb      #'9'      ; accept decimal digits only
                    bls       L_atoi_accum ; branch if lower or same to L_atoi_accum

L_atoi_done
                    tst       ,s+       ; test and discard the local sign flag
                    puls      d         ; load the accumulated positive value
                    beq       L_atoi_exit ; branch if equal/zero to L_atoi_exit
                    nega                ; begin 16-bit two's-complement negation
                    negb                ; negate the low byte
                    sbca      #0        ; fold the low-byte borrow into the high byte

L_atoi_exit
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
