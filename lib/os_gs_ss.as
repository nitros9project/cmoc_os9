* Modern _os_gs_* and _os_ss_* wrappers over OS-9 GetStat/SetStat.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

__os_gs_size        EXPORT              ; export modern size wrapper
__os_gs_pos         EXPORT              ; export modern position wrapper
__os_gs_ready       EXPORT              ; export modern ready wrapper
__os_gs_eof         EXPORT              ; export modern eof wrapper
__os_gs_popt        EXPORT              ; export modern path-options getter
__os_gs_devnm       EXPORT              ; export modern device-name getter
__os_gs_fd          EXPORT              ; export modern file-descriptor getter
__os_ss_popt        EXPORT              ; export modern path-options setter
__os_ss_pfd         EXPORT              ; export modern file-descriptor setter
__os_ss_sendsig     EXPORT              ; export modern send-signal setter
__os_ss_ticks       EXPORT              ; export modern ticks setter
__os_ss_reset       EXPORT              ; export modern reset setter
__os_ss_relea       EXPORT              ; export modern release setter

_osret              EXTERNAL            ; import modern status return helper

__os_gs_size
                    ldb       #SS_Size  ; request 32-bit object size
                    bra       GSLong_01 ; share size/position helper

__os_gs_pos
                    ldb       #SS_Pos   ; request 32-bit file position
GSLong_01           pshs      y,u       ; preserve Y,U across the system call
                    lda       7,s       ; load path number argument
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    bcs       GSLong_02 ; branch to shared return on error
                    ldy       8,s       ; load destination pointer
                    stx       ,y        ; store high word of result
                    stu       2,y       ; store low word of result
GSLong_02           puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return error_code status

__os_gs_ready
                    pshs      y         ; preserve Y across the system call
                    ldb       #SS_Ready ; request ready status
                    lda       5,s       ; load path number argument
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    bcs       GSWord_02 ; branch to shared return on error
                    ldy       6,s       ; load destination pointer
                    clra                ; widen B into a 16-bit C int result
                    std       ,y        ; store returned ready status/count
GSWord_02           puls      y         ; restore preserved register
                    lbra      _osret    ; return error_code status

__os_gs_eof
                    pshs      y         ; preserve Y across the system call
                    ldb       #SS_EOF   ; request end-of-file status
                    lda       5,s       ; load path number argument
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    ldy       6,s       ; load destination pointer
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

__os_gs_popt
                    ldb       #SS_Opt   ; request path options packet
                    bra       GSBuf_01  ; share single-buffer GetStat helper

__os_gs_devnm
                    ldb       #SS_DevNm ; request device name string
                    ldx       4,s       ; load destination buffer pointer
                    lda       3,s       ; load path number argument
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    bcs       GSDev_02  ; branch to shared return on error
GSDev_01            lda       ,x+       ; scan returned name until high-bit terminator
                    bpl       GSDev_01  ; continue until terminator byte is found
                    anda      #$7f      ; strip the high-bit terminator marker
                    sta       -1,x      ; write back the final character
                    clr       ,x        ; append C string terminator
GSDev_02            lbra      _osret    ; return error_code status

__os_gs_fd
                    pshs      y         ; preserve Y across the system call
                    ldb       #SS_FD    ; request file descriptor sector block
                    lda       5,s       ; load path number argument
                    ldx       6,s       ; load descriptor buffer pointer
                    ldy       8,s       ; load byte-count pointer
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    puls      y         ; restore preserved register
                    lbra      _osret    ; return error_code status

GSBuf_01            ldx       4,s       ; load destination buffer pointer
                    lda       3,s       ; load path number argument
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    lbra      _osret    ; return error_code status

__os_ss_popt
                    ldb       #SS_Opt   ; write path options packet
                    bra       SSBuf_01  ; share single-buffer SetStat helper

__os_ss_pfd
                    ldb       #SS_FD    ; write file descriptor sector block
                    bra       SSBuf_01  ; share single-buffer SetStat helper

__os_ss_sendsig
                    ldb       #SS_SSig  ; configure signal-on-status
                    bra       SSBuf_01  ; pass integer value in X like legacy helper

__os_ss_ticks
                    ldb       #SS_Ticks ; write tick-related parameter block
SSBuf_01            ldx       4,s       ; load source pointer/value argument
                    lda       3,s       ; load path number argument
                    os9       I_SetStt  ; invoke OS-9 system call I_SetStt
                    lbra      _osret    ; return error_code status

__os_ss_reset
                    ldb       #SS_Reset ; request device reset
                    bra       SSBare_01 ; share no-argument SetStat helper

__os_ss_relea
                    ldb       #SS_Relea ; request resource release
SSBare_01           lda       3,s       ; load path number argument
                    os9       I_SetStt  ; invoke OS-9 system call I_SetStt
                    lbra      _osret    ; return error_code status

                    endsect             ; end current section
