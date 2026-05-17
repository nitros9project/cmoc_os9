                    use       ../include/os9.d ; shared OS-9 service constants

__os9_sleep         EXPORT              ; export sleep wrapper

_osret              EXTERNAL            ; common successful return helper

                    section   code      ; begin code section

__os9_sleep
                    ldx       [2,s]     ; load current tick count from caller's pointer
                    os9       F_Sleep   ; sleep for the requested number of ticks
                    stx       [2,s]     ; write back remaining ticks if sleep was interrupted
                    lbra      _osret    ; return through common success path

                    endsect             ; end code section
