                    section   code      ; begin code section

ccmult              EXPORT              ; export this symbol

ccmult:             tsta                ; test A and update condition codes
                    bne       BranchTarget_01 ; branch if not equal to BranchTarget_01
                    tst       2,s       ; test stack-relative value 2,s and update condition codes
                    bne       BranchTarget_01 ; branch if not equal to BranchTarget_01
                    lda       3,s       ; load A from stack-relative value 3,s
                    mul                 ; multiply A by B and leave the product in D
                    ldx       ,s        ; load X from memory pointed to by S
                    stx       2,s       ; store X to stack-relative value 2,s
                    ldx       #0        ; load X from immediate value 0
                    std       ,s        ; store D to memory pointed to by S
                    puls      d,pc      ; restore registers and return
BranchTarget_01     pshs      d         ; save D on the hardware stack
                    ldd       #0        ; load D from immediate value 0
                    pshs      d         ; save D on the hardware stack
                    pshs      d         ; save D on the hardware stack
                    lda       5,s       ; load A from stack-relative value 5,s
                    ldb       9,s       ; load B from stack-relative value 9,s
                    mul                 ; multiply A by B and leave the product in D
                    std       2,s       ; store D to stack-relative value 2,s
                    lda       5,s       ; load A from stack-relative value 5,s
                    ldb       8,s       ; load B from stack-relative value 8,s
                    mul                 ; multiply A by B and leave the product in D
                    addd      1,s       ; add stack-relative value 1,s into D
                    std       1,s       ; store D to stack-relative value 1,s
                    bcc       BranchTarget_02 ; branch if carry is clear to BranchTarget_02
                    inc       ,s        ; increment memory pointed to by S
BranchTarget_02     lda       4,s       ; load A from stack-relative value 4,s
                    ldb       9,s       ; load B from stack-relative value 9,s
                    mul                 ; multiply A by B and leave the product in D
                    addd      1,s       ; add stack-relative value 1,s into D
                    std       1,s       ; store D to stack-relative value 1,s
                    bcc       BranchTarget_03 ; branch if carry is clear to BranchTarget_03
                    inc       ,s        ; increment memory pointed to by S
BranchTarget_03     lda       4,s       ; load A from stack-relative value 4,s
                    ldb       8,s       ; load B from stack-relative value 8,s
                    mul                 ; multiply A by B and leave the product in D
                    addd      ,s        ; add memory pointed to by S into D
                    std       ,s        ; store D to memory pointed to by S
                    ldx       6,s       ; load X from stack-relative value 6,s
                    stx       8,s       ; store X to stack-relative value 8,s
                    ldx       ,s        ; load X from memory pointed to by S
                    ldd       2,s       ; load D from stack-relative value 2,s
                    leas      8,s       ; adjust S using 8,s
                    rts                 ; return to caller

                    endsect             ; end current section

