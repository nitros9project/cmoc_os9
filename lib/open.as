* Compact assembly implementation of open()/close().

                    section   code      ; begin code section

_open               EXPORT              ; export this symbol
_close              EXPORT              ; export this symbol

_os9err             EXTERNAL            ; import external symbol
_sysret             EXTERNAL            ; import external symbol

_open
                    ldx       2,s       ; load X from stack-relative value 2,s
                    lda       5,s       ; load A from stack-relative value 5,s
                    os9       $84       ; invoke OS-9 system call $84
                    lbcs      _os9err   ; long branch if carry is set to _os9err
                    tfr       a,b       ; transfer A,B
                    clra                ; clear A
                    rts                 ; return to caller

_close
                    lda       3,s       ; load A from stack-relative value 3,s
                    os9       $8F       ; invoke OS-9 system call $8F
                    lbra      _sysret   ; long branch unconditionally to _sysret

                    endsect             ; end current section
