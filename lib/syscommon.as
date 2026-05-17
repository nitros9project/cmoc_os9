                    section   code      ; begin code section

* global error entry point for _os_xxxx calls
_oserr              EXPORT              ; export this symbol
_oserr
                    clra                ; clear A
_errno              EXTERNAL            ; import external symbol
                    std       _errno,y  ; store D to indexed value _errno,y
                    rts                 ; return to caller

* global return entry point for _os_xxxx calls
_osret              EXPORT              ; export this symbol
_osret
                    bcs       _oserr    ; branch if carry is set to _oserr
                    clra                ; clear A
                    clrb                ; clear B
                    rts                 ; return to caller

* global error entry point for traditional calls
_os9err             EXPORT              ; export this symbol
_os9err
                    clra                ; clear A
                    std       _errno,y  ; store D to indexed value _errno,y
                    ldd       #-1       ; load D from immediate value -1
                    rts                 ; return to caller

* global return entry point for traditional calls
_sysret             EXPORT              ; export this symbol
_sysret
                    bcs       _os9err   ; branch if carry is set to _os9err
                    clra                ; clear A
                    clrb                ; clear B
                    rts                 ; return to caller

                    endsect             ; end current section

