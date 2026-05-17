                    section   code      ; begin code section

_flacc              EXTERNAL            ; import external symbol
_chcodes            EXTERNAL            ; import external symbol

htol                EXPORT              ; export this symbol

htol:               pshs      y,u       ; save Y,U on the hardware stack
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    leay      _chcodes,y ; compute effective address into Y from _chcodes,y
                    ldu       6,s       ; load U from stack-relative value 6,s
                    clra                ; clear A
                    clrb                ; clear B
                    std       ,x        ; store D to memory pointed to by X
                    std       2,x       ; store D to indexed value 2,x
Loop_01             ldb       ,u        ; load B from memory pointed to by U
                    cmpb      #$20      ; compare B against immediate value $20
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    cmpb      #9        ; compare B against immediate value 9
                    bne       BranchTarget_03 ; branch if not equal to BranchTarget_03
BranchTarget_01     leau      1,u       ; compute effective address into U from 1,u
                    bra       Loop_01   ; branch unconditionally to Loop_01
Loop_02             lda       #4        ; load A from immediate value 4
Loop_03             asl       3,x       ; shift indexed value 3,x left by one bit
                    rol       2,x       ; rotate indexed value 2,x left through carry
                    rol       1,x       ; rotate indexed value 1,x left through carry
                    rol       ,x        ; rotate memory pointed to by X left through carry
                    deca                ; decrement A
                    bne       Loop_03   ; branch if not equal to Loop_03
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    subb      #$30      ; subtract immediate value $30 from B
                    cmpb      #9        ; compare B against immediate value 9
                    ble       BranchTarget_02 ; branch if less or equal to BranchTarget_02
                    subb      #7        ; subtract immediate value 7 from B
                    cmpb      #$0f      ; compare B against immediate value $0f
                    ble       BranchTarget_02 ; branch if less or equal to BranchTarget_02
                    subb      #$20      ; subtract immediate value $20 from B
BranchTarget_02     andcc     #254      ; clear condition-code bits with mask #254
                    lda       #3        ; load A from immediate value 3
                    bra       Continue_01 ; branch unconditionally to Continue_01
Loop_04             ldb       #0        ; load B from immediate value 0
Continue_01         adcb      a,x       ; add indexed value a,x into B
                    stb       a,x       ; store B to indexed value a,x
                    deca                ; decrement A
                    bpl       Loop_04   ; branch if plus to Loop_04
                    ldb       ,u        ; load B from memory pointed to by U
BranchTarget_03     ldb       b,y       ; load B from indexed value b,y
                    andb      #$40      ; AND B with immediate value $40
                    bne       Loop_02   ; branch if not equal to Loop_02
                    puls      y,u,pc    ; restore registers and return

                    endsect             ; end current section

