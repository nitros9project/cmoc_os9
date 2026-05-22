                    use       ../include/os9.d ; shared OS-9 service constants
                    use       ../include/fcntl.d ; shared file-mode constants

__os_ss_attr        EXPORT              ; export file-attribute SetStat helper

_osret              EXTERNAL            ; common successful return helper

                    section   code      ; begin code section

__os_ss_attr
stk_attr_ret        equ       0         ; caller return address
stk_attr_path       equ       2         ; pathname pointer
stk_attr_perm       equ       4         ; 16-bit permission value
                    pshs      y,u       ; preserve registers across helper calls
                    leas      -16,s     ; reserve temporary file descriptor buffer
                    lda       #S_IWRITE ; first try opening as a regular writable file
                    bsr       openfile  ; open the path and fetch its descriptor sector
                    bcc       openok    ; continue if the open/GetStat sequence succeeded
                    lda       #S_DIR|S_IWRITE ; retry as a writable directory path
                    bsr       openfile  ; attempt directory open/GetStat sequence
                    bcs       goexit    ; give up if both open attempts failed
openok
                    pshs      a,y       ; save open path id and returned owner/group info
                    os9       F_ID      ; fetch current process user id for permission check
                    cmpy      #0        ; user 0 bypasses owner check
                    beq       userok    ; superuser may update attributes directly
                    ldb       #E_FNA    ; preload permission-denied style error code
                    cmpy      1,x       ; compare process user id against file owner id
                    orcc      #1        ; force carry set for mismatch/error return
                    bne       goexit    ; reject attribute change for non-owner
userok              ldb       stk_attr_perm+24,s ; load requested permission byte through the saved path/owner frame
                    stb       ,x        ; patch attribute field in descriptor buffer
                    puls      a,y       ; restore path id and saved Y value
                    ldb       #SS_FD    ; request descriptor-sector update
                    os9       I_SetStt  ; write the modified descriptor back to disk
                    bcs       goexit    ; return error if SetStat failed
                    os9       I_Close   ; close the temporary path descriptor
goexit
                    leas      16,s      ; discard temporary file descriptor buffer
                    puls      y,u       ; restore caller's registers
                    lbra      _osret    ; return through common status helper

openfile
stk_openfile_ret    equ       0         ; return address from bsr
stk_openfile_fdbuf  equ       2         ; caller's 16-byte descriptor buffer
stk_openfile_path   equ       24        ; pathname pointer in the caller frame
                    ldx       stk_openfile_path,s ; load pathname pointer argument
                    os9       I_Open    ; open the path using mode in A
                    bcc       getfd     ; fetch descriptor contents on success
                    rts                 ; return with OS-9 carry/error status intact

getfd
                    leax      2,s       ; point X at local descriptor-sector buffer
                    ldy       #16       ; request the 16-byte descriptor sector
                    ldb       #SS_FD    ; ask GetStat for descriptor contents
                    os9       I_GetStt  ; populate local descriptor buffer
                    rts                 ; return with carry reflecting GetStat status

                    endsect             ; end code section
