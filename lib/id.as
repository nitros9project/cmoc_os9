* Live cmoc_os9 ABI assembly implementation of OS-9 ID wrappers.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

__os_getpid         EXPORT    ;         export this symbol
__os_getuid         EXPORT    ;         export this symbol
__os_asetuid        EXPORT    ;         export this symbol
__os_setuid         EXPORT    ;         export this symbol

_getpid             EXTERNAL  ;         import external symbol
_oserr              EXTERNAL  ;         import external symbol
_osret              EXTERNAL  ;         import external symbol

__os_getpid:
stk_os_getpid_saved_y equ       0         ; saved CMOC data-area register after pshs y
stk_os_getpid_ret   equ       2         ; caller return address after pshs y
stk_os_getpid_result equ       4         ; optional caller pointer for returned process ID
                    pshs      y         ; preserve caller's data-area register
                    lbsr      _getpid   ; fetch the process ID through the C helper
                    ldx       stk_os_getpid_result,s ; get optional output pointer
                    beq       os_getpid_done ; skip store when caller passed NULL
                    std       ,x        ; store process ID through caller output pointer
os_getpid_done      clra                ; return C success code 0
                    clrb                ; complete 16-bit zero return value
                    puls      y,pc      ; restore registers and return

__os_getuid:
stk_os_getuid_ret   equ       0         ; caller return address after Y is restored
stk_os_getuid_result equ       2         ; optional caller pointer for returned user ID
                    pshs      y         ; preserve caller's data-area register
                    os9       F_ID      ; ask OS-9 for the current process identity
                    tfr       y,d       ; move returned user ID from Y into D
                    puls      y         ; restore caller's data-area register before C return
                    lbcs      _oserr    ; return OS-9 error if F_ID failed
                    ldx       stk_os_getuid_result,s ; get optional output pointer
                    beq       os_getuid_done ; skip store when caller passed NULL
                    std       ,x        ; store user ID through caller output pointer
os_getuid_done      lbra      _osret    ; return success through shared helper

__os_asetuid:
stk_os_asetuid_saved_y equ       0         ; saved CMOC data-area register after pshs y
stk_os_asetuid_ret  equ       2         ; caller return address after pshs y
stk_os_asetuid_uid  equ       4         ; requested user ID parameter
                    pshs      y         ; preserve caller's data-area register
                    bra       os_setuid_call ; share the OS-9 set-user call path

__os_setuid:
stk_os_setuid_saved_y equ       0         ; saved CMOC data-area register after pshs y
stk_os_setuid_ret   equ       2         ; caller return address after pshs y
stk_os_setuid_uid   equ       4         ; requested user ID parameter
                    pshs      y         ; preserve caller's data-area register
                    os9       F_ID      ; read current user ID before deciding privilege
                    tfr       y,d       ; copy current user ID into D for zero check
                    std       -2,s      ; legacy scratch write only to set condition codes
                    beq       os_setuid_call ; root user may attempt the set-user call
                    ldb       #E_FNA    ; non-root callers report file-not-accessible
os_setuid_error     puls      y         ; restore caller's data-area register
                    lbra      _oserr    ; return B as the OS-9 error code
os_setuid_call      ldy       stk_os_setuid_uid,s ; load requested user ID
                    os9       F_SUser   ; ask OS-9 to change the process user ID
                    bcs       os_setuid_error ; return any F_SUser error unchanged
os_setuid_done      puls      y         ; restore caller's data-area register
                    lbra      _osret    ; return success through shared helper

                    endsect   ;         end current section
