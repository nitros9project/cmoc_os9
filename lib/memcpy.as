* Adapted from Deek's KLibc memcpy.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_memcpy             EXPORT              ; export this symbol

_memcpy
                    pshs      y,u       ; save Y,U on the hardware stack
                    ldu       6,s       ; destination pointer
                    ldy       8,s       ; source pointer
                    ldd       10,s      ; byte count
                    pshs      u         ; save original destination pointer for return
                    lsra                ; divide count by 2, preserving odd-byte carry
                    rorb
                    tfr       d,x       ; word count into X
                    bcc       BranchTarget_01 ; skip odd-byte prologue when count is even
                    lda       ,y+       ; copy the leading odd byte
                    sta       ,u+
BranchTarget_01     leax      0,x       ; set Z for the word-copy count
                    beq       BranchTarget_02 ; no word copies left
Loop_01             ldd       ,y++      ; copy two bytes per iteration
                    std       ,u++
                    leax      -1,x
                    bne       Loop_01
BranchTarget_02     ldd       ,s        ; return original destination pointer
                    leas      2,s       ; drop saved destination pointer
                    puls      y,u,pc    ; restore registers and return

                    endsect             ; end current section
