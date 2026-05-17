* Compact assembly implementation of write()/writeln().

                    section   code      ; begin code section

_write              EXPORT              ; export this symbol
_writeln            EXPORT              ; export this symbol

_os9err             EXTERNAL            ; import external symbol

_write
                    pshs      y         ; save Y on the hardware stack
                    ldy       8,s       ; load Y from stack-relative value 8,s
                    beq       L_write_exit ; branch if equal/zero to L_write_exit
                    lda       5,s       ; load A from stack-relative value 5,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    os9       $8A       ; invoke OS-9 system call $8A
L_write_common
                    bcc       L_write_exit ; branch if carry is clear to L_write_exit
                    puls      y         ; restore Y from the hardware stack
                    lbra      _os9err   ; long branch unconditionally to _os9err
L_write_exit
                    tfr       y,d       ; transfer Y,D
                    puls      y,pc      ; restore registers and return

_writeln
                    pshs      y         ; save Y on the hardware stack
                    ldy       8,s       ; load Y from stack-relative value 8,s
                    beq       L_write_exit ; branch if equal/zero to L_write_exit
                    lda       5,s       ; load A from stack-relative value 5,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    os9       $8C       ; invoke OS-9 system call $8C
                    bra       L_write_common ; branch unconditionally to L_write_common

                    endsect             ; end current section
