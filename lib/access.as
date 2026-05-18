* Compact assembly implementation of access-related syscalls.

                    use       ../include/os9.d ; shared OS-9 service constants
                    use       ../include/fcntl.d ; shared file-mode constants

                    section   code      ; begin code section

_access             EXPORT              ; export this symbol
_mknod              EXPORT              ; export this symbol
_unlinkx            EXPORT              ; export this symbol
_unlink             EXPORT              ; export this symbol
_dup                EXPORT              ; export this symbol

_sysret             EXTERNAL            ; import external symbol
_os9err             EXTERNAL            ; import external symbol

_access
stk_access_ret      equ       0         ; caller return address
stk_access_path     equ       2         ; pathname pointer
stk_access_mode     equ       4         ; 16-bit access-mode argument
                    ldx       stk_access_path,s ; pass pathname to I$Open
                    lda       stk_access_mode+1,s ; use the low byte of the mode argument
                    os9       I_Open    ; probe whether the path can be opened as requested
                    bcs       L_access_done ; leave the OS-9 error status for _sysret
                    os9       I_Close   ; close the probe path on success
L_access_done
                    lbra      _sysret   ; long branch unconditionally to _sysret

_mknod
stk_mknod_ret       equ       0         ; caller return address
stk_mknod_path      equ       2         ; pathname pointer
stk_mknod_mode      equ       4         ; 16-bit directory mode argument
                    ldx       stk_mknod_path,s ; pass pathname to I$MakDir
                    ldb       stk_mknod_mode+1,s ; use the low byte of the mode argument
                    os9       I_MakDir  ; invoke OS-9 make-directory call
                    lbra      _sysret   ; long branch unconditionally to _sysret

_unlinkx
stk_unlinkx_ret     equ       0         ; caller return address
stk_unlinkx_path    equ       2         ; pathname pointer
stk_unlinkx_mode    equ       4         ; 16-bit delete mode argument
                    lda       stk_unlinkx_mode+1,s ; use caller-supplied delete mode
                    ldx       stk_unlinkx_path,s ; pass pathname to I$DeletX
                    bra       L_unlink_do ; branch unconditionally to L_unlink_do

_unlink
stk_unlink_ret      equ       0         ; caller return address
stk_unlink_path     equ       2         ; pathname pointer
                    ldx       stk_unlink_path,s ; pass pathname to I$DeletX
                    lda       #FAM_WRITE ; delete regular files through write access
L_unlink_do
                    os9       I_DeletX  ; invoke OS-9 extended delete call
                    lbra      _sysret   ; long branch unconditionally to _sysret

_dup
stk_dup_ret         equ       0         ; caller return address
stk_dup_path        equ       2         ; 16-bit path-number argument
                    lda       stk_dup_path+1,s ; duplicate the low-byte OS-9 path number
                    os9       I_Dup     ; invoke OS-9 duplicate-path call
                    lbcs      _os9err   ; long branch if carry is set to _os9err
                    tfr       a,b       ; return the duplicated path as a C int
                    clra                ; clear the high byte of the C int result
                    rts                 ; return to caller

                    endsect             ; end current section
