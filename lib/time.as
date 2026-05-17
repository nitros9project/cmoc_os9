                    use       ../include/os9.d ; shared OS-9 service constants

__os_getime         EXPORT              ; export get-system-time wrapper
__os_setime         EXPORT              ; export set-system-time wrapper

_osret              EXTERNAL            ; common successful return helper

                    section   code      ; begin code section

__os_getime
                    ldx       2,s       ; load pointer to caller's time packet
                    os9       F_Time    ; fill packet with current OS-9 time values
                    lbra      _osret    ; return through common success path

__os_setime
                    ldx       2,s       ; load pointer to caller's time packet
                    os9       F_STime   ; set OS-9 clock from the supplied packet
                    lbra      _osret    ; return through common success path

                    endsect             ; end code section
