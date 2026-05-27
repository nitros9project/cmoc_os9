* Adapted from cmoc_os9/lib/todo/misc.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_lock               EXPORT    ;         export this symbol
_pause              EXPORT    ;         export this symbol
_sync               EXPORT    ;         export this symbol
_crc                EXPORT    ;         export this symbol
_prerr              EXPORT    ;         export this symbol
_tsleep             EXPORT    ;         export this symbol

_os9err             EXTERNAL  ;         import external symbol

_lock:
stk_lock_ret        equ       0         ; caller return address
                    rts                 ; return to caller

_pause:
stk_pause_ret       equ       0         ; caller return address
                    ldx       #0        ; sleep indefinitely until a signal wakes the process
                    clrb                ; no tick count pointer is supplied for pause
                    os9       F_Sleep   ; suspend the current process
                    lbra      _os9err   ; return OS-9 status through the error helper

_sync:
stk_sync_ret        equ       0         ; caller return address
                    rts                 ; return to caller

_crc:
stk_crc_saved_yu    equ       0         ; saved Y/U registers after pshs y,u
stk_crc_ret         equ       4         ; caller return address after pshs y,u
stk_crc_buffer      equ       6         ; buffer pointer
stk_crc_count       equ       8         ; byte count
stk_crc_accum       equ       10        ; CRC accumulator pointer/value argument
                    pshs      y,u       ; preserve registers used by OS-9 CRC call
                    ldx       stk_crc_buffer,s ; pass buffer pointer
                    ldy       stk_crc_count,s ; pass byte count
                    ldu       stk_crc_accum,s ; pass CRC accumulator
                    os9       F_CRC     ; update CRC over the caller buffer
                    puls      y,u,pc    ; restore registers and return

_prerr:
stk_prerr_ret       equ       0         ; caller return address
stk_prerr_path_byte equ       3         ; low byte of path number argument
stk_prerr_error_byte equ       5         ; low byte of error code argument
                    lda       stk_prerr_path_byte,s ; pass output path number
                    ldb       stk_prerr_error_byte,s ; pass error code to print
                    os9       F_PErr    ; ask OS-9 to print the error text
                    lblo      _os9err   ; return OS-9 failure through error helper
                    clra                ; return 0 on success (D held path:errcode)
                    clrb
                    rts                 ; return to caller

_tsleep:
stk_tsleep_ret      equ       0         ; caller return address
stk_tsleep_ticks    equ       2         ; pointer to tick count in/out parameter
                    ldx       stk_tsleep_ticks,s ; pass caller tick-count pointer
                    os9       F_Sleep   ; sleep for the requested number of ticks
                    lblo      _os9err   ; return OS-9 failure through error helper
                    tfr       x,d       ; return remaining ticks pointer/value from OS-9
                    rts                 ; return to caller

                    endsect   ;         end current section
