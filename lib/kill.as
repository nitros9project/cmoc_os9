* Adapted from old Kreider process.a.
* kill(pid, signal) -> 0 on success, -1 on error.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_kill               EXPORT    ;         export this symbol
_sysret             EXTERNAL  ;         import external symbol

_kill:
stk_kill_ret        equ       0         ; caller return address
stk_kill_pid        equ       2         ; process ID argument
stk_kill_pid_byte   equ       3         ; low byte passed to F_Send in A
stk_kill_signal     equ       4         ; signal number argument
stk_kill_signal_byte equ       5         ; low byte passed to F_Send in B
                    lda       stk_kill_pid_byte,s ; pass target process ID to OS-9
                    ldb       stk_kill_signal_byte,s ; pass signal number to OS-9
                    os9       F_Send    ; send the signal to the target process
                    lbra      _sysret   ; return OS-9 carry/status through shared helper

                    endsect   ;         end current section
