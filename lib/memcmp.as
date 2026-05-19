* Adapted from Deek's KLibc memcmp.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_memcmp             EXPORT    ;         export this symbol

_memcmp:
stk_memcmp_saved_yu equ       0         ; saved Y/U registers after pshs y,u
stk_memcmp_ret      equ       4         ; caller return address after pshs y,u
stk_memcmp_left     equ       6         ; first buffer pointer
stk_memcmp_right    equ       8         ; second buffer pointer
stk_memcmp_count    equ       10        ; byte count
                    pshs      y,u       ; preserve registers used as compare cursor/count
                    ldx       stk_memcmp_left,s ; load first buffer pointer
                    cmpx      stk_memcmp_right,s ; identical pointers compare equal
                    beq       memcmp_equal ; skip scan when both pointers match
                    ldu       stk_memcmp_right,s ; load second buffer pointer
                    ldy       stk_memcmp_count,s ; load remaining byte count
                    beq       memcmp_equal ; zero-length buffers compare equal
memcmp_loop         ldb       ,u+       ; fetch next byte from second buffer
                    subb      ,x+       ; compare with next byte from first buffer
                    beq       memcmp_next ; continue while bytes match
                    negb                ; return first - second rather than second - first
                    sex                 ; sign-extend B into A to form D
                    bra       memcmp_done ; return non-zero comparison result
memcmp_next         leay      -1,y      ; consume one compared byte
                    bne       memcmp_loop ; continue until count reaches zero
memcmp_equal        clra                ; equal result high byte
                    clrb                ; equal result low byte
memcmp_done         puls      y,u,pc    ; restore registers and return

                    endsect   ;         end current section
