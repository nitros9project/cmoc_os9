*
* Adapted from cmoc_os9/lib/todo/chmod.a for the live CMOC ABI.
*

                    use       ../include/os9.d ; shared OS-9 service constants
                    use       ../include/fcntl.d ; shared file-mode constants

                    section   code      ; begin code section

_chmod              EXPORT    ;         export this symbol

_sysret             EXTERNAL  ;         import external symbol

FD_Att              equ       0         ; attribute byte offset in an OS-9 file descriptor
FD_Own              equ       1         ; owner field offset in an OS-9 file descriptor
Bufsize             equ       16        ; file descriptor sector bytes copied locally

_chmod:
stk_chmod_ret       equ       0         ; caller return address at entry
stk_chmod_path      equ       2         ; pathname pointer argument
stk_chmod_mode      equ       4         ; new attribute byte, passed as int
stk_chmod_buf       equ       0         ; 16-byte file descriptor buffer after allocation
stk_chmod_saved     equ       Bufsize   ; saved Y/U pair above local buffer
                    pshs      y,u       ; preserve caller frame registers
                    leas      -Bufsize,s ; reserve local descriptor-sector buffer

                    bsr       openfile  ; open path and load descriptor sector into local buffer
                    bcs       chexit    ; return OS-9 error if open or descriptor read failed

                    pshs      a,y       ; save path number and descriptor pointer during F$ID
                    os9       F_ID      ; fetch caller identity for ownership check
                    cmpy      #0        ; superuser owner ID can always change attributes
                    beq       chmod10   ; skip owner match when running as superuser
                    ldb       #E_FNA    ; deny non-owner updates
                    cmpy      FD_Own,x  ; compare caller ID with file descriptor owner
                    orcc      #1        ; pre-set carry so failure exits through _sysret
                    bne       chexit    ; reject when caller does not own the file

chmod10             ldb       stk_chmod_mode+1+Bufsize+4+3,s ; saved A/Y shifts mode low byte by 3 more bytes
                    stb       FD_Att,x  ; update descriptor attribute byte in local buffer
                    puls      a,y       ; restore path number and descriptor pointer
                    ldb       #SS_FD    ; request descriptor-sector SetStat
                    os9       I_SetStt  ; write back descriptor sector changes
                    bcs       chexit    ; preserve SetStat error for _sysret
                    os9       I_Close   ; close temporary path

chexit              leas      Bufsize,s ; release local descriptor buffer
                    puls      y,u       ; restore caller frame registers
                    lbra      _sysret   ; translate OS-9 carry/B result to C return value

openfile
                    lda       #FAM_WRITE ; open with write access so descriptor changes are allowed
                    ldx       stk_chmod_path+Bufsize+4+2,s ; BSR return shifts original path argument by 2 bytes
                    os9       I_Open    ; open target for descriptor access
                    bcc       openf10   ; read descriptor only after open succeeds
                    rts                 ; return to caller

openf10             leax      stk_chmod_buf+2,s ; point X at local descriptor buffer past BSR return address
                    ldy       #Bufsize  ; read exactly one descriptor buffer
                    ldb       #SS_FD    ; request descriptor-sector GetStat
                    os9       I_GetStt  ; load descriptor sector into local buffer
                    rts                 ; return to caller

                    endsect   ;         end current section
