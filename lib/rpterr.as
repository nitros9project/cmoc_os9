                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_errno              EXTERNAL  ;         import C errno storage

_rpterr             EXPORT    ;         export report-error-to-parent helper
_rpterr:
stk_rpterr_ret      equ       0         ; caller return address
                    std       _errno,y  ; record the caller's error value in errno
                    pshs      b,y       ; preserve signal/error byte and data pointer across F_ID
                    os9       F_ID      ; fetch current process identity for F_Send setup
                    puls      b,y       ; restore signal/error byte and data pointer
                    os9       F_Send    ; send the error byte as a signal/status notification
                    rts                 ; return to caller

                    endsect   ;         end current section
