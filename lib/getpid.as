* Adapted from cmoc_os9/lib/ported/mktemp.as and old Kreider id.a.
* Return the current process ID as an int.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_getpid             EXPORT              ; export this symbol

_getpid
                    pshs      y         ; save data pointer
                    os9       F_ID      ; invoke OS-9 system call F_ID
                    puls      y         ; restore Y from the hardware stack
                    tfr       a,b       ; transfer A,B
                    clra                ; clear A
                    rts                 ; return to caller

                    endsect             ; end current section
