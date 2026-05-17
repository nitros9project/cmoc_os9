                    use       ../include/os9.d ; shared OS-9 service constants

__os_send           EXPORT              ; export signal-send wrapper
__os_wait           EXPORT              ; export wait wrapper
__os_setpr          EXPORT              ; export set-priority wrapper
__os_chain          EXPORT              ; export chain wrapper
__os_fork           EXPORT              ; export fork wrapper

_oserr              EXTERNAL            ; common OS-9 error-return helper
_osret              EXTERNAL            ; common OS-9 success-return helper

                    section   code      ; begin code section

__os_send
                    lda       3,s       ; load target process id byte
                    ldb       5,s       ; load signal number byte
                    os9       F_Send    ; deliver signal directly through OS-9
                    lbra      _osret    ; return 0 on success or errno on failure

__os_wait
                    clra                ; clear high byte before wait call
                    clrb                ; clear low byte before wait call
                    os9       F_Wait    ; wait for any child process to terminate
                    lblo      _oserr    ; return errno-style error when no child or failure
                    ldx       2,s       ; load caller's status pointer
                    beq       L001b     ; skip status writeback when pointer is NULL
                    stb       1,x       ; store child exit status in low byte
                    clr       ,x        ; clear high byte of stored status word
L001b               tfr       a,b       ; move child pid byte into low byte of return value
                    clra                ; clear high byte of returned pid
                    rts                 ; return child pid in D

__os_setpr
                    lda       3,s       ; load process id byte
                    ldb       5,s       ; load requested priority byte
                    os9       F_SPrior  ; update process priority
                    lbra      _osret    ; return 0 on success or errno on failure

__os_chain
                    leau      ,s        ; capture original argument frame in U
                    leas      255,y     ; move stack out of the way before chaining
                    ldx       2,u       ; load module name pointer
                    ldy       4,u       ; load parameter size in pages
                    lda       9,u       ; load language byte
                    ora       11,u      ; merge requested module type byte
                    ldb       13,u      ; load requested data size in pages
                    ldu       6,u       ; load parameter address
                    os9       F_Chain   ; replace current process image with target module
                    os9       F_Exit    ; terminate if chain unexpectedly returns

__os_fork
                    pshs      y,u       ; preserve caller's Y and U registers
                    ldx       6,s       ; load module name pointer
                    ldy       8,s       ; load parameter size in pages
                    ldu       10,s      ; load parameter address
                    lda       13,s      ; load language byte
                    ora       15,s      ; merge requested module type byte
                    ldb       17,s      ; load requested data size in pages
                    os9       F_Fork    ; create child process
                    puls      y,u       ; restore caller's Y and U registers
                    lblo      _oserr    ; return errno-style error on fork failure
                    tfr       a,b       ; normalize returned child pid into D
                    clra                ; clear high byte of returned pid
                    std       [14,s]    ; store child pid through caller's output pointer
                    lbra      _osret    ; return 0 on success or errno on failure

                    endsect             ; end code section
