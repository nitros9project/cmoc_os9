* Adapted from cmoc_os9/lib/todo/devtyp.as

                    section   code      ; begin code section

_devtyp             EXPORT              ; export this symbol
_isatty             EXPORT              ; export this symbol

_os9err             EXTERNAL            ; import external symbol

_isatty
                    ldd       2,s       ; load D from stack-relative value 2,s
                    pshs      d         ; save D on the hardware stack
                    bsr       _devtyp   ; branch to subroutine to _devtyp
                    std       ,s++      ; store D to memory pointed to by S+, then advance S+
                    beq       tty_yes   ; branch if equal/zero to tty_yes
                    clrb                ; clear B
                    rts                 ; return to caller
tty_yes
                    incb                ; increment B
                    rts                 ; return to caller

_devtyp
                    lda       3,s       ; load A from stack-relative value 3,s
                    clrb                ; clear B
                    leas      -32,s     ; adjust S using -32,s
                    leax      ,s        ; compute effective address into X from ,s
                    os9       $8D       ; invoke OS-9 system call $8D
                    lda       ,s        ; load A from memory pointed to by S
                    leas      32,s      ; adjust S using 32,s
                    lblo      _os9err   ; long branch if lower to _os9err
                    tfr       a,b       ; transfer A,B
                    clra                ; clear A
                    rts                 ; return to caller

                    endsect             ; end current section
