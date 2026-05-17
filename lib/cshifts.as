* Adapted from cmoc_os9/lib/todo/cshifts.as for the live cmoc_os9 ABI.
*
* These are codegen helper entry points, not ordinary C-callable functions.
* Keep their historical unprefixed names so existing assembly callers can
* branch to them directly.

                    section   code      ; begin code section

ccasr               EXPORT              ; export this symbol
cclsr               EXPORT              ; export this symbol
ccasl               EXPORT              ; export this symbol

ccasr
                    tstb                ; test B and update condition codes
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
Loop_01             asr       2,s       ; arithmetic shift stack-relative value 2,s right by one bit
                    ror       3,s       ; rotate stack-relative value 3,s right through carry
                    decb                ; decrement B
                    bne       Loop_01   ; branch if not equal to Loop_01
                    bra       BranchTarget_01 ; branch unconditionally to BranchTarget_01

cclsr
                    tstb                ; test B and update condition codes
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
Loop_02             lsr       2,s       ; logical shift stack-relative value 2,s right by one bit
                    ror       3,s       ; rotate stack-relative value 3,s right through carry
                    decb                ; decrement B
                    bne       Loop_02   ; branch if not equal to Loop_02
                    bra       BranchTarget_01 ; branch unconditionally to BranchTarget_01

ccasl
                    tstb                ; test B and update condition codes
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
Loop_03             asl       3,s       ; shift stack-relative value 3,s left by one bit
                    rol       2,s       ; rotate stack-relative value 2,s left through carry
                    decb                ; decrement B
                    bne       Loop_03   ; branch if not equal to Loop_03
BranchTarget_01     ldd       2,s       ; load D from stack-relative value 2,s
                    pshs      d         ; save D on the hardware stack
                    ldd       2,s       ; load D from stack-relative value 2,s
                    std       4,s       ; store D to stack-relative value 4,s
                    ldd       ,s        ; load D from memory pointed to by S
                    leas      4,s       ; adjust S using 4,s
                    rts                 ; return to caller

                    endsect             ; end current section
