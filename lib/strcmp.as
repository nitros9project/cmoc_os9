* Adapted from Deek's KLibc strcmp.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strcmp             EXPORT    ;         export strcmp helper

_strcmp:
stk_strcmp_ret      equ       0         ; caller return address
stk_strcmp_left     equ       2         ; left-hand string pointer
stk_strcmp_right    equ       4         ; right-hand string pointer
                    pshs      u         ; preserve caller's U register
                    ldx       stk_strcmp_left+2,s ; load left-hand string after saved U
                    ldu       stk_strcmp_right+2,s ; load right-hand string after saved U
                    bra       Continue_01 ; compare first character before advancing right string
Loop_01             ldb       ,u+       ; advance over matching right-hand character
                    beq       BranchTarget_01 ; equal strings ended at NUL
Continue_01         ldb       ,u        ; load current right-hand character
                    subb      ,x+       ; subtract current left-hand character and advance left
                    beq       Loop_01   ; continue while characters match
                    negb                ; return left-minus-right ordering
BranchTarget_01     sex                 ; sign-extend signed byte result into D
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
