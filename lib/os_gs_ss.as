* Modern _os_gs_* and _os_ss_* wrappers over OS-9 GetStat/SetStat.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

__os_gs_size        EXPORT    ;         export modern size wrapper
__os_gs_pos         EXPORT    ;         export modern position wrapper
__os_gs_ready       EXPORT    ;         export modern ready wrapper
__os_gs_eof         EXPORT    ;         export modern eof wrapper
__os_gs_popt        EXPORT    ;         export modern path-options getter
__os_gs_devnm       EXPORT    ;         export modern device-name getter
__os_gs_fd          EXPORT    ;         export modern file-descriptor getter
__os_gs_scsiz       EXPORT    ;         export modern screen-size getter
__os_ss_popt        EXPORT    ;         export modern path-options setter
__os_ss_pfd         EXPORT    ;         export modern file-descriptor setter
__os_ss_sendsig     EXPORT    ;         export modern send-signal setter
__os_ss_ticks       EXPORT    ;         export modern ticks setter
__os_ss_reset       EXPORT    ;         export modern reset setter
__os_ss_relea       EXPORT    ;         export modern release setter

_osret              EXTERNAL  ;         import modern status return helper

__os_gs_size:
stk_os_gs_size_ret  equ       0         ; caller return address
stk_os_gs_size_path equ       2         ; path descriptor argument
stk_os_gs_size_value equ       4         ; destination long pointer
                    ldb       #SS_Size  ; request 32-bit object size
                    bra       GSLong_01 ; share size/position helper

__os_gs_pos:
stk_os_gs_pos_ret   equ       0         ; caller return address
stk_os_gs_pos_path  equ       2         ; path descriptor argument
stk_os_gs_pos_value equ       4         ; destination long pointer
                    ldb       #SS_Pos   ; request 32-bit file position
GSLong_01
stk_gslong_ret      equ       0         ; caller return address for shared long GetStat wrappers
stk_gslong_path     equ       2         ; path descriptor argument
stk_gslong_path_byte equ       3         ; low byte passed to OS-9 in A
stk_gslong_value    equ       4         ; destination long pointer
                    pshs      y,u       ; preserve Y,U across the system call
                    lda       stk_gslong_path_byte+4,s ; pass path descriptor in A
                    os9       I_GetStt  ; request the selected 32-bit status value
                    bcs       GSLong_02 ; skip stores when OS-9 reports an error
                    ldy       stk_gslong_value+4,s ; load destination long pointer
                    stx       ,y        ; store high word of X:U result
                    stu       2,y       ; store low word of X:U result
GSLong_02           puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return error_code status

__os_gs_ready:
stk_os_gs_ready_ret equ       0         ; caller return address
stk_os_gs_ready_path equ       2         ; path descriptor argument
stk_os_gs_ready_path_byte equ       3         ; low byte passed to OS-9 in A
stk_os_gs_ready_value equ       4         ; destination int pointer
                    pshs      y         ; preserve Y across the system call
                    ldb       #SS_Ready ; request ready status
                    lda       stk_os_gs_ready_path_byte+2,s ; pass path descriptor in A
                    os9       I_GetStt  ; query ready count/status into B
                    bcs       GSWord_02 ; skip output store on OS-9 error
                    ldy       stk_os_gs_ready_value+2,s ; load destination int pointer
                    clra                ; widen B into a 16-bit C int result
                    std       ,y        ; store returned ready status/count
GSWord_02           puls      y         ; restore preserved register
                    lbra      _osret    ; return error_code status

