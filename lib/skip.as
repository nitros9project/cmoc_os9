* Adapted from cmoc_os9/lib/todo/skip.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_skipbl             EXPORT    ;         export leading-blank skipper
_skipwd             EXPORT    ;         export word skipper

_skipbl:
stk_skipbl_ret      equ       0         ; caller return address
stk_skipbl_string   equ       2         ; input string pointer
                    ldx       stk_skipbl_string,s ; load scan pointer
Loop_01             ldb       ,x+       ; fetch next character and advance past it
                    cmpb      #$20      ; treat ASCII space as skippable whitespace
                    beq       Loop_01   ; continue through spaces
                    cmpb      #9        ; treat horizontal tab as skippable whitespace
                    beq       Loop_01   ; continue through tabs
                    bra       BranchTarget_01 ; step back to first non-blank character

_skipwd:
stk_skipwd_ret      equ       0         ; caller return address
stk_skipwd_string   equ       2         ; input string pointer
                    ldx       stk_skipwd_string,s ; load scan pointer
Loop_02             ldb       ,x+       ; fetch next character and advance past it
                    beq       BranchTarget_01 ; stop at NUL terminator
                    cmpb      #$20      ; stop at ASCII space
                    beq       BranchTarget_01 ; return pointer to delimiter
                    cmpb      #9        ; stop at horizontal tab
                    bne       Loop_02   ; continue until word delimiter
BranchTarget_01     leax      -1,x      ; back up to the character that stopped the scan
                    tfr       x,d       ; return resulting pointer in D
                    rts                 ; return to caller

                    endsect   ;         end current section
