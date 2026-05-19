                    section   code      ; begin code section

argv                EXTERN    ;         import external symbol

__prgname           EXPORT    ;         export program-name helper
__prgname:
stk_prgname_ret     equ       0         ; caller return address
                    ldd       argv,y    ; return argv[0] pointer from runtime storage
                    rts                 ; return program name pointer

                    endsect   ;         end current section
