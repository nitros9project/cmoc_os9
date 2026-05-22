* Adapted from cmoc_os9/lib/todo/cshifts.as for the live cmoc_os9 ABI.
*
* These are codegen helper entry points, not ordinary C-callable functions.
* Keep their historical unprefixed names so existing assembly callers can
* branch to them directly.

                    section   code      ; begin code section

ccasr               EXPORT    ;         export this symbol
cclsr               EXPORT    ;         export this symbol
ccasl               EXPORT    ;         export this symbol

ccasr:
stk_cshift_ret      equ       0         ; caller return address for 16-bit shift helpers
stk_cshift_value    equ       2         ; stacked 16-bit value being shifted in place
                    tstb                ; check whether any shift steps are required
                    beq       BranchTarget_01 ; skip loop for zero shift count
Loop_01             asr       stk_cshift_value,s ; shift high byte right, preserving sign
                    ror       stk_cshift_value+1,s ; rotate low byte through carry
                    decb                ; one shift step completed
                    bne       Loop_01   ; continue until requested count is exhausted
                    bra       BranchTarget_01 ; return common shifted value

cclsr:
                    tstb                ; check whether any shift steps are required
                    beq       BranchTarget_01 ; skip loop for zero shift count
Loop_02             lsr       stk_cshift_value,s ; shift high byte right with zero fill
                    ror       stk_cshift_value+1,s ; rotate low byte through carry
                    decb                ; one shift step completed
                    bne       Loop_02   ; continue until requested count is exhausted
                    bra       BranchTarget_01 ; return common shifted value

ccasl:
                    tstb                ; check whether any shift steps are required
                    beq       BranchTarget_01 ; skip loop for zero shift count
Loop_03             asl       stk_cshift_value+1,s ; shift low byte left first
                    rol       stk_cshift_value,s ; rotate high byte through carry
                    decb                ; one shift step completed
                    bne       Loop_03   ; continue until requested count is exhausted
BranchTarget_01     ldd       stk_cshift_value,s ; load shifted 16-bit result
                    pshs      d         ; save result while moving caller return address
                    ldd       stk_cshift_ret+2,s ; fetch caller return address after pushed result
                    std       stk_cshift_value+2,s ; move return address over consumed value
                    ldd       ,s        ; restore shifted result to D
                    leas      stk_cshift_value+2,s ; discard saved result and original return slot
                    rts                 ; return to caller

                    endsect   ;         end current section