__os_gs_eof:
stk_os_gs_eof_ret   equ       0         ; caller return address
stk_os_gs_eof_path  equ       2         ; path descriptor argument
stk_os_gs_eof_path_byte equ       3         ; low byte passed to OS-9 in A
stk_os_gs_eof_value equ       4         ; destination int pointer
                    pshs      y         ; preserve Y across the system call
                    ldb       #SS_EOF   ; request end-of-file status
                    lda       stk_os_gs_eof_path_byte+2,s ; pass path descriptor in A
                    os9       I_GetStt  ; ask OS-9 whether the path is at EOF
                    ldy       stk_os_gs_eof_value+2,s ; load destination int pointer
                    bcs       GSEof_01  ; EOF is reported through the carry/error path
                    clra                ; non-EOF becomes a zero C int result
                    clrb                ; non-EOF becomes a zero C int result
                    std       ,y        ; store EOF state for the caller
                    puls      y         ; restore preserved register
                    lbra      _osret    ; return error_code status
GSEof_01            cmpb      #E_EOF    ; treat OS-9 EOF as a successful state query
                    bne       GSWord_02 ; preserve other errors as true failures
                    ldd       #-1       ; report EOF through the output value
                    std       ,y        ; store EOF state for the caller
                    andcc     #$fe      ; clear carry so _osret reports success
                    puls      y         ; restore preserved register
                    lbra      _osret    ; return error_code status

__os_gs_popt:
stk_os_gs_popt_ret  equ       0         ; caller return address
stk_os_gs_popt_path equ       2         ; path descriptor argument
stk_os_gs_popt_opts equ       4         ; destination options buffer
                    ldb       #SS_Opt   ; request path options packet
                    bra       GSBuf_01  ; share single-buffer GetStat helper

__os_gs_devnm:
stk_os_gs_devnm_ret equ       0         ; caller return address
stk_os_gs_devnm_path equ       2         ; path descriptor argument
stk_os_gs_devnm_path_byte equ       3         ; low byte passed to OS-9 in A
stk_os_gs_devnm_name equ       4         ; destination device-name buffer
                    ldb       #SS_DevNm ; request device name string
                    ldx       stk_os_gs_devnm_name,s ; load destination buffer pointer
                    lda       stk_os_gs_devnm_path_byte,s ; pass path descriptor in A
                    os9       I_GetStt  ; read high-bit-terminated device name
                    bcs       GSDev_02  ; return without touching buffer on error
GSDev_01            lda       ,x+       ; scan returned name until high-bit terminator
                    bpl       GSDev_01  ; continue until terminator byte is found
                    anda      #$7f      ; strip the high-bit terminator marker
                    sta       -1,x      ; write back the final character
                    clr       ,x        ; append C string terminator
GSDev_02            lbra      _osret    ; return error_code status

__os_gs_fd:
stk_os_gs_fd_ret    equ       0         ; caller return address
stk_os_gs_fd_path   equ       2         ; path descriptor argument
stk_os_gs_fd_path_byte equ       3         ; low byte passed to OS-9 in A
stk_os_gs_fd_buffer equ       4         ; destination descriptor buffer
stk_os_gs_fd_count  equ       6         ; count pointer for descriptor bytes
                    pshs      y         ; preserve Y across the system call
                    ldb       #SS_FD    ; request file descriptor sector block
                    lda       stk_os_gs_fd_path_byte+2,s ; pass path descriptor in A
                    ldx       stk_os_gs_fd_buffer+2,s ; load descriptor buffer pointer
                    ldy       stk_os_gs_fd_count+2,s ; load byte-count pointer
                    os9       I_GetStt  ; read descriptor bytes into caller buffer
                    puls      y         ; restore preserved register
                    lbra      _osret    ; return error_code status

__os_gs_scsiz:
stk_os_gs_scsiz_ret equ       0         ; caller return address
stk_os_gs_scsiz_path equ       2         ; path descriptor argument
stk_os_gs_scsiz_path_byte equ       3         ; low byte passed to OS-9 in A
stk_os_gs_scsiz_width equ       4         ; destination width pointer
stk_os_gs_scsiz_height equ       6         ; destination height pointer
                    pshs      y         ; preserve Y across the system call
                    ldb       #SS_ScSiz ; request screen dimensions
                    lda       stk_os_gs_scsiz_path_byte+2,s ; pass path descriptor in A
                    os9       I_GetStt  ; returns width in X and height in Y
                    bcs       GSScSiz_01 ; skip stores when OS-9 reports an error
                    stx       [stk_os_gs_scsiz_width+2,s] ; store returned screen width
                    sty       [stk_os_gs_scsiz_height+2,s] ; store returned screen height
