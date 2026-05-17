* These are assembly implementations of these functions
* The C versions are macros in ctype.h
* char toupper(char c)

                    section   code      ; begin code section

toupper             EXPORT              ; export this symbol
_chcodes            EXTERNAL            ; import external symbol

toupper:            clra                ; clear A
                    ldb       3,s       ; load B from stack-relative value 3,s
                    leax      _chcodes,pcr ; compute effective address into X from _chcodes,pcr
                    lda       d,x       ; load A from indexed value d,x
                    anda      #4        ; AND A with immediate value 4
                    beq       returnit  ; beq   L0022
                    andb      #$df      ; AND B with immediate value $df
                    bra       returnit  ; branch unconditionally to returnit
                    *         clra
                    *         rts

* char tolower(char c)

tolower             EXPORT              ; export this symbol
_chcodes            EXTERNAL            ; import external symbol

tolower:            clra                ; clear A
                    ldb       3,s       ; load B from stack-relative value 3,s
                    leax      _chcodes,pcr ; compute effective address into X from _chcodes,pcr
                    lda       d,x       ; load A from indexed value d,x
                    anda      #2        ; AND A with immediate value 2
                    beq       returnit  ; beq   L0022
                    orb       #$20      ; OR B with immediate value $20
returnit
                    clra                ; clear A
                    rts                 ; return to caller
* L0022 ldd   2,s
*  rts

                    endsect             ; end current section
