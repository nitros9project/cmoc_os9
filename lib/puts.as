* Compact assembly implementation of puts()/fputs().

                    section   code      ; begin code section

_puts               EXPORT    ;         export line-output helper
_fputs              EXPORT    ;         export string-to-stream helper

__iob               EXTERNAL  ;         import stdio stream table
_putc               EXTERNAL  ;         import character-output helper

_puts:
stk_puts_ret        equ       0         ; caller return address
stk_puts_string     equ       2         ; string pointer argument
                    pshs      u         ; preserve caller's U register
                    leax      __iob+13,y ; select stdout FILE entry
                    ldd       stk_puts_string+2,s ; load string pointer after saved U
                    pshs      d,x       ; stage string and stdout for fputs/putc calls
                    bsr       _fputs    ; emit the string body
                    ldb       #$0D      ; append OS-9 carriage return for puts()
                    stb       1,s       ; replace staged low byte with newline character
                    lbsr      _putc     ; emit trailing carriage return to stdout
                    leas      4,s       ; discard staged string/stdout arguments
                    puls      u,pc      ; restore registers and return

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
