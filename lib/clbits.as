                    section   code      ; begin code section

_flacc              EXTERNAL            ; import external symbol
_lbexit             EXTERNAL            ; import external symbol

_land               EXPORT              ; export this symbol
_lor                EXPORT              ; export this symbol
_lxor               EXPORT              ; export this symbol
_lnot               EXPORT              ; export this symbol

_land:              ldd       2,s       ; load D from stack-relative value 2,s
                    anda      ,x        ; AND A with memory pointed to by X
                    andb      1,x       ; AND B with indexed value 1,x
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    ldd       4,s       ; load D from stack-relative value 4,s
                    anda      2,x       ; AND A with indexed value 2,x
                    andb      3,x       ; AND B with indexed value 3,x
                    std       _flacc+2,y ; store D to indexed value _flacc+2,y
                    lbra      _lbexit   ; long branch unconditionally to _lbexit
_lor:               ldd       2,s       ; load D from stack-relative value 2,s
                    ora       ,x        ; OR A with memory pointed to by X
                    orb       1,x       ; OR B with indexed value 1,x
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    ldd       4,s       ; load D from stack-relative value 4,s
                    ora       2,x       ; OR A with indexed value 2,x
                    orb       3,x       ; OR B with indexed value 3,x
                    std       _flacc+2,y ; store D to indexed value _flacc+2,y
                    lbra      _lbexit   ; long branch unconditionally to _lbexit
_lxor:              ldd       2,s       ; load D from stack-relative value 2,s
                    eora      ,x        ; XOR A with memory pointed to by X
                    eorb      1,x       ; XOR B with indexed value 1,x
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    ldd       4,s       ; load D from stack-relative value 4,s
                    eora      2,x       ; XOR A with indexed value 2,x
                    eorb      3,x       ; XOR B with indexed value 3,x
                    std       _flacc+2,y ; store D to indexed value _flacc+2,y
                    lbra      _lbexit   ; long branch unconditionally to _lbexit
_lnot:              lda       ,x        ; load A from memory pointed to by X
                    ora       1,x       ; OR A with indexed value 1,x
                    ora       2,x       ; OR A with indexed value 2,x
                    ora       3,x       ; OR A with indexed value 3,x
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    clrb                ; clear B
                    clra                ; clear A
                    rts                 ; return to caller
BranchTarget_01     ldd       #1        ; load D from immediate value 1
                    rts                 ; return to caller

                    endsect             ; end current section