GSScSiz_01          puls      y         ; restore preserved register
                    lbra      _osret    ; return error_code status

GSBuf_01
stk_gsbuf_ret       equ       0         ; caller return address for shared buffer GetStat wrappers
stk_gsbuf_path      equ       2         ; path descriptor argument
stk_gsbuf_path_byte equ       3         ; low byte passed to OS-9 in A
stk_gsbuf_buffer    equ       4         ; destination buffer pointer
                    ldx       stk_gsbuf_buffer,s ; load destination buffer pointer
                    lda       stk_gsbuf_path_byte,s ; pass path descriptor in A
                    os9       I_GetStt  ; read selected status packet into buffer
                    lbra      _osret    ; return error_code status

__os_ss_popt:
stk_os_ss_popt_ret  equ       0         ; caller return address
stk_os_ss_popt_path equ       2         ; path descriptor argument
stk_os_ss_popt_opts equ       4         ; source options buffer
                    ldb       #SS_Opt   ; write path options packet
                    bra       SSBuf_01  ; share single-buffer SetStat helper

__os_ss_pfd:
stk_os_ss_pfd_ret   equ       0         ; caller return address
stk_os_ss_pfd_path  equ       2         ; path descriptor argument
stk_os_ss_pfd_buffer equ       4         ; source descriptor buffer
                    ldb       #SS_FD    ; write file descriptor sector block
                    bra       SSBuf_01  ; share single-buffer SetStat helper

__os_ss_sendsig:
stk_os_ss_sendsig_ret equ       0         ; caller return address
stk_os_ss_sendsig_path equ       2         ; path descriptor argument
stk_os_ss_sendsig_signo equ       4         ; signal selector value
                    ldb       #SS_SSig  ; configure signal-on-status
                    bra       SSBuf_01  ; pass integer value in X like legacy helper

__os_ss_ticks:
stk_os_ss_ticks_ret equ       0         ; caller return address
stk_os_ss_ticks_path equ       2         ; path descriptor argument
stk_os_ss_ticks_block equ       4         ; source tick parameter block
                    ldb       #SS_Ticks ; write tick-related parameter block
SSBuf_01
stk_ssbuf_ret       equ       0         ; caller return address for shared buffer SetStat wrappers
stk_ssbuf_path      equ       2         ; path descriptor argument
stk_ssbuf_path_byte equ       3         ; low byte passed to OS-9 in A
stk_ssbuf_value     equ       4         ; source pointer or integer value
                    ldx       stk_ssbuf_value,s ; load source pointer/value argument
                    lda       stk_ssbuf_path_byte,s ; pass path descriptor in A
                    os9       I_SetStt  ; write selected status packet/value
                    lbra      _osret    ; return error_code status

__os_ss_reset:
stk_os_ss_reset_ret equ       0         ; caller return address
stk_os_ss_reset_path equ       2         ; path descriptor argument
                    ldb       #SS_Reset ; request device reset
                    bra       SSBare_01 ; share no-argument SetStat helper

__os_ss_relea:
stk_os_ss_relea_ret equ       0         ; caller return address
stk_os_ss_relea_path equ       2         ; path descriptor argument
                    ldb       #SS_Relea ; request resource release
SSBare_01
stk_ssbare_ret      equ       0         ; caller return address for bare SetStat wrappers
stk_ssbare_path     equ       2         ; path descriptor argument
stk_ssbare_path_byte equ       3         ; low byte passed to OS-9 in A
                    lda       stk_ssbare_path_byte,s ; pass path descriptor in A
                    os9       I_SetStt  ; issue selected no-argument SetStat call
                    lbra      _osret    ; return error_code status

                    endsect   ;         end current section
