* Compact assembly implementation of puts().

                    section   code      ; begin code section

_puts               EXPORT    ;         export line-output helper

__iob               EXTERNAL  ;         import stdio stream table
_fputs              EXTERNAL  ;         import string-to-stream helper
_putc               EXTERNAL  ;         import character-output helper

_puts:
stk_puts_ret        equ       0         ; caller return address
stk_puts_string     equ       2         ; string pointer argument
                    pshs      u         ; preserve caller's U register
                    leax      __iob+13,y ; select stdout FILE entry
                    ldd       stk_puts_string+2,s ; load string pointer after saved U
                    pshs      d,x       ; stage string and stdout for fputs/putc calls
                    lbsr      _fputs    ; emit the string body through stdio
                    ldd       #$000D    ; append OS-9 carriage return as a full int
                    std       ,s        ; replace staged char (zero high byte so putc
*                                       ; returns the non-negative character, not the
*                                       ; sign-extended high byte of the string pointer)
                    lbsr      _putc     ; emit trailing carriage return to stdout
                    leas      4,s       ; discard staged string/stdout arguments
                    puls      u,pc      ; restore registers and return

                    endsect   ;         end current section
