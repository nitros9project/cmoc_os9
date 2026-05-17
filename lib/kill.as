* Adapted from old Kreider process.a.
* kill(pid, signal) -> 0 on success, -1 on error.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_kill               EXPORT              ; export this symbol
_sysret             EXTERNAL            ; import external symbol

_kill
                    lda       3,s       ; get process id
                    ldb       5,s       ; get signal number
                    os9       F_Send    ; invoke OS-9 system call F_Send
                    lbra      _sysret   ; long branch unconditionally to _sysret

                    endsect             ; end current section
