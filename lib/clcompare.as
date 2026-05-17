                    section   code      ; begin code section

_lcmpr              EXPORT              ; export this symbol

_lcmpr:             ldd       2,s       ; load D from stack-relative value 2,s
                    cmpd      ,x        ; compare D against memory pointed to by X
                    bne       BranchTarget_02 ; branch if not equal to BranchTarget_02
                    ldd       4,s       ; load D from stack-relative value 4,s
                    cmpd      2,x       ; compare D against indexed value 2,x
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
                    bcs       BranchTarget_01 ; branch if carry is set to BranchTarget_01
                    lda       #1        ; load A from immediate value 1
                    andcc     #254      ; clear condition-code bits with mask #254
                    bra       BranchTarget_02 ; branch unconditionally to BranchTarget_02
BranchTarget_01     clra                ; clear A
                    cmpa      #1        ; compare A against immediate value 1
BranchTarget_02     pshs      cc        ; save CC on the hardware stack
                    ldd       1,s       ; load D from stack-relative value 1,s
                    std       5,s       ; store D to stack-relative value 5,s
                    puls      cc        ; restore CC from the hardware stack
                    leas      4,s       ; adjust S using 4,s
                    rts                 ; return to caller

                    endsect             ; end current section

