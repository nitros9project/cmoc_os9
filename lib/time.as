                    use       ../include/os9.d ; shared OS-9 service constants

__os_getime         EXPORT    ;         export OS-9 system-time read wrapper
__os_setime         EXPORT    ;         export OS-9 system-time write wrapper

_osret              EXTERNAL  ;         common error_code return helper

                    section   code      ; begin code section

__os_getime:
stk_os_getime_ret   equ       0         ; caller return address
stk_os_getime_time  equ       2         ; destination OS-9 time packet pointer
                    ldx       stk_os_getime_time,s ; pass caller's time packet to F$Time
                    os9       F_Time    ; fill packet with current OS-9 time values
                    lbra      _osret    ; return zero or OS-9 error code

__os_setime:
stk_os_setime_ret   equ       0         ; caller return address
stk_os_setime_time  equ       2         ; source OS-9 time packet pointer
                    ldx       stk_os_setime_time,s ; pass caller's time packet to F$STime
                    os9       F_STime   ; set OS-9 clock from the supplied packet
                    lbra      _osret    ; return zero or OS-9 error code

                    endsect   ;         end code section
