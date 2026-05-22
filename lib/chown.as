*
* Adapted from cmoc_os9/lib/todo/chown.as for the live CMOC ABI.
*

                    use       ../include/os9.d ; shared OS-9 service constants
                    use       ../include/fcntl.d ; shared file-mode constants

                    section   code      ; begin code section

_chown              EXPORT    ;         export this symbol

_sysret             EXTERNAL  ;         import external symbol

Bufsize             equ       16        ; file descriptor sector bytes copied locally

_chown:
stk_chown_ret       equ       0         ; caller return address at entry
stk_chown_path      equ       2         ; pathname pointer argument
stk_chown_owner     equ       4         ; new owner ID argument
stk_chown_buf       equ       0         ; 16-byte file descriptor buffer after allocation
stk_chown_saved     equ       Bufsize   ; saved Y/U pair above local buffer
                    pshs      y,u       ; preserve caller frame registers
                    leas      -Bufsize,s ; reserve local descriptor-sector buffer
                    os9       F_ID      ; fetch caller identity for ownership check
                    bcs       chxit     ; return F$ID error through _sysret
                    ldb       #E_FNA    ; deny non-owner ownership changes
                    cmpy      #0        ; only superuser may change file ownership
                    orcc      #1        ; pre-set carry so nonzero ID becomes E_FNA
                    bne       chxit     ; reject non-superuser ownership change
                    bsr       openfile  ; open path and load descriptor sector into local buffer
                    bcs       chxit     ; return OS-9 error if open or descriptor read failed
                    pshs      a         ; save path number while owner field is updated
                    ldd       stk_chown_owner+Bufsize+4+1,s ; saved A shifts owner argument by 1 byte
                    std       1,x       ; replace descriptor owner field
                    puls      a         ; restore path number for SetStat/Close
                    ldb       #SS_FD    ; request descriptor-sector SetStat
                    os9       I_SetStt  ; write back descriptor sector changes
                    bcs       chxit     ; preserve SetStat error for _sysret
                    os9       I_Close   ; close temporary path
chxit               leas      Bufsize,s ; release local descriptor buffer
                    puls      y,u       ; restore caller frame registers
                    lbra      _sysret   ; translate OS-9 carry/B result to C return value

openfile
                    lda       #FAM_WRITE ; open with write access so descriptor changes are allowed
                    ldx       stk_chown_path+Bufsize+4+2,s ; BSR return shifts original path argument by 2 bytes
                    os9       I_Open    ; open target for descriptor access
                    bcc       openf10   ; read descriptor only after open succeeds
                    rts                 ; return to caller

openf10             leax      stk_chown_buf+2,s ; point X at local descriptor buffer past BSR return address
                    ldy       #Bufsize  ; read exactly one descriptor buffer
                    ldb       #SS_FD    ; request descriptor-sector GetStat
                    os9       I_GetStt  ; load descriptor sector into local buffer
                    rts                 ; return to caller

                    endsect   ;         end current section
