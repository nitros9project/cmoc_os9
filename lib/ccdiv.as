                    section   code      ; begin code section

_rpterr             EXTERNAL            ; import external symbol

ccudiv              EXPORT              ; export this symbol
ccdiv               EXPORT              ; export this symbol

ccudiv:             subd      #0        ; subtract immediate value 0 from D
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    pshs      d         ; save D on the hardware stack
                    leas      -2,s      ; adjust S using -2,s
                    clr       ,s        ; clear memory pointed to by S
                    clr       1,s       ; clear stack-relative value 1,s
                    bra       BranchTarget_02 ; branch unconditionally to BranchTarget_02
Loop_01             puls      d         ; restore D from the hardware stack
                    std       ,s        ; store D to memory pointed to by S
                    ldd       #$002d    ; load D from immediate value $002d
                    lbra      _rpterr   ; long branch unconditionally to _rpterr
ccdiv:              subd      #0        ; subtract immediate value 0 from D
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    pshs      d         ; save D on the hardware stack
                    leas      -2,s      ; adjust S using -2,s
                    clr       ,s        ; clear memory pointed to by S
                    clr       1,s       ; clear stack-relative value 1,s
                    tsta                ; test A and update condition codes
                    bpl       BranchTarget_01 ; branch if plus to BranchTarget_01
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    com       1,s
                    std       2,s       ; store D to stack-relative value 2,s
BranchTarget_01     ldd       6,s       ; load D from stack-relative value 6,s
                    bpl       BranchTarget_02 ; branch if plus to BranchTarget_02
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    com       1,s
                    std       6,s       ; store D to stack-relative value 6,s
BranchTarget_02     lda       #1        ; load A from immediate value 1
Loop_02             inca                ; increment A
                    asl       3,s       ; shift stack-relative value 3,s left by one bit
                    rol       2,s       ; rotate stack-relative value 2,s left through carry
                    bpl       Loop_02   ; branch if plus to Loop_02
                    sta       ,s        ; store A to memory pointed to by S
                    ldd       6,s       ; load D from stack-relative value 6,s
                    clr       6,s       ; clear stack-relative value 6,s
                    clr       7,s       ; clear stack-relative value 7,s
Loop_03             subd      2,s       ; subtract stack-relative value 2,s from D
                    bcc       BranchTarget_03 ; branch if carry is clear to BranchTarget_03
                    addd      2,s       ; add stack-relative value 2,s into D
                    andcc     #254      ; clear condition-code bits with mask #254
                    bra       Continue_01 ; branch unconditionally to Continue_01
BranchTarget_03     orcc      #1        ; set condition-code bits with mask #1
Continue_01         rol       7,s       ; rotate stack-relative value 7,s left through carry
                    rol       6,s       ; rotate stack-relative value 6,s left through carry
                    lsr       2,s       ; logical shift stack-relative value 2,s right by one bit
                    ror       3,s       ; rotate stack-relative value 3,s right through carry
                    dec       ,s        ; decrement memory pointed to by S
                    bne       Loop_03   ; branch if not equal to Loop_03
                    std       2,s       ; store D to stack-relative value 2,s
                    tst       1,s       ; test stack-relative value 1,s and update condition codes
                    beq       BranchTarget_04 ; branch if equal/zero to BranchTarget_04
                    ldd       6,s       ; load D from stack-relative value 6,s
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    std       6,s       ; store D to stack-relative value 6,s
BranchTarget_04     ldx       4,s       ; load X from stack-relative value 4,s
                    ldd       6,s       ; load D from stack-relative value 6,s
                    std       4,s       ; store D to stack-relative value 4,s
                    stx       6,s       ; store X to stack-relative value 6,s
                    ldx       2,s       ; load X from stack-relative value 2,s
                    ldd       4,s       ; load D from stack-relative value 4,s
                    leas      6,s       ; adjust S using 6,s
                    rts                 ; return to caller

                    endsect             ; end current section

