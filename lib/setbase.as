* Compact assembly implementation of setbase().

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_setbase            EXPORT              ; export this symbol

_ibrk               EXTERNAL            ; import external symbol
_getstat            EXTERNAL            ; import external symbol

DEVMASK             equ       $C0       ; define constant as $C0
SCF                 equ       $40       ; define constant as $40
RBF                 equ       $80       ; define constant as $80
INIT                equ       $80       ; define constant as $80
BIGBUF              equ       $08       ; define constant as $08
UNBUF               equ       $04       ; define constant as $04
BUFSIZ_C            equ       256       ; define constant as 256

_setbase
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldb       7,u       ; load B from indexed value 7,u
                    bitb      #DEVMASK  ; test bits in B against immediate value DEVMASK
                    bne       L_setbase_known ; branch if not equal to L_setbase_known
                    leas      -32,s     ; adjust S using -32,s
                    leax      ,s        ; compute effective address into X from ,s
                    ldd       8,u       ; load D from indexed value 8,u
                    pshs      d,x       ; save D,X on the hardware stack
                    clra                ; clear A
                    clrb                ; clear B
                    pshs      d         ; save D on the hardware stack
                    lbsr      _getstat  ; long branch to subroutine to _getstat
                    ldb       #SCF      ; load B from immediate value SCF
                    lda       6,s       ; load A from stack-relative value 6,s
                    beq       L_setbase_merge ; branch if equal/zero to L_setbase_merge
                    ldb       #RBF      ; load B from immediate value RBF
L_setbase_merge
                    leas      38,s      ; adjust S using 38,s
                    orb       7,u       ; OR B with indexed value 7,u
                    stb       7,u       ; store B to indexed value 7,u
L_setbase_known
                    lda       6,u       ; load A from indexed value 6,u
                    ora       #INIT     ; OR A with immediate value INIT
                    sta       6,u       ; store A to indexed value 6,u
                    ldd       8,u       ; load D from indexed value 8,u
                    cmpd      #1        ; compare D against immediate value 1
                    bne       L_setbase_check ; branch if not equal to L_setbase_check
                    ldb       7,u       ; load B from indexed value 7,u
                    orb       #UNBUF    ; OR B with immediate value UNBUF
                    stb       7,u       ; store B to indexed value 7,u
L_setbase_check
                    andb      #BIGBUF+UNBUF ; AND B with immediate value BIGBUF+UNBUF
                    bne       L_setbase_done ; branch if not equal to L_setbase_done
                    ldd       11,u      ; load D from indexed value 11,u
                    bne       L_setbase_have_size ; branch if not equal to L_setbase_have_size
                    ldd       #BUFSIZ_C ; load D from immediate value BUFSIZ_C
                    std       11,u      ; store D to indexed value 11,u
L_setbase_have_size
                    ldd       2,u       ; load D from indexed value 2,u
                    bne       L_setbase_big ; branch if not equal to L_setbase_big
                    ldd       11,u      ; load D from indexed value 11,u
                    pshs      d         ; save D on the hardware stack
                    lbsr      _ibrk     ; long branch to subroutine to _ibrk
                    leas      2,s       ; adjust S using 2,s
                    std       2,u       ; store D to indexed value 2,u
                    cmpd      #-1       ; compare D against immediate value -1
                    beq       L_setbase_unbuf ; branch if equal/zero to L_setbase_unbuf
L_setbase_big
                    ldb       #BIGBUF   ; load B from immediate value BIGBUF
                    bra       L_setbase_flag ; branch unconditionally to L_setbase_flag
L_setbase_unbuf
                    leax      10,u      ; compute effective address into X from 10,u
                    stx       2,u       ; store X to indexed value 2,u
                    ldd       #1        ; load D from immediate value 1
                    std       11,u      ; store D to indexed value 11,u
                    ldb       #UNBUF    ; load B from immediate value UNBUF
L_setbase_flag
                    orb       7,u       ; OR B with indexed value 7,u
                    stb       7,u       ; store B to indexed value 7,u
                    ldd       2,u       ; load D from indexed value 2,u
                    addd      11,u      ; add indexed value 11,u into D
                    std       4,u       ; store D to indexed value 4,u
                    std       ,u        ; store D to memory pointed to by U
L_setbase_done
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
