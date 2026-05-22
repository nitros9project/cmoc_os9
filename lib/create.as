* Compact assembly implementation of creat/create/ocreat().

                    use       ../include/os9.d ; shared OS-9 service and error constants
                    use       ../include/fcntl.d ; shared file access and attribute bits

                    section   code      ; begin code section

_creat              EXPORT    ;         export this symbol
_create             EXPORT    ;         export this symbol
_ocreat             EXPORT    ;         export this symbol

_os9err             EXTERNAL  ;         import external symbol

CREAT_EXEC_MASK     equ       S_IEXEC|S_IOEXEC ; execute bits creat() preserves from mode
CREAT_DEFAULT_ATTR  equ       S_IREAD|S_IWRITE|S_IOREAD ; default non-execute creat() attributes
CREAT_OPEN_MASK     equ       S_IREAD|S_IWRITE|S_IEXEC ; access bits usable by I$Open fallback
CREAT_SAVED_U_SIZE  equ       2         ; bytes pushed by each entry while preserving U

_creat:
stk_creat_ret       equ       0         ; caller return address
stk_creat_path      equ       2         ; pathname pointer argument
stk_creat_mode      equ       4         ; creat() mode argument
                    pshs      u         ; preserve caller frame register
                    ldx       stk_creat_path+2,s ; saved U shifts pathname argument by 2 bytes
                    lda       stk_creat_mode+3,s ; load low byte of mode after saved U
                    tfr       a,b       ; copy requested mode bits into B for OS-9 attributes
                    andb      #CREAT_EXEC_MASK ; preserve requested execute bits
                    orb       #CREAT_DEFAULT_ATTR ; force default read/write attributes
                    os9       I_Create  ; invoke OS-9 create path call
                    bcc       L_creat_ret ; return path number when create succeeds
                    cmpb      #E_CEF    ; creating existing file?
                    bne       L_create_err ; report any error other than existing file
                    lda       stk_creat_mode+3,s ; reload mode low byte for existing-file fallback
                    bita      #S_DIR    ; do not treat a directory request as a regular file open
                    bne       L_create_err ; reject directory creation through creat()
                    anda      #CREAT_OPEN_MASK ; keep only OS-9 open access bits
                    ldx       stk_creat_path+2,s ; reload pathname for I$Open fallback
                    os9       I_Open    ; try opening the existing file
                    bcs       L_create_err ; report open failure
                    pshs      a,u       ; save path number and frame register while truncating
                    ldx       #0        ; set high half of new file size to zero
                    leau      ,x        ; set low half of new file size to zero
                    ldb       #SS_Size  ; request SetStat file-size update
                    os9       I_SetStt  ; set file size to zero for truncation
                    puls      a,u       ; restore A,U from the hardware stack
                    bcc       L_creat_ret ; return path number after successful truncation
                    pshs      b         ; save B on the hardware stack
                    os9       I_Close   ; close partially opened path on failure
                    puls      b         ; restore B from the hardware stack
L_create_err
                    leas      CREAT_SAVED_U_SIZE,s ; discard saved U before entering shared OS-9 error path
                    lbra      _os9err   ; convert OS-9 error in B to C errno return

_create:
stk_create_ret      equ       0         ; caller return address
stk_create_path     equ       2         ; pathname pointer argument
stk_create_access   equ       4         ; OS-9 access mode argument
stk_create_attrs    equ       6         ; OS-9 file attributes argument
                    pshs      u         ; preserve caller frame register
                    ldx       stk_create_path+2,s ; saved U shifts pathname argument by 2 bytes
                    lda       stk_create_access+3,s ; load low byte of access mode
                    ldb       stk_create_attrs+3,s ; load low byte of file attributes
                    os9       I_Create  ; invoke OS-9 create path call
                    bcs       L_ocreat_retry ; retry only when existing file caused failure
                    bra       L_creat_ret ; return newly created path

L_ocreat_retry
                    cmpb      #E_CEF    ; creating existing file?
                    bne       L_create_err ; report non-existing-file create errors
                    ldx       stk_create_path+2,s ; reload pathname for delete-and-retry
                    os9       I_Delete  ; remove old file before retrying create
                    bcs       L_create_err ; report delete failure
                    puls      u         ; restore U from the hardware stack
                    bra       _ocreat   ; retry create without the existing file

_ocreat:
stk_ocreat_ret      equ       0         ; caller return address
stk_ocreat_path     equ       2         ; pathname pointer argument
stk_ocreat_access   equ       4         ; OS-9 access mode argument
stk_ocreat_attrs    equ       6         ; OS-9 file attributes argument
                    pshs      u         ; preserve caller frame register
                    ldx       stk_ocreat_path+2,s ; saved U shifts pathname argument by 2 bytes
                    lda       stk_ocreat_access+3,s ; load low byte of access mode
                    ldb       stk_ocreat_attrs+3,s ; load low byte of file attributes
                    os9       I_Create  ; invoke OS-9 create path call
                    bcs       L_ocreat_retry ; delete existing file and retry when requested

L_creat_ret
                    leas      CREAT_SAVED_U_SIZE,s ; discard saved U before returning
                    tfr       a,b       ; move OS-9 path number into low byte of int return
                    clra                ; clear high byte of int return
                    rts                 ; return to caller

                    endsect   ;         end current section
