                    section   code      ; begin code section

_chcodes            EXTERNAL            ; import external symbol

htoi                EXPORT              ; export this symbol

htoi:               clra                ; clear A
                    clrb                ; clear B
                    pshs      d,u       ; save D,U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    leax      _chcodes,y ; compute effective address into X from _chcodes,y
Loop_01             ldb       ,u        ; load B from memory pointed to by U
                    cmpb      #$20      ; compare B against immediate value $20
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    cmpb      #9        ; compare B against immediate value 9
                    bne       BranchTarget_03 ; branch if not equal to BranchTarget_03
BranchTarget_01     leau      1,u       ; compute effective address into U from 1,u
                    bra       Loop_01   ; branch unconditionally to Loop_01
Loop_02             ldd       ,s        ; load D from memory pointed to by S
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    std       ,s        ; store D to memory pointed to by S
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    subb      #$30      ; subtract immediate value $30 from B
                    cmpb      #9        ; compare B against immediate value 9
                    ble       BranchTarget_02 ; branch if less or equal to BranchTarget_02
                    subb      #7        ; subtract immediate value 7 from B
                    cmpb      #$0f      ; compare B against immediate value $0f
                    ble       BranchTarget_02 ; branch if less or equal to BranchTarget_02
                    subb      #$20      ; subtract immediate value $20 from B
BranchTarget_02     clra                ; clear A
                    addd      ,s        ; add memory pointed to by S into D
                    std       ,s        ; store D to memory pointed to by S
                    ldb       ,u        ; load B from memory pointed to by U
BranchTarget_03     ldb       b,x       ; load B from indexed value b,x
                    andb      #$40      ; AND B with immediate value $40
                    bne       Loop_02   ; branch if not equal to Loop_02
                    puls      d,u,pc    ; restore registers and return

                    endsect             ; end current section

