                    use       ../include/os9.d ; shared OS-9 service constants

__os_send           EXPORT    ;         export signal-send wrapper
__os_wait           EXPORT    ;         export wait wrapper
__os_setpr          EXPORT    ;         export set-priority wrapper
__os_chain          EXPORT    ;         export chain wrapper
__os_fork           EXPORT    ;         export fork wrapper

_oserr              EXTERNAL  ;         common OS-9 error-return helper
_osret              EXTERNAL  ;         common OS-9 success-return helper

                    section   code      ; begin code section

__os_send:
stk_os_send_ret     equ       0         ; caller return address
stk_os_send_pid     equ       2         ; target process id argument
stk_os_send_pid_byte equ       3         ; low byte passed to OS-9 in A
stk_os_send_signal  equ       4         ; signal number argument
stk_os_send_signal_byte equ       5         ; low byte passed to OS-9 in B
                    lda       stk_os_send_pid_byte,s ; pass target process id byte
                    ldb       stk_os_send_signal_byte,s ; pass signal number byte
                    os9       F_Send    ; deliver signal directly through OS-9
                    lbra      _osret    ; return 0 on success or errno on failure

__os_wait:
stk_os_wait_ret     equ       0         ; caller return address
stk_os_wait_statusp equ       2         ; optional caller status pointer
                    clra                ; clear high byte before wait call
                    clrb                ; clear low byte before wait call
                    os9       F_Wait    ; wait for any child process to terminate
                    lblo      _oserr    ; return errno-style error when no child or failure
                    ldx       stk_os_wait_statusp,s ; load caller's status pointer
                    beq       wait_return_pid ; skip status writeback when pointer is NULL
                    stb       1,x       ; store child exit status in low byte
                    clr       ,x        ; clear high byte of stored status word
wait_return_pid     tfr       a,b       ; move child pid byte into low byte of return value
                    clra                ; clear high byte of returned pid
                    rts                 ; return child pid in D

__os_setpr:
stk_os_setpr_ret    equ       0         ; caller return address
stk_os_setpr_pid    equ       2         ; target process id argument
stk_os_setpr_pid_byte equ       3         ; low byte passed to OS-9 in A
stk_os_setpr_priority equ       4         ; priority argument
stk_os_setpr_priority_byte equ       5         ; low byte passed to OS-9 in B
                    lda       stk_os_setpr_pid_byte,s ; pass target process id byte
                    ldb       stk_os_setpr_priority_byte,s ; pass requested priority byte
                    os9       F_SPrior  ; update process priority
                    lbra      _osret    ; return 0 on success or errno on failure

__os_chain:
stk_os_chain_ret    equ       0         ; caller return address
stk_os_chain_module equ       2         ; module name pointer
stk_os_chain_paramsize equ       4         ; parameter size in pages
stk_os_chain_paramaddr equ       6         ; parameter block address
stk_os_chain_lang_byte equ       9         ; low byte of language nibble argument
stk_os_chain_type_byte equ       11        ; low byte of type nibble argument
stk_os_chain_datasize_byte equ       13        ; low byte of data size in pages
                    leau      ,s        ; capture original argument frame in U
                    leas      255,y     ; move stack out of the way before chaining
                    ldx       stk_os_chain_module,u ; load module name pointer
                    ldy       stk_os_chain_paramsize,u ; load parameter size in pages
                    lda       stk_os_chain_lang_byte,u ; load language byte
                    ora       stk_os_chain_type_byte,u ; merge requested module type byte
                    ldb       stk_os_chain_datasize_byte,u ; load requested data size in pages
                    ldu       stk_os_chain_paramaddr,u ; load parameter address
                    os9       F_Chain   ; replace current process image with target module
                    os9       F_Exit    ; terminate if chain unexpectedly returns

__os_fork:
stk_os_fork_ret     equ       0         ; caller return address
stk_os_fork_module  equ       2         ; module name pointer
stk_os_fork_paramsize equ       4         ; parameter size in pages
stk_os_fork_paramaddr equ       6         ; parameter block address
stk_os_fork_lang_byte equ       9         ; low byte of language nibble argument
stk_os_fork_type_byte equ       11        ; low byte of type nibble argument
stk_os_fork_datasize_byte equ       13        ; low byte of data size in pages
stk_os_fork_pidp    equ       14        ; caller pointer receiving child process id
                    pshs      y,u       ; preserve caller's Y and U registers
                    ldx       stk_os_fork_module+4,s ; load module name pointer
                    ldy       stk_os_fork_paramsize+4,s ; load parameter size in pages
                    ldu       stk_os_fork_paramaddr+4,s ; load parameter address
                    lda       stk_os_fork_lang_byte+4,s ; load language byte
                    ora       stk_os_fork_type_byte+4,s ; merge requested module type byte
                    ldb       stk_os_fork_datasize_byte+4,s ; load requested data size in pages
                    os9       F_Fork    ; create child process
                    puls      y,u       ; restore caller's Y and U registers
                    lblo      _oserr    ; return errno-style error on fork failure
                    tfr       a,b       ; normalize returned child pid into D
                    clra                ; clear high byte of returned pid
                    std       [stk_os_fork_pidp,s] ; store child pid through caller's output pointer
                    lbra      _osret    ; return 0 on success or errno on failure

                    endsect   ;         end code section
