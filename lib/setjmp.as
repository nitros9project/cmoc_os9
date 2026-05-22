                    section   code      ; begin code section

_setjmp             EXPORT    ;         export non-local jump context saver
_longjmp            EXPORT    ;         export non-local jump restorer

_setjmp:
stk_setjmp_ret      equ       0         ; caller return address
stk_setjmp_env      equ       2         ; jmp_buf pointer argument
                    ldx       stk_setjmp_env,s ; load caller's jump buffer pointer
                    ldd       stk_setjmp_ret,s ; copy return address being saved
                    std       2,x       ; save resume PC in jump buffer
                    sty       6,x       ; save data pointer in jump buffer
                    stu       4,x       ; save caller U in jump buffer
                    sts       ,x        ; save stack pointer in jump buffer
                    clra                ; setjmp returns zero on the direct return
                    clrb                ; setjmp returns zero on the direct return
                    rts                 ; return to caller

_longjmp:
stk_longjmp_ret     equ       0         ; caller return address, not used after restoring context
stk_longjmp_env     equ       2         ; saved jmp_buf pointer
stk_longjmp_value   equ       4         ; value to return from saved setjmp site
                    ldx       stk_longjmp_env,s ; load saved jump buffer pointer
                    ldy       6,x       ; restore saved data pointer
                    ldu       4,x       ; restore saved U register
                    ldd       stk_longjmp_value,s ; load requested setjmp return value
                    bne       longjmp1  ; keep non-zero return values unchanged
                    ldb       #1        ; longjmp(env, 0) must return 1 from setjmp
longjmp1
                    lds       ,x        ; restore saved stack pointer
                    leas      2,s       ; discard saved return-address slot from restored frame
                    jmp       [2,x]     ; resume at saved setjmp return address

                    endsect   ;         end current section
