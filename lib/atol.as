_atol               EXPORT              ; export atol entry point

_lneg               EXTERNAL            ; long negate helper

                    section   code      ; begin code section

_atol
stk_atol_ret        equ       0         ; caller return address
stk_atol_dest       equ       2         ; hidden long-return destination pointer
stk_atol_src        equ       4         ; source string pointer
stk_atol_accum0     equ       0         ; first local accumulator word
stk_atol_accum2     equ       2         ; second local accumulator word
stk_atol_sign       equ       4         ; local sign flag after workspace allocation
                    pshs      u         ; preserve caller's U register
                    ldu       stk_atol_src+2,s ; load source pointer after saving U
                    clra                ; initialize accumulator high byte to zero
                    clrb                ; initialize accumulator low byte and sign flag to zero
                    pshs      b         ; reserve sign flag byte initialized to zero
                    pshs      d         ; reserve high word of 32-bit result
                    pshs      d         ; reserve low word of 32-bit result
charloop
                    ldb       ,u+       ; fetch next input character and advance
                    cmpb      #' '      ; test for leading space
                    beq       charloop  ; skip spaces before the number
                    cmpb      #9        ; test for leading tab
                    beq       charloop  ; skip tabs before the number
                    cmpb      #'-'      ; check for explicit minus sign
                    bne       L001e     ; branch if this is not a minus sign
                    stb       stk_atol_sign,s ; remember that the final value is negative
                    bra       L0045     ; consume the sign and continue scanning
L001e               cmpb      #'+'      ; check for explicit plus sign
                    bne       L0047     ; branch if parsing should begin immediately
                    bra       L0045     ; consume the plus sign and continue
L0024               leas      -4,s      ; reserve a 32-bit temporary copy of the accumulator
                    ldd       stk_atol_accum0+4,s ; copy high word after temporary allocation
                    std       ,s        ; save temporary high word
                    ldd       stk_atol_accum2+4,s ; copy low word after temporary allocation
                    std       2,s       ; save temporary low word
                    asl       stk_atol_accum2+5,s ; shift accumulator left once: low byte
                    rol       stk_atol_accum2+4,s ; shift accumulator left once: low high byte
                    rol       stk_atol_accum0+5,s ; shift accumulator left once: high low byte
                    rol       stk_atol_accum0+4,s ; shift accumulator left once: high high byte
                    asl       3,s       ; shift temporary left three times for accumulator * 8
                    rol       2,s       ; propagate carry through temporary byte 2
                    rol       1,s       ; propagate carry through temporary byte 1
                    rol       ,s        ; propagate carry through temporary byte 0
                    asl       3,s       ; second temporary shift
                    rol       2,s       ; propagate carry through temporary byte 2
                    rol       1,s       ; propagate carry through temporary byte 1
                    rol       ,s        ; propagate carry through temporary byte 0
                    asl       3,s       ; third temporary shift
                    rol       2,s       ; propagate carry through temporary byte 2
                    rol       1,s       ; propagate carry through temporary byte 1
                    rol       ,s        ; propagate carry through temporary byte 0
                    ldd       stk_atol_accum2+4,s ; add temporary low word to accumulator low word
                    addd      2,s       ; add low word of accumulator * 8
                    std       stk_atol_accum2+4,s ; store accumulator * 10 low word
                    ldd       stk_atol_accum0+4,s ; add temporary high word plus carry
                    adcb      1,s       ; add high-word low byte
                    adca      ,s        ; add high-word high byte
                    std       stk_atol_accum0+4,s ; store accumulator * 10 high word
                    ldb       -1,u      ; reload the digit character just consumed
                    clra                ; extend digit to 16 bits
                    subb      #$30      ; convert ASCII digit to numeric value
                    addd      stk_atol_accum2+4,s ; add digit into low word of product
                    std       stk_atol_accum2+4,s ; store the updated accumulator word
                    ldd       #0        ; prepare zero for carry propagation
                    adcb      stk_atol_accum0+5,s ; add carry into high-word low byte
                    adca      stk_atol_accum0+4,s ; add carry into high-word high byte
                    std       stk_atol_accum0+4,s ; store the propagated accumulator word
                    leas      4,s       ; discard temporary copy
L0045               ldb       ,u+       ; fetch next character after optional sign/digit
L0047               cmpb      #'0'      ; reject characters below the digit range
                    blo       L0052     ; branch if this is not a decimal digit
                    cmpb      #'9'      ; accept decimal digits only
                    bls       L0024     ; keep accumulating while character is a digit
L0052
                    tst       stk_atol_sign,s ; check whether a minus sign was recorded
                    beq       L005d     ; skip negation if the value is positive
                    leax      ,s        ; point X at temporary 32-bit result
                    lbsr      _lneg     ; negate the accumulated long value
                    bra       L005f     ; continue with result copy
L005d               leax      ,s        ; point X at the positive temporary result
L005f               ldu       stk_atol_dest+7,s ; load hidden destination after locals and saved U
                    ldd       ,x        ; copy high word of parsed long
                    std       ,u        ; store high word into caller's return slot
                    ldd       2,x       ; copy low word of parsed long
                    std       2,u       ; store low word into caller's return slot
                    leas      5,s       ; discard temporary sign/result workspace
                    puls      u,pc      ; restore U and return with X pointing at result

                    endsect             ; end code section
