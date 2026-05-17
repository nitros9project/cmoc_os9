                    section   code      ; begin code section

_ltoacc             EXTERNAL            ; import external symbol

_lshl               EXPORT              ; export this symbol
_lshr               EXPORT              ; export this symbol

_lshl:              ldx       2,s       ; load X from stack-relative value 2,s
                    pshs      b         ; save B on the hardware stack
                    lbsr      _ltoacc   ; long branch to subroutine to _ltoacc
                    puls      b         ; restore B from the hardware stack
                    tstb                ; test B and update condition codes
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
Loop_01             asl       3,x       ; shift indexed value 3,x left by one bit
                    rol       2,x       ; rotate indexed value 2,x left through carry
                    rol       1,x       ; rotate indexed value 1,x left through carry
                    rol       ,x        ; rotate memory pointed to by X left through carry
                    decb                ; decrement B
                    bne       Loop_01   ; branch if not equal to Loop_01
BranchTarget_01     puls      d         ; restore D from the hardware stack
                    std       ,s        ; store D to memory pointed to by S
                    rts                 ; return to caller
_lshr:              ldx       2,s       ; load X from stack-relative value 2,s
                    pshs      b         ; save B on the hardware stack
                    lbsr      _ltoacc   ; long branch to subroutine to _ltoacc
                    puls      b         ; restore B from the hardware stack
                    tstb                ; test B and update condition codes
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
Loop_02             asr       ,x        ; arithmetic shift memory pointed to by X right by one bit
                    ror       1,x       ; rotate indexed value 1,x right through carry
                    ror       2,x       ; rotate indexed value 2,x right through carry
                    ror       3,x       ; rotate indexed value 3,x right through carry
                    decb                ; decrement B
                    bne       Loop_02   ; branch if not equal to Loop_02
BranchTarget_02     puls      d         ; restore D from the hardware stack
                    std       ,s        ; store D to memory pointed to by S
                    rts                 ; return to caller

                    endsect             ; end current section

