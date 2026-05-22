                    section   code      ; begin code section

* global error entry point for _os_xxxx calls
_oserr              EXPORT    ;         export modern _os_* error return helper
_oserr:
                    clra                ; keep OS-9 error code in low byte only
_errno              EXTERNAL  ;         import C errno storage
                    std       _errno,y  ; save error code into errno
                    rts                 ; return to caller

* global return entry point for _os_xxxx calls
_osret              EXPORT    ;         export modern _os_* success/error return helper
_osret:
                    bcs       _oserr    ; convert carry-set OS-9 errors into errno
                    clra                ; return zero on success
                    clrb                ; return zero on success
                    rts                 ; return to caller

* global error entry point for traditional calls
_os9err             EXPORT    ;         export traditional -1/errno error helper
_os9err:
                    clra                ; keep OS-9 error code in low byte only
                    std       _errno,y  ; save error code into errno
                    ldd       #-1       ; return -1 for traditional C wrappers
                    rts                 ; return to caller

* global return entry point for traditional calls
_sysret             EXPORT    ;         export traditional success/error return helper
_sysret:
                    bcs       _os9err   ; convert carry-set OS-9 errors into -1/errno
                    clra                ; return zero on success
                    clrb                ; return zero on success
                    rts                 ; return to caller

                    endsect   ;         end current section
