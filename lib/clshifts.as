* CMOC long shift helper ABI: X is loaded from the caller stack to find the
* long operand, B is the shift count, and _ltoacc copies the operand to _flacc
* before the in-place shift. The helper repairs the caller stack on return.

                    section   code      ; begin code section

_ltoacc             EXTERNAL  ;         import external symbol

_lshl               EXPORT    ;         export this symbol
_lshr               EXPORT    ;         export this symbol

_lshl:
stk_lshl_ret        equ       0         ; caller return address
stk_lshl_operand    equ       2         ; pointer to long operand on caller stack
                    ldx       stk_lshl_operand,s ; load pointer to long operand
                    pshs      b         ; save B on the hardware stack
                    lbsr      _ltoacc   ; copy operand to _flacc and return X=_flacc
                    puls      b         ; restore B from the hardware stack
                    tstb                ; check whether any shift steps are required
                    beq       BranchTarget_01 ; skip loop for zero shift count
Loop_01             asl       3,x       ; shift byte 3 left and seed carry
                    rol       2,x       ; rotate carry into byte 2
                    rol       1,x       ; rotate carry into byte 1
                    rol       ,x        ; rotate carry into byte 0
                    decb                ; one shift step completed
                    bne       Loop_01   ; continue until requested count is exhausted
BranchTarget_01     puls      d         ; pull caller return address, leaving S at stacked operand pointer
                    std       stk_lshl_operand-2,s ; place return address over consumed operand pointer
                    rts                 ; return to caller
_lshr:
stk_lshr_ret        equ       0         ; caller return address
stk_lshr_operand    equ       2         ; pointer to long operand on caller stack
                    ldx       stk_lshr_operand,s ; load pointer to long operand
                    pshs      b         ; save B on the hardware stack
                    lbsr      _ltoacc   ; copy operand to _flacc and return X=_flacc
                    puls      b         ; restore B from the hardware stack
                    tstb                ; check whether any shift steps are required
                    beq       BranchTarget_02 ; skip loop for zero shift count
Loop_02             asr       ,x        ; shift byte 0 right while preserving sign
                    ror       1,x       ; rotate carry into byte 1
                    ror       2,x       ; rotate carry into byte 2
                    ror       3,x       ; rotate carry into byte 3
                    decb                ; one shift step completed
                    bne       Loop_02   ; continue until requested count is exhausted
BranchTarget_02     puls      d         ; pull caller return address, leaving S at stacked operand pointer
                    std       stk_lshr_operand-2,s ; place return address over consumed operand pointer
                    rts                 ; return to caller

                    endsect   ;         end current section
