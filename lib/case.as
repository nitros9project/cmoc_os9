* These are assembly implementations of these functions
* The C versions are macros in ctype.h
* char toupper(char c)

                    section   code      ; begin code section

toupper             EXPORT    ;         export this symbol
_chcodes            EXTERNAL  ;         import external symbol

toupper:
stk_toupper_ret     equ       0         ; caller return address
stk_toupper_char    equ       2         ; int-promoted character argument
                    clra                ; form a zero-extended table index in D
                    ldb       stk_toupper_char+1,s ; use low byte of promoted character
                    leax      _chcodes,pcr ; point X at character classification table
                    lda       d,x       ; fetch class flags for the character
                    anda      #4        ; isolate lowercase flag
                    beq       returnit  ; leave character unchanged if it is not lowercase
                    andb      #$df      ; clear ASCII lowercase bit to produce uppercase
                    bra       returnit  ; return converted character
                    *         clra
                    *         rts

* char tolower(char c)

tolower             EXPORT    ;         export this symbol
_chcodes            EXTERNAL  ;         import external symbol

tolower:
stk_tolower_ret     equ       0         ; caller return address
stk_tolower_char    equ       2         ; int-promoted character argument
                    clra                ; form a zero-extended table index in D
                    ldb       stk_tolower_char+1,s ; use low byte of promoted character
                    leax      _chcodes,pcr ; point X at character classification table
                    lda       d,x       ; fetch class flags for the character
                    anda      #2        ; isolate uppercase flag
                    beq       returnit  ; leave character unchanged if it is not uppercase
                    orb       #$20      ; set ASCII lowercase bit
returnit
                    clra                ; return int value with high byte cleared
                    rts                 ; return converted or original character in D

                    endsect   ;         end current section
