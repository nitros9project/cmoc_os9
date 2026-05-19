* Adapted from Deek's KLibc stringsu_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strucat            EXPORT    ;         export uppercase strcat helper
_strucpy            EXPORT    ;         export uppercase strcpy helper

toupper             EXTERN    ;         import character uppercase helper

_strucat:
stk_strucat_ret     equ       0         ; caller return address
stk_strucat_dest    equ       2         ; destination string pointer
stk_strucat_source  equ       4         ; source string pointer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_strucat_source+2,s ; load source pointer after saved U
                    ldx       stk_strucat_dest+2,s ; load destination pointer after saved U
Loop_01             ldb       ,x+       ; scan destination byte and advance
                    bne       Loop_01   ; continue until destination NUL
                    leax      -1,x      ; back up to append over NUL
                    bra       Loop_02   ; copy uppercased source into destination tail

_strucpy:
stk_strucpy_ret     equ       0         ; caller return address
stk_strucpy_dest    equ       2         ; destination string pointer
stk_strucpy_source  equ       4         ; source string pointer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_strucpy_source+2,s ; load source pointer after saved U
                    ldx       stk_strucpy_dest+2,s ; load destination pointer after saved U
Loop_02             ldb       ,u+       ; fetch next source byte
                    clra                ; form int argument for toupper
                    pshs      d,x       ; save character argument and destination pointer
                    lbsr      toupper   ; uppercase the source byte
                    leas      2,s       ; discard toupper argument, leaving saved X
                    puls      x         ; restore destination pointer
                    stb       ,x+       ; store uppercased byte and advance destination
                    bne       Loop_02   ; continue through source NUL
                    ldd       stk_strucpy_dest+2,s ; return destination pointer
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
