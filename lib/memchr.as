* Adapted from Deek's KLibc memchr.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_memchr             EXPORT    ;         export this symbol

_memchr:
stk_memchr_saved_xu equ       0         ; saved X/U registers after pshs x,u
stk_memchr_ret      equ       4         ; caller return address after pshs x,u
stk_memchr_buffer   equ       6         ; buffer pointer
stk_memchr_char     equ       8         ; 16-bit search character argument
stk_memchr_char_byte equ       9         ; low byte compared against buffer bytes
stk_memchr_count    equ       10        ; maximum byte count
                    pshs      x,u       ; preserve registers used as cursor/count
                    ldu       stk_memchr_buffer,s ; load buffer cursor
                    ldx       stk_memchr_count,s ; load remaining byte count
                    beq       memchr_not_found ; zero length cannot contain the byte
memchr_scan_loop    lda       ,u+       ; fetch next byte and advance cursor
                    cmpa      stk_memchr_char_byte,s ; compare with requested byte
                    bne       memchr_next ; keep scanning while bytes differ
                    leau      -1,u      ; back up to the matching byte
                    tfr       u,d       ; return pointer to the matching byte
                    bra       memchr_done ; finish with non-NULL pointer
memchr_next         leax      -1,x      ; consume one byte from remaining count
                    bne       memchr_scan_loop ; continue until count reaches zero
memchr_not_found    clra                ; return NULL high byte
                    clrb                ; return NULL low byte
memchr_done         puls      x,u,pc    ; restore registers and return

                    endsect   ;         end current section
