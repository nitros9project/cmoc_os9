* Adapted from Deek's KLibc strnucmp_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strnucmp           EXPORT    ;         export case-insensitive bounded compare helper

toupper             EXTERN    ;         import character uppercase helper

_strnucmp:
stk_strnucmp_ret    equ       0         ; caller return address
stk_strnucmp_left   equ       2         ; left-hand string pointer, advanced in place
stk_strnucmp_right  equ       4         ; right-hand string pointer
stk_strnucmp_count  equ       6         ; remaining byte count, decremented in place
                    pshs      y,u       ; preserve caller's Y and U registers
                    ldu       stk_strnucmp_right+4,s ; load right-hand string after saved Y/U
                    ldd       stk_strnucmp_count+4,s ; load compare count after saved Y/U
                    beq       BranchTarget_01 ; zero count compares equal
                    bra       Continue_01 ; compare first byte before advancing right side
Loop_01             ldd       stk_strnucmp_count+4,s ; reload remaining count
                    subd      #1        ; account for one matched byte
                    std       stk_strnucmp_count+4,s ; save remaining count in caller frame
                    beq       ReturnZero_01 ; all requested bytes matched
                    ldb       ,u+       ; advance over matched right-hand byte
                    beq       ReturnZero_01 ; both strings ended at NUL
Continue_01         ldb       ,u        ; load current right-hand byte
                    clra                ; form int argument for toupper
                    pshs      d         ; pass right-hand byte to toupper
                    lbsr      toupper   ; uppercase right-hand byte
                    std       ,s        ; keep uppercased right-hand byte on stack
                    ldx       stk_strnucmp_left+6,s ; load left-hand pointer after saved uppercase byte
                    ldb       ,x+       ; fetch current left-hand byte and advance
                    stx       stk_strnucmp_left+6,s ; save advanced left-hand pointer
                    clra                ; form int argument for toupper
                    pshs      d         ; pass left-hand byte to toupper
                    lbsr      toupper   ; uppercase left-hand byte
                    leas      2,s       ; discard left-hand toupper argument
                    subd      ,s++      ; compare uppercased bytes and discard saved right byte
                    beq       Loop_01   ; continue while uppercased bytes match
                    bra       BranchTarget_01 ; return mismatch result in D
ReturnZero_01       clra                ; return zero for equal prefix
                    clrb                ; return zero for equal prefix
BranchTarget_01     puls      y,u,pc    ; restore registers and return

                    endsect   ;         end current section
