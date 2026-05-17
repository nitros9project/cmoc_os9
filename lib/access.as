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
                    ldx       2,s       ; load X from stack-relative value 2,s
                    lda       5,s       ; load A from stack-relative value 5,s
                    os9       I_Open    ; invoke OS-9 open call
                    bcs       L_access_done ; branch if carry is set to L_access_done
                    os9       I_Close   ; close the probe path on success
L_access_done
                    lbra      _sysret   ; long branch unconditionally to _sysret

_mknod
                    ldx       2,s       ; load X from stack-relative value 2,s
                    ldb       5,s       ; load B from stack-relative value 5,s
                    os9       I_MakDir  ; invoke OS-9 make-directory call
                    lbra      _sysret   ; long branch unconditionally to _sysret

_unlinkx
                    lda       5,s       ; load A from stack-relative value 5,s
                    ldx       2,s       ; load X from stack-relative value 2,s
                    bra       L_unlink_do ; branch unconditionally to L_unlink_do

_unlink
                    ldx       2,s       ; load X from stack-relative value 2,s
                    lda       #FAM_WRITE ; load A from immediate value FAM_WRITE
L_unlink_do
                    os9       I_DeletX  ; invoke OS-9 extended delete call
                    lbra      _sysret   ; long branch unconditionally to _sysret

_dup
                    lda       3,s       ; load A from stack-relative value 3,s
                    os9       I_Dup     ; invoke OS-9 duplicate-path call
                    lbcs      _os9err   ; long branch if carry is set to _os9err
                    tfr       a,b       ; transfer A,B
                    clra                ; clear A
                    rts                 ; return to caller

                    endsect             ; end current section
