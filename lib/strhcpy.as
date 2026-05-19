* Adapted from Deek's KLibc strhcpy_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strhcpy            EXPORT    ;         export high-bit-terminated string copy helper

_strhcpy:
stk_strhcpy_ret     equ       0         ; caller return address
stk_strhcpy_dest    equ       2         ; destination pointer
stk_strhcpy_source  equ       4         ; high-bit-terminated source pointer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_strhcpy_dest+2,s ; load destination pointer after saved U
                    ldx       stk_strhcpy_source+2,s ; load source pointer after saved U
Loop_01             ldb       ,x+       ; copy next source byte
                    stb       ,u+       ; store byte and advance destination
                    bpl       Loop_01   ; continue until high bit marks final byte
                    andb      #$7f      ; strip high-bit terminator from final character
                    stb       -1,u      ; replace stored final character
                    clr       ,u        ; append C NUL terminator
                    ldd       stk_strhcpy_dest+2,s ; return destination pointer
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
