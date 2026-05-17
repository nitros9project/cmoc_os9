* Compact assembly implementation of puts()/fputs().

                    section   code      ; begin code section

_puts               EXPORT              ; export this symbol
_fputs              EXPORT              ; export this symbol

__iob               EXTERNAL            ; import external symbol
_putc               EXTERNAL            ; import external symbol

_puts
                    pshs      u         ; save U on the hardware stack
                    leax      __iob+13,y ; compute effective address into X from __iob+13,y
                    ldd       4,s       ; load D from stack-relative value 4,s
                    pshs      d,x       ; save D,X on the hardware stack
                    bsr       _fputs    ; branch to subroutine to _fputs
                    ldb       #$0D      ; load B from immediate value $0D
                    stb       1,s       ; store B to stack-relative value 1,s
                    lbsr      _putc     ; long branch to subroutine to _putc
                    leas      4,s       ; adjust S using 4,s
                    puls      u,pc      ; restore registers and return

_fputs
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    pshs      d,x       ; save D,X on the hardware stack
                    bra       L_fputs_loop ; branch unconditionally to L_fputs_loop
L_fputs_emit
                    stb       1,s       ; store B to stack-relative value 1,s
                    lbsr      _putc     ; long branch to subroutine to _putc
L_fputs_loop
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    bne       L_fputs_emit ; branch if not equal to L_fputs_emit
                    leas      4,s       ; adjust S using 4,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
