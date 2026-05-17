_memncmp            EXPORT              ; export memncmp entry point

                    section   code      ; begin code section

_memncmp
                    pshs      y,u       ; preserve Y and U across the compare
                    ldx       6,s       ; load first buffer pointer
                    ldu       8,s       ; load second buffer pointer
                    ldy       10,s      ; load remaining byte count
                    beq       L001f     ; return equal immediately for zero length
                    bra       L0015     ; enter compare loop
L000d               leay      -1,y      ; consume one byte from the remaining count
                    beq       L001f     ; stop once all bytes matched
                    ldb       ,u+       ; advance second pointer to the next byte
L0015               ldb       ,u        ; load current byte from second buffer
                    subb      ,x+       ; compare against current byte from first buffer
                    beq       L000d     ; continue while bytes are equal
                    negb                ; normalize sign so result matches first-second
                    sex                 ; sign-extend compare result into D
                    bra       L0021     ; return non-zero compare result
L001f               clra                ; high byte zero for equal result
                    clrb                ; low byte zero for equal result
L0021               puls      y,u,pc    ; restore registers and return

                    endsect             ; end code section
