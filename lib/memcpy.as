* Adapted from Deek's KLibc memcpy.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_memcpy             EXPORT    ;         export this symbol

_memcpy:
stk_memcpy_saved_yu equ       0         ; saved Y/U registers after pshs y,u
stk_memcpy_ret      equ       4         ; caller return address after pshs y,u
stk_memcpy_dest     equ       6         ; destination pointer
stk_memcpy_source   equ       8         ; source pointer
stk_memcpy_count    equ       10        ; byte count
stk_memcpy_orig_dest equ       0         ; saved destination pointer after pshs u
                    pshs      y,u       ; preserve registers used as copy pointers
                    ldu       stk_memcpy_dest,s ; load destination pointer
                    ldy       stk_memcpy_source,s ; load source pointer
                    ldd       stk_memcpy_count,s ; load byte count
                    pshs      u         ; save original destination pointer for return
                    lsra                ; divide count by 2, preserving odd-byte carry
                    rorb
                    tfr       d,x       ; word count into X
                    bcc       memcpy_words ; skip odd-byte prologue when count is even
                    lda       ,y+       ; copy the leading odd byte
                    sta       ,u+
memcpy_words        leax      0,x       ; set Z for the word-copy count
                    beq       memcpy_done ; no word copies left
memcpy_word_loop    ldd       ,y++      ; copy two bytes per iteration
                    std       ,u++
                    leax      -1,x
                    bne       memcpy_word_loop
memcpy_done         ldd       stk_memcpy_orig_dest,s ; return original destination pointer
                    leas      2,s       ; drop saved destination pointer
                    puls      y,u,pc    ; restore registers and return

                    endsect   ;         end current section
