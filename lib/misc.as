* Adapted from cmoc_os9/lib/todo/misc.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_lock               EXPORT              ; export this symbol
_pause              EXPORT              ; export this symbol
_sync               EXPORT              ; export this symbol
_crc                EXPORT              ; export this symbol
_prerr              EXPORT              ; export this symbol
_tsleep             EXPORT              ; export this symbol

_os9err             EXTERNAL            ; import external symbol

_lock
                    rts                 ; return to caller

_pause
                    ldx       #0        ; load X from immediate value 0
                    clrb                ; clear B
                    os9       F_Sleep   ; invoke OS-9 system call F_Sleep
                    lbra      _os9err   ; long branch unconditionally to _os9err

_sync
                    rts                 ; return to caller

_crc
                    pshs      y,u       ; save Y,U on the hardware stack
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldy       8,s       ; load Y from stack-relative value 8,s
                    ldu       10,s      ; load U from stack-relative value 10,s
                    os9       F_CRC     ; invoke OS-9 system call F_CRC
                    puls      y,u,pc    ; restore registers and return

_prerr
                    lda       3,s       ; load A from stack-relative value 3,s
                    ldb       5,s       ; load B from stack-relative value 5,s
                    os9       F_PErr    ; invoke OS-9 system call F_PErr
                    lblo      _os9err   ; long branch if lower to _os9err
                    rts                 ; return to caller

_tsleep
                    ldx       2,s       ; load X from stack-relative value 2,s
                    os9       F_Sleep   ; invoke OS-9 system call F_Sleep
                    lblo      _os9err   ; long branch if lower to _os9err
                    tfr       x,d       ; transfer X,D
                    rts                 ; return to caller

                    endsect             ; end current section
