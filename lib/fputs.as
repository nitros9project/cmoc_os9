* Compact assembly implementation of fputs().

                    section   code      ; begin code section

_fputs              EXPORT    ;         export string-to-stream helper

_putc               EXTERNAL  ;         import character-output helper

_fputs:
stk_fputs_ret       equ       0         ; caller return address
stk_fputs_string    equ       2         ; string pointer argument
stk_fputs_file      equ       4         ; FILE pointer argument
                    pshs      u         ; preserve caller's U register
                    ldu       stk_fputs_string+2,s ; load source string pointer after saved U
                    ldx       stk_fputs_file+2,s ; load destination FILE pointer after saved U
                    pshs      d,x       ; stage character slot and FILE pointer for putc()
                    bra       L_fputs_loop ; enter NUL-terminated string scan
L_fputs_emit
                    stb       1,s       ; store current character in staged putc argument
                    lbsr      _putc     ; emit one character to the FILE stream
L_fputs_loop
                    ldb       ,u+       ; fetch next string byte and advance source pointer
                    bne       L_fputs_emit ; continue until NUL terminator
                    leas      4,s       ; discard staged putc arguments
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
