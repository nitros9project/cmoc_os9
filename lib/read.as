* Compact assembly implementation of read()/readln().

                    section   code      ; begin code section

_read               EXPORT              ; export this symbol
_readln             EXPORT              ; export this symbol

_os9err             EXTERNAL            ; import external symbol

_read
                    pshs      y         ; save Y on the hardware stack
                    lda       5,s       ; load A from stack-relative value 5,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldy       8,s       ; load Y from stack-relative value 8,s
                    pshs      y         ; save Y on the hardware stack
                    os9       $89       ; invoke OS-9 system call $89
L_read_common
                    bcc       L_read_exit ; branch if carry is clear to L_read_exit
                    cmpb      #$D3      ; compare B against immediate value $D3
                    bne       L_read_error ; branch if not equal to L_read_error
                    clra                ; clear A
                    clrb                ; clear B
                    puls      x,y,pc    ; restore registers and return
L_read_error
                    puls      x,y       ; restore X,Y from the hardware stack
                    lbra      _os9err   ; long branch unconditionally to _os9err
L_read_exit
                    tfr       y,d       ; transfer Y,D
                    puls      x,y,pc    ; restore registers and return

_readln
                    pshs      y         ; save Y on the hardware stack
                    lda       5,s       ; load A from stack-relative value 5,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldy       8,s       ; load Y from stack-relative value 8,s
                    pshs      y         ; save Y on the hardware stack
                    os9       $8B       ; invoke OS-9 system call $8B
                    bra       L_read_common ; branch unconditionally to L_read_common

                    endsect             ; end current section
