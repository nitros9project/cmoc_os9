                    section   code      ; begin code section

_flacc              EXTERNAL            ; import external symbol
_lbexit             EXTERNAL            ; import external symbol

_lmul               EXPORT              ; export this symbol

_lmul:              ldd       2,x       ; load D from indexed value 2,x
                    pshs      d         ; save D on the hardware stack
                    ldd       ,x        ; load D from memory pointed to by X
                    pshs      d         ; save D on the hardware stack
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    clr       ,x        ; clear memory pointed to by X
                    clr       1,x       ; clear indexed value 1,x
                    lda       9,s       ; load A from stack-relative value 9,s
                    ldb       3,s       ; load B from stack-relative value 3,s
                    mul                 ; multiply A by B and leave the product in D
                    std       2,x       ; store D to indexed value 2,x
                    lda       9,s       ; load A from stack-relative value 9,s
                    ldb       2,s       ; load B from stack-relative value 2,s
                    mul                 ; multiply A by B and leave the product in D
                    addd      1,x       ; add indexed value 1,x into D
                    std       1,x       ; store D to indexed value 1,x
                    bcc       BranchTarget_01 ; branch if carry is clear to BranchTarget_01
                    inc       ,x        ; increment memory pointed to by X
BranchTarget_01     lda       8,s       ; load A from stack-relative value 8,s
                    ldb       3,s       ; load B from stack-relative value 3,s
                    mul                 ; multiply A by B and leave the product in D
                    addd      1,x       ; add indexed value 1,x into D
                    std       1,x       ; store D to indexed value 1,x
                    bcc       BranchTarget_02 ; branch if carry is clear to BranchTarget_02
                    inc       ,x        ; increment memory pointed to by X
BranchTarget_02     lda       9,s       ; load A from stack-relative value 9,s
                    ldb       1,s       ; load B from stack-relative value 1,s
                    mul                 ; multiply A by B and leave the product in D
                    addd      ,x        ; add memory pointed to by X into D
                    std       ,x        ; store D to memory pointed to by X
                    lda       8,s       ; load A from stack-relative value 8,s
                    ldb       2,s       ; load B from stack-relative value 2,s
                    mul                 ; multiply A by B and leave the product in D
                    addd      ,x        ; add memory pointed to by X into D
                    std       ,x        ; store D to memory pointed to by X
                    lda       7,s       ; load A from stack-relative value 7,s
                    ldb       3,s       ; load B from stack-relative value 3,s
                    mul                 ; multiply A by B and leave the product in D
                    addd      ,x        ; add memory pointed to by X into D
                    std       ,x        ; store D to memory pointed to by X
                    lda       9,s       ; load A from stack-relative value 9,s
                    ldb       ,s        ; load B from memory pointed to by S
                    mul                 ; multiply A by B and leave the product in D
                    addb      ,x        ; add memory pointed to by X into B
                    stb       ,x        ; store B to memory pointed to by X
                    lda       8,s       ; load A from stack-relative value 8,s
                    ldb       1,s       ; load B from stack-relative value 1,s
                    mul                 ; multiply A by B and leave the product in D
                    addb      ,x        ; add memory pointed to by X into B
                    stb       ,x        ; store B to memory pointed to by X
                    lda       7,s       ; load A from stack-relative value 7,s
                    ldb       2,s       ; load B from stack-relative value 2,s
                    mul                 ; multiply A by B and leave the product in D
                    addb      ,x        ; add memory pointed to by X into B
                    stb       ,x        ; store B to memory pointed to by X
                    lda       6,s       ; load A from stack-relative value 6,s
                    ldb       3,s       ; load B from stack-relative value 3,s
                    mul                 ; multiply A by B and leave the product in D
                    addb      ,x        ; add memory pointed to by X into B
                    stb       ,x        ; store B to memory pointed to by X
                    leas      4,s       ; adjust S using 4,s
                    lbra      _lbexit   ; long branch unconditionally to _lbexit

                    endsect             ; end current section

