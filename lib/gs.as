* GetStat wrappers adapted for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_gs_size            EXPORT    ;         export this symbol
__gs_size           EXPORT    ;         export C ABI alias for _gs_size()
_gs_pos             EXPORT    ;         export this symbol
__gs_pos            EXPORT    ;         export C ABI alias for _gs_pos()
_gs_rdy             EXPORT    ;         export this symbol
__gs_rdy            EXPORT    ;         export C ABI alias for _gs_rdy()
_gs_eof             EXPORT    ;         export this symbol
__gs_eof            EXPORT    ;         export C ABI alias for _gs_eof()
_gs_opt             EXPORT    ;         export this symbol
__gs_opt            EXPORT    ;         export C ABI alias for _gs_opt()
_gs_devn            EXPORT    ;         export this symbol
__gs_devn           EXPORT    ;         export C ABI alias for _gs_devn()
_gs_gfd             EXPORT    ;         export this symbol
__gs_gfd            EXPORT    ;         export C ABI alias for _gs_gfd()

_errno              EXTERNAL  ;         import external symbol
_os9err             EXTERNAL  ;         import external symbol
_sysret             EXTERNAL  ;         import external symbol

__gs_size:
_gs_size:
stk_gs_size_ret     equ       0         ; caller return address
stk_gs_size_dest    equ       2         ; hidden long-return destination pointer
stk_gs_size_path    equ       4         ; OS-9 path number argument
                    ldb       #SS_Size  ; request current file size
                    bra       L_gs_long ; handle the common 32-bit GetStat result

__gs_pos:
_gs_pos:
stk_gs_pos_ret      equ       0         ; caller return address
stk_gs_pos_dest     equ       2         ; hidden long-return destination pointer
stk_gs_pos_path     equ       4         ; OS-9 path number argument
                    ldb       #SS_Pos   ; request current file position
L_gs_long           pshs      u         ; preserve U, which receives the low word from I$GetStt
                    lda       stk_gs_size_path+3,s ; load path byte after saved U shifts the caller frame
                    os9       I_GetStt  ; query size or position as a 32-bit X:U value
                    bcc       L_gs_long_store ; keep returned X:U when GetStat succeeded
                    ldx       #-1       ; synthesize -1L high word on error
                    tfr       x,u       ; synthesize -1L low word on error
                    clra                ; convert OS-9 error byte to int errno
                    std       _errno,y  ; store failure code in errno
L_gs_long_store     tfr       x,d       ; copy high word before loading the destination pointer
                    ldx       stk_gs_size_dest+2,s ; load hidden long-return destination after saved U
                    std       ,x        ; store high word of long result
                    stu       2,x       ; store low word of long result
                    puls      u,pc      ; restore U and return

__gs_rdy:
_gs_rdy:
stk_gs_rdy_ret      equ       0         ; caller return address
stk_gs_rdy_path     equ       2         ; OS-9 path number argument
                    ldb       #SS_Ready ; request readiness status
                    lda       stk_gs_rdy_path+1,s ; load path byte for I$GetStt
                    os9       I_GetStt  ; query bytes ready on the path
                    lblo      _os9err   ; convert OS-9 carry/error to -1 and errno
                    clra                ; return ready byte as an int
                    rts                 ; return readiness count

__gs_eof:
_gs_eof:
stk_gs_eof_ret      equ       0         ; caller return address
stk_gs_eof_path     equ       2         ; OS-9 path number argument
                    ldb       #SS_EOF   ; request end-of-file status
                    lda       stk_gs_eof_path+1,s ; load path byte for I$GetStt
                    os9       I_GetStt  ; query EOF status
                    bra       L_gs_sysret ; normalize success or failure through _sysret

__gs_opt:
_gs_opt:
stk_gs_opt_ret      equ       0         ; caller return address
stk_gs_opt_path     equ       2         ; OS-9 path number argument
stk_gs_opt_buffer   equ       4         ; destination options packet
                    ldb       #SS_Opt   ; request path options packet
                    ldx       stk_gs_opt_buffer,s ; load destination options buffer
                    lda       stk_gs_opt_path+1,s ; load path byte for I$GetStt
                    os9       I_GetStt  ; query options status
                    bra       L_gs_sysret ; normalize success or failure through _sysret

__gs_devn:
_gs_devn:
stk_gs_devn_ret     equ       0         ; caller return address
stk_gs_devn_path    equ       2         ; OS-9 path number argument
stk_gs_devn_buffer  equ       4         ; destination device-name buffer
                    ldb       #SS_DevNm ; request device name string
                    ldx       stk_gs_devn_buffer,s ; load destination device-name buffer
                    lda       stk_gs_devn_path+1,s ; load path byte for I$GetStt
                    os9       I_GetStt  ; ask OS-9 to copy the device name
                    bcs       L_gs_sysret ; let _sysret convert errors to errno
L_gs_devn_scan      lda       ,x+       ; scan for OS-9 high-bit terminator
                    bpl       L_gs_devn_scan ; keep scanning until the final character is marked
                    anda      #$7f      ; clear terminator bit on the last character
                    sta       -1,x      ; replace marked final character with plain ASCII
                    clr       ,x        ; append C NUL terminator
                    clra                ; return zero on success
                    clrb                ; return zero on success
                    rts                 ; return success

__gs_gfd:
_gs_gfd:
stk_gs_gfd_ret      equ       0         ; caller return address
stk_gs_gfd_path     equ       2         ; OS-9 path number argument
stk_gs_gfd_buffer   equ       4         ; destination file-descriptor buffer
stk_gs_gfd_count    equ       6         ; byte count to request
                    pshs      y         ; preserve CMOC data pointer while OS-9 uses Y as byte count
                    ldb       #SS_FD    ; request file descriptor sector block
                    lda       stk_gs_gfd_path+3,s ; load path byte after saved Y shifts the caller frame
                    ldx       stk_gs_gfd_buffer+2,s ; load destination buffer after saved Y
                    ldy       stk_gs_gfd_count+2,s ; load requested byte count after saved Y
                    os9       I_GetStt  ; read file descriptor bytes
                    puls      y         ; restore CMOC data pointer
L_gs_sysret         lbra      _sysret   ; return 0 on success or errno on failure

                    endsect   ;         end current section
