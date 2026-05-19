* Adapted from Deek's KLibc strings_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strcat             EXPORT    ;         export strcat helper
_strcpy             EXPORT    ;         export strcpy helper
_strend             EXPORT    ;         export end-of-string pointer helper

_strcat:
stk_strcat_ret      equ       0         ; caller return address
stk_strcat_dest     equ       2         ; destination string pointer
stk_strcat_source   equ       4         ; source string pointer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_strcat_source+2,s ; load source pointer after saved U
                    ldx       stk_strcat_dest+2,s ; load destination pointer after saved U
                    bsr       Subroutine_01 ; find destination NUL terminator
                    tfr       d,x       ; copy append position into X
                    bra       Loop_01   ; copy source string into destination tail

_strcpy:
stk_strcpy_ret      equ       0         ; caller return address
stk_strcpy_dest     equ       2         ; destination string pointer
stk_strcpy_source   equ       4         ; source string pointer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_strcpy_source+2,s ; load source pointer after saved U
                    ldx       stk_strcpy_dest+2,s ; load destination pointer after saved U
Loop_01             ldb       ,u+       ; copy next source byte
                    stb       ,x+       ; store byte into destination
                    bne       Loop_01   ; continue through the terminating NUL
                    ldd       stk_strcpy_dest+2,s ; return destination pointer
                    puls      u,pc      ; restore U and return

_strend:
stk_strend_ret      equ       0         ; caller return address
stk_strend_string   equ       2         ; string pointer
                    ldx       stk_strend_string,s ; load string pointer
Subroutine_01       ldb       ,x+       ; scan next byte and advance
                    bne       Subroutine_01 ; continue until the NUL terminator is found
                    leax      -1,x      ; back up to the NUL terminator
                    tfr       x,d       ; return pointer to string terminator
                    rts                 ; return to caller

                    endsect   ;         end current section
