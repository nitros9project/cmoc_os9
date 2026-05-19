* Adapted from cmoc_os9/lib/ported/mktemp.as and old Kreider id.a.
* Return the current process ID as an int.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_getpid             EXPORT    ;         export this symbol

_getpid:
stk_getpid_ret      equ       0         ; caller return address
                    pshs      y         ; save data pointer
                    os9       F_ID      ; invoke OS-9 system call F_ID
                    puls      y         ; restore CMOC data pointer
                    tfr       a,b       ; move process ID into low byte of int result
                    clra                ; clear high byte of int result
                    rts                 ; return process ID

                    endsect   ;         end current section
