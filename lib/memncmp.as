_memncmp            EXPORT    ;         export memncmp entry point

                    section   code      ; begin code section

_memncmp:
stk_memncmp_saved_yu equ       0         ; saved Y/U registers after pshs y,u
stk_memncmp_ret     equ       4         ; caller return address after pshs y,u
stk_memncmp_left    equ       6         ; first buffer pointer
stk_memncmp_right   equ       8         ; second buffer pointer
stk_memncmp_count   equ       10        ; maximum byte count
                    pshs      y,u       ; preserve Y and U across the compare
                    ldx       stk_memncmp_left,s ; load first buffer pointer
                    ldu       stk_memncmp_right,s ; load second buffer pointer
                    ldy       stk_memncmp_count,s ; load remaining byte count
                    beq       memncmp_equal ; return equal immediately for zero length
                    bra       memncmp_compare ; enter compare loop
memncmp_next        leay      -1,y      ; consume one byte from the remaining count
                    beq       memncmp_equal ; stop once all bytes matched
                    ldb       ,u+       ; advance second pointer to the next byte
memncmp_compare     ldb       ,u        ; load current byte from second buffer
                    subb      ,x+       ; compare against current byte from first buffer
                    beq       memncmp_next ; continue while bytes are equal
                    negb                ; normalize sign so result matches first-second
                    sex                 ; sign-extend compare result into D
                    bra       memncmp_done ; return non-zero compare result
memncmp_equal       clra                ; high byte zero for equal result
                    clrb                ; low byte zero for equal result
memncmp_done        puls      y,u,pc    ; restore registers and return

                    endsect   ;         end code section
