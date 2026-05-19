* Adapted from cmoc_os9/lib/todo/devtyp.as

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_devtyp             EXPORT    ;         export this symbol
_isatty             EXPORT    ;         export this symbol

_os9err             EXTERNAL  ;         import external symbol

_isatty:
stk_isatty_ret      equ       0         ; caller return address
stk_isatty_fd       equ       2         ; path number argument
                    ldd       stk_isatty_fd,s ; copy path number for _devtyp call
                    pshs      d         ; pass path number on the stack
                    bsr       _devtyp   ; query OS-9 path options for device type
                    std       ,s++      ; discard argument while keeping _devtyp status in D/flags
                    beq       tty_yes   ; device type zero is treated as terminal-like
                    clrb                ; return false for nonzero device type
                    rts                 ; return to caller
tty_yes
                    incb                ; return true for terminal-like device
                    rts                 ; return to caller

_devtyp:
stk_devtyp_ret      equ       0         ; caller return address
stk_devtyp_fd       equ       2         ; path number argument
stk_devtyp_optsize  equ       32        ; path options packet size used here
stk_devtyp_optbuf   equ       0         ; temporary options buffer after allocation
                    lda       stk_devtyp_fd+1,s ; load path number low byte
                    clrb                ; request SS_Opt path options
                    leas      -stk_devtyp_optsize,s ; reserve path options buffer
                    leax      stk_devtyp_optbuf,s ; point X at options buffer
                    os9       I_GetStt  ; read path options into local buffer
                    lda       stk_devtyp_optbuf,s ; fetch device type byte from options packet
                    leas      stk_devtyp_optsize,s ; release path options buffer
                    lblo      _os9err   ; convert GetStat failure to errno return
                    tfr       a,b       ; return device type in low byte
                    clra                ; clear high byte of int return
                    rts                 ; return to caller

                    endsect   ;         end current section
