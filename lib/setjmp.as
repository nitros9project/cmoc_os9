                    section   code      ; begin code section

_setjmp             EXPORT              ; export this symbol
_longjmp            EXPORT              ; export this symbol

_setjmp
                    ldx       2,s       ; load X from stack-relative value 2,s
                    ldd       ,s        ; load D from memory pointed to by S
                    std       2,x       ; store D to indexed value 2,x
                    sty       6,x       ; store Y to indexed value 6,x
                    stu       4,x       ; store U to indexed value 4,x
                    sts       ,x        ; store S to memory pointed to by X
                    clra                ; clear A
                    clrb                ; clear B
                    rts                 ; return to caller

_longjmp
                    ldx       2,s       ; load X from stack-relative value 2,s
                    ldy       6,x       ; load Y from indexed value 6,x
                    ldu       4,x       ; load U from indexed value 4,x
                    ldd       4,s       ; load D from stack-relative value 4,s
                    bne       longjmp1  ; branch if not equal to longjmp1
                    ldb       #1        ; load B from immediate value 1
longjmp1
                    lds       ,x        ; load S from memory pointed to by X
                    leas      2,s       ; adjust S using 2,s
                    jmp       [2,x]     ; jump to [2,x]

                    endsect             ; end current section
