* Adapted from Deek's KLibc memccpy.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_memccpy            EXPORT    ;         export this symbol

_memccpy:
stk_memccpy_saved_yu equ       0         ; saved Y/U registers after pshs y,u
stk_memccpy_ret     equ       4         ; caller return address after pshs y,u
stk_memccpy_dest    equ       6         ; destination buffer pointer
stk_memccpy_source  equ       8         ; source buffer pointer
stk_memccpy_char    equ       10        ; 16-bit stop character argument
stk_memccpy_char_byte equ       11        ; low byte compared against copied bytes
stk_memccpy_count   equ       12        ; maximum byte count
                    pshs      y,u       ; preserve registers used as copy pointers/count
                    ldu       stk_memccpy_source,s ; load source pointer
                    ldx       stk_memccpy_dest,s ; load destination pointer
                    ldy       stk_memccpy_count,s ; load byte count
                    beq       memccpy_not_found ; zero length cannot copy the stop byte
memccpy_copy_loop   lda       ,u+       ; fetch next source byte and advance source
                    sta       ,x+       ; copy byte to destination and advance destination
                    cmpa      stk_memccpy_char_byte,s ; did this byte match the stop character?
                    bne       memccpy_next ; continue until match or count exhaustion
                    tfr       x,d       ; return pointer to the byte after the copied stop character
                    bra       memccpy_done ; finish with non-NULL return pointer
memccpy_next        leay      -1,y      ; consume one byte from remaining count
                    bne       memccpy_copy_loop ; keep copying while bytes remain
memccpy_not_found   clra                ; return NULL when stop character was not copied
                    clrb                ; complete NULL return value
memccpy_done        puls      y,u,pc    ; restore registers and return

                    endsect   ;         end current section
