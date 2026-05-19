* Adapted from Deek's KLibc strass_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

__strass            EXPORT    ;         export counted string assignment helper

__strass:
stk_strass_ret      equ       0         ; caller return address
stk_strass_dest     equ       2         ; destination pointer
stk_strass_source   equ       4         ; source pointer
stk_strass_count    equ       6         ; byte count to copy
                    pshs      y,u       ; preserve destination/source index registers
                    ldu       stk_strass_dest+4,s ; load destination pointer after saved Y/U
                    ldy       stk_strass_source+4,s ; load source pointer after saved Y/U
                    ldd       stk_strass_count+4,s ; load byte count after saved Y/U
                    lsra                ; divide byte count by two
                    rorb                ; keep odd byte in carry while forming word count
                    tfr       d,x       ; use X as the word-copy count
                    bcc       BranchTarget_01 ; skip byte copy when count was even
                    lda       ,y+       ; copy leading odd byte from source
                    sta       ,u+       ; store leading odd byte to destination
BranchTarget_01     stx       -2,s      ; update flags from word count without changing X
                    beq       BranchTarget_02 ; no word copies remain
Loop_01             ldd       ,y++      ; copy next two source bytes
                    std       ,u++      ; store next two destination bytes
                    leax      -1,x      ; count down copied words
                    bne       Loop_01   ; continue until all words are copied
BranchTarget_02     puls      y,u,pc    ; restore registers and return

                    endsect   ;         end current section
