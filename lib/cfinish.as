                    use       ../include/os9.d ; shared OS-9 service constants

__exit              EXPORT    ;         export exit wrapper with cleanup
_exit               EXPORT    ;         export raw process-exit entry point

__dumprof           EXTERNAL  ;         profile dump hook
__tidyup            EXTERNAL  ;         stdio/runtime cleanup hook

                    section   code      ; begin code section

__exit:
                    lbsr      __dumprof ; flush profiling data before exit
                    lbsr      __tidyup  ; flush and close runtime-managed resources
                    bra       _exit     ; tail into the raw exit path

_exit:
stk_exit_ret        equ       0         ; caller return address, unused because F$Exit does not return
stk_exit_status     equ       2         ; process exit status argument
                    ldd       stk_exit_status,s ; pass caller-supplied status to F$Exit
                    os9       F_Exit    ; terminate the current process

                    endsect   ;         end code section
