* Adapted from Deek's KLibc strncmp.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strncmp            EXPORT    ;         export strncmp helper

_strncmp:
stk_strncmp_ret     equ       0         ; caller return address
stk_strncmp_left    equ       2         ; left-hand string pointer
stk_strncmp_right   equ       4         ; right-hand string pointer
stk_strncmp_count   equ       6         ; maximum bytes to compare
                    pshs      y,u       ; preserve caller's Y and U registers
                    ldx       stk_strncmp_left+4,s ; load left-hand string after saved Y/U
                    ldu       stk_strncmp_right+4,s ; load right-hand string after saved Y/U
                    ldy       stk_strncmp_count+4,s ; load compare count after saved Y/U
                    beq       ReturnZero_01 ; zero count compares equal
                    bra       Continue_01 ; compare first byte before advancing right side
Loop_01             leay      -1,y      ; count down matched byte
                    beq       ReturnZero_01 ; all requested bytes matched
                    ldb       ,u+       ; advance over matched right-hand byte
                    beq       ReturnZero_01 ; both strings ended at NUL
Continue_01         ldb       ,u        ; load current right-hand byte
                    subb      ,x+       ; subtract current left-hand byte and advance left
                    beq       Loop_01   ; continue while bytes match
                    negb                ; return left-minus-right ordering
                    sex                 ; sign-extend signed byte result into D
                    bra       Continue_02 ; return mismatch result
ReturnZero_01       clra                ; return zero for equal prefix
                    clrb                ; return zero for equal prefix
Continue_02         puls      y,u,pc    ; restore registers and return

                    endsect   ;         end current section
