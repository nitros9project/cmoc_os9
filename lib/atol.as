_atol               EXPORT              ; export atol entry point

_lmul               EXTERNAL            ; long multiply helper
_lneg               EXTERNAL            ; long negate helper
_flacc              EXTERNAL            ; shared long return accumulator
_lmove              EXTERNAL            ; long move helper
_chcodes            EXTERNAL            ; character classification table

                    section   code      ; begin code section

_atol
                    pshs      u         ; preserve caller's U register
                    ldu       4,s       ; load source string pointer
                    clra                ; clear high byte of initial accumulator
                    clrb                ; clear low byte of initial accumulator
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
                    stb       4,s       ; remember that the final value is negative
                    bra       L0045     ; consume the sign and continue scanning
L001e               cmpb      #'+'      ; check for explicit plus sign
                    bne       L0047     ; branch if parsing should begin immediately
                    bra       L0045     ; consume the plus sign and continue
L0024               ldd       2,s       ; load current low word of accumulated value
                    pshs      d         ; pass low word to long multiply helper
                    ldd       2,s       ; reload current high word of accumulated value
                    pshs      d         ; pass high word to long multiply helper
                    leax      L006c,pcr ; point at 32-bit constant 10
                    lbsr      _lmul     ; multiply accumulated value by 10
                    ldb       -1,u      ; reload the digit character just consumed
                    clra                ; extend digit to 16 bits
                    subb      #$30      ; convert ASCII digit to numeric value
                    addd      2,x       ; add digit into low word of product
                    std       2,s       ; store updated low word
                    ldd       #0        ; prepare zero for carry propagation
                    adcb      1,x       ; add carry into high-word low byte
                    adca      ,x        ; add carry into high-word high byte
                    std       ,s        ; store updated high word
L0045               ldb       ,u+       ; fetch next character after optional sign/digit
L0047               clra                ; clear high byte for table indexing
                    leax      _chcodes,y ; point at character classification table
                    ldb       d,x       ; load classification flags for this character
                    andb      #8        ; isolate the decimal-digit bit
                    bne       L0024     ; keep accumulating while character is a digit
                    tst       4,s       ; check whether a minus sign was recorded
                    beq       L005d     ; skip negation if the value is positive
                    leax      ,s        ; point X at temporary 32-bit result
                    lbsr      _lneg     ; negate the accumulated long value
                    bra       L005f     ; continue with result copy
L005d               leax      ,s        ; point X at the positive temporary result
L005f               leau      _flacc,y  ; point U at the shared long return buffer
                    pshs      u         ; pass destination pointer to long move helper
                    lbsr      _lmove    ; copy parsed value into the return buffer
                    leas      5,s       ; discard temporary sign/result workspace
                    puls      u,pc      ; restore U and return with X pointing at result

L006c               fcb       $07,$00,$00 ; high 24 bits of 32-bit constant 10
                    fcb       $07,$00,$0A ; low byte of 32-bit constant 10

                    endsect             ; end code section
