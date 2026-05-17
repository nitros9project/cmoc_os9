* Adapted from cmoc_os9/lib/todo/bsearch.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_bsearch            EXPORT              ; export this symbol

ccmult              EXTERNAL            ; import external symbol

_bsearch
                    pshs      d,x,y,u   ; save D,X,Y,U on the hardware stack
                    ldu       10,s      ; load U from stack-relative value 10,s
                    clra                ; clear A
                    clrb                ; clear B
Loop_01             addd      #1        ; add immediate value 1 into D
                    std       2,s       ; store D to stack-relative value 2,s
                    ldd       14,s      ; load D from stack-relative value 14,s
Loop_02             subd      2,s       ; subtract stack-relative value 2,s from D
                    bmi       ReturnZero_01 ; branch if minus to ReturnZero_01
                    ldd       14,s      ; load D from stack-relative value 14,s
                    addd      2,s       ; add stack-relative value 2,s into D
                    lsra                ; logical shift A right by one bit
                    rorb                ; rotate B right through carry
                    std       4,s       ; store D to stack-relative value 4,s
                    addd      #-1       ; add immediate value -1 into D
                    pshs      d         ; save D on the hardware stack
                    ldd       18,s      ; load D from stack-relative value 18,s
                    lbsr      ccmult    ; long branch to subroutine to ccmult
                    addd      12,s      ; add stack-relative value 12,s into D
                    std       ,s        ; store D to memory pointed to by S
                    pshs      u         ; save U on the hardware stack
                    jsr       [20,s]    ; call subroutine at [20,s]
                    std       ,s++      ; store D to memory pointed to by S+, then advance S+
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    asla                ; shift A left by one bit
                    ldd       4,s       ; load D from stack-relative value 4,s
                    bcc       Loop_01   ; branch if carry is clear to Loop_01
                    addd      #-1       ; add immediate value -1 into D
                    std       14,s      ; store D to stack-relative value 14,s
                    bra       Loop_02   ; branch unconditionally to Loop_02
ReturnZero_01       clra                ; clear A
                    clrb                ; clear B
                    bra       Continue_01 ; branch unconditionally to Continue_01
BranchTarget_01     ldd       ,s        ; load D from memory pointed to by S
Continue_01         leas      6,s       ; adjust S using 6,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
