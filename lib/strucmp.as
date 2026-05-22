* Adapted from Deek's KLibc strucmp.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strucmp            EXPORT    ;         export case-insensitive strcmp helper

toupper             EXTERN    ;         import character uppercase helper

_strucmp:
stk_strucmp_ret     equ       0         ; caller return address
stk_strucmp_left    equ       2         ; left-hand string pointer
stk_strucmp_right   equ       4         ; right-hand string pointer
                    pshs      u         ; preserve caller's U register
                    ldx       stk_strucmp_left+2,s ; load left-hand string after saved U
                    ldu       stk_strucmp_right+2,s ; load right-hand string after saved U
                    bra       Continue_01 ; compare first byte before advancing right side
Loop_01             ldb       ,u+       ; advance over matched right-hand byte
                    beq       BranchTarget_01 ; equal strings ended at NUL
Continue_01         ldb       ,u        ; load current right-hand byte
                    clra                ; form int argument for toupper
                    pshs      d,x       ; save right byte and left pointer
                    lbsr      toupper   ; uppercase right-hand byte
                    leas      2,s       ; discard toupper argument, leaving saved X
                    ldx       ,s        ; reload left-hand pointer
                    std       ,s        ; save uppercased right byte for comparison
                    ldb       ,x+       ; fetch current left-hand byte and advance
                    clra                ; form int argument for toupper
                    pshs      d,x       ; save left byte and advanced left pointer
                    lbsr      toupper   ; uppercase left-hand byte
                    leas      2,s       ; discard toupper argument, leaving saved X
                    puls      x         ; restore advanced left-hand pointer
                    subd      ,s++      ; compare uppercased bytes and discard saved right byte
                    beq       Loop_01   ; continue while uppercased bytes match
BranchTarget_01     puls      u,pc      ; restore U and return comparison result

                    endsect   ;         end current section
