* Compact assembly implementation of strchr/strrchr and index/rindex aliases.

                    section   code      ; begin code section

_strchr             EXPORT    ;         export this symbol
_index              EXPORT    ;         export this symbol
_strrchr            EXPORT    ;         export this symbol
_rindex             EXPORT    ;         export this symbol

_strchr:
_index:
stk_strchr_ret      equ       0         ; caller return address
stk_strchr_string   equ       2         ; string pointer argument
stk_strchr_char     equ       4         ; 16-bit int character argument
stk_strchr_char_byte equ       5         ; low byte of character argument
                    ldx       stk_strchr_string,s ; start scanning at caller string pointer
L_strchr_loop
                    ldb       ,x+       ; read next string byte and advance pointer
                    beq       L_strchr_not_found ; no match before the NUL terminator
                    cmpb      stk_strchr_char_byte,s ; compare against requested character byte
                    bne       L_strchr_loop ; keep scanning until character or terminator
                    tfr       x,d       ; convert post-incremented match pointer to D
                    bra       L_strrchr_done ; subtract one and return the matched address

L_strchr_not_found
                    clra                ; return NULL high byte
                    rts                 ; return to caller

_strrchr:
_rindex:
stk_strrchr_ret     equ       0         ; caller return address
stk_strrchr_string  equ       2         ; string pointer argument
stk_strrchr_char    equ       4         ; 16-bit int character argument
stk_strrchr_char_byte equ       5         ; low byte of character argument
stk_strrchr_last_match equ       0         ; temporary last-match pointer after pshs d
                    ldx       stk_strrchr_string,s ; start scanning at caller string pointer
                    ldd       #1        ; seed last-match slot so subtract-one yields NULL
                    pshs      d         ; reserve last-match pointer on stack
                    bra       L_strrchr_scan ; enter loop by reading the first byte

L_strrchr_match
                    cmpb      stk_strrchr_char_byte+2,s ; account for last-match slot
                    bne       L_strrchr_scan ; leave previous last-match unchanged
                    stx       stk_strrchr_last_match,s ; remember post-incremented match pointer

L_strrchr_scan
                    ldb       ,x+       ; read next string byte and advance pointer
                    bne       L_strrchr_match ; keep scanning until the NUL terminator
                    puls      d         ; recover post-incremented last-match pointer

L_strrchr_done
                    subd      #1        ; convert post-incremented pointer to match address
                    rts                 ; return to caller

                    endsect   ;         end current section
