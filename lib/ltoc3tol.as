* Adapted from cmoc_os9/lib/todo/ltoc3tol.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_c3tol              EXPORT    ;         export this symbol
_ltoc3              EXPORT    ;         export this symbol

_c3tol:
stk_c3tol_saved_u   equ       0         ; saved U register after pshs u
stk_c3tol_ret       equ       2         ; caller return address after pshs u
stk_c3tol_dest      equ       4         ; destination long pointer
stk_c3tol_source    equ       6         ; source 3-byte value pointer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_c3tol_dest,s ; load destination long pointer
                    ldx       stk_c3tol_source,s ; load source 3-byte value pointer
                    clra                ; zero-extend source into the high byte of the long
                    ldb       ,x+       ; fetch first source byte and advance source
                    std       ,u++      ; store long bytes 0/1 and advance destination
                    ldd       ,x++      ; fetch remaining two source bytes
                    std       ,u++      ; store long bytes 2/3 and advance destination
                    puls      u,pc      ; restore registers and return

_ltoc3:
stk_ltoc3_saved_u   equ       0         ; saved U register after pshs u
stk_ltoc3_ret       equ       2         ; caller return address after pshs u
stk_ltoc3_dest      equ       4         ; destination 3-byte value pointer
stk_ltoc3_value     equ       6         ; source long value on caller stack
stk_ltoc3_value_low3 equ       7         ; low three bytes of source long value
                    pshs      u         ; preserve caller's U register
                    leau      stk_ltoc3_value_low3,s ; point at low three bytes of source long
                    ldx       stk_ltoc3_dest,s ; load destination 3-byte value pointer
                    lda       ,u+       ; copy first kept byte from the long value
                    sta       ,x+       ; store first byte and advance destination
                    ldd       ,u++      ; copy remaining two kept bytes
                    std       ,x++      ; store remaining bytes and advance destination
                    puls      u,pc      ; restore registers and return

                    endsect   ;         end current section
