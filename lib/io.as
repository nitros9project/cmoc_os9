                    use       ../include/os9.d ; shared OS-9 service constants
                    use       ../include/fcntl.d ; shared file access and permission constants
                    use       ../include/stdio.d ; shared seek-origin constants

__os_create         EXPORT    ;         export low-level create wrapper
__os_open           EXPORT    ;         export low-level open wrapper
__os_close          EXPORT    ;         export low-level close wrapper
__os_delete         EXPORT    ;         export low-level delete wrapper
__os_makdir         EXPORT    ;         export low-level make-directory wrapper
__os_read           EXPORT    ;         export low-level read wrapper
__os_readln         EXPORT    ;         export low-level readln wrapper
__os_write          EXPORT    ;         export low-level write wrapper
__os_writeln        EXPORT    ;         export low-level writeln wrapper
__os_seek           EXPORT    ;         export direct OS-9 seek wrapper
_lseek              EXPORT    ;         export stdio-style long seek helper

_oserr              EXTERNAL  ;         common OS-9 error-return helper
_osret              EXTERNAL  ;         common OS-9 success-return helper
_errno              EXTERNAL  ;         C errno storage
_flacc              EXTERNAL  ;         shared long return accumulator

                    section   code      ; begin code section

__os_create:
stk_os_create_saved_dp equ       0         ; saved direct-page byte after save prologue
stk_os_create_saved_regs equ       1         ; saved Y/U register block after save prologue
stk_os_create_ret   equ       5         ; caller return address after save prologue
stk_os_create_path  equ       7         ; pathname pointer argument after save prologue
stk_os_create_mode_byte equ       10        ; low byte of open/create mode argument
stk_os_create_outptr equ       11        ; caller pointer receiving path number
stk_os_create_perm_byte equ       14        ; low byte of permission argument
                    pshs      y,u       ; preserve registers used by OS-9
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    ldx       stk_os_create_path,s ; load pathname pointer
                    lda       stk_os_create_perm_byte,s ; load requested permission bits
                    tfr       a,b       ; copy permissions into B for masking
                    andb      #FAP_EXEC|FAP_PEXEC ; keep executable permission bits
                    orb       #FAP_READ|FAP_WRITE|FAP_PREAD ; force owner read/write and public read
                    os9       I_Create  ; try to create the path
                    bcc       createok  ; continue on successful create
                    cmpb      #E_CEF    ; check for already-exists error
                    bne       createerr ; fail immediately for any other error
                    lda       stk_os_create_mode_byte,s ; load requested mode byte
                    bita      #FAM_DIR  ; test directory bit in mode
                    bne       createerr ; do not retry open for directory create
                    anda      #FAM_READ|FAM_WRITE|S_IEXEC ; keep low-level access mode bits only
                    ldx       stk_os_create_path,s ; reload pathname pointer
                    os9       I_Open    ; fall back to opening the existing file
                    bcs       createerr ; fail if open also failed
                    pshs      d         ; save returned path descriptor
                    tfr       a,b       ; normalize path number into D
                    clra                ; clear high byte for 16-bit store
                    std       [stk_os_create_outptr+2,s] ; write opened path through shifted caller pointer
                    puls      d         ; recover original path descriptor bytes
                    pshs      a,u       ; save path and U around SetStat call
                    ldx       #0        ; pass null X parameter
                    leau      ,x        ; pass null U parameter
                    ldb       #SS_Size  ; request truncation-on-create update
                    os9       I_SetStt  ; truncate the reopened file
                    puls      a,u       ; restore path and U
                    bcc       createok  ; keep the reopened path on success
                    pshs      b         ; preserve SetStat error code
                    os9       I_Close   ; close the reopened path on truncation failure
                    puls      b         ; restore original error code
createerr
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _oserr    ; return with errno set from OS-9 status
createok
                    tfr       a,b       ; copy path number into B for 16-bit return store
                    clra                ; clear high byte for 16-bit path value
                    std       [stk_os_create_outptr,s] ; store created path through caller output pointer
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return success through shared helper

__os_open:
stk_os_open_saved_dp equ       0         ; saved direct-page byte after save prologue
stk_os_open_saved_regs equ       1         ; saved Y/U register block after save prologue
stk_os_open_ret     equ       5         ; caller return address after save prologue
stk_os_open_path    equ       7         ; pathname pointer argument after save prologue
stk_os_open_mode_byte equ       10        ; low byte of open mode argument
stk_os_open_outptr  equ       11        ; caller pointer receiving path number
                    pshs      y,u       ; preserve registers used by OS-9
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    ldx       stk_os_open_path,s ; load pathname pointer
                    lda       stk_os_open_mode_byte,s ; load open mode byte
                    os9       I_Open    ; open the requested path
                    lblo      openerr   ; branch to error path on carry set
                    pshs      d         ; save returned path descriptor bytes
                    tfr       a,b       ; normalize path number into D
                    clra                ; clear high byte for 16-bit store
                    std       [stk_os_open_outptr+2,s] ; write opened path through shifted output pointer
                    puls      d         ; discard saved descriptor bytes
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return success through shared helper
openerr
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _oserr    ; return OS-9 error through shared helper

__os_close:
stk_os_close_saved_dp equ       0         ; saved direct-page byte after save prologue
stk_os_close_saved_regs equ       1         ; saved Y/U register block after save prologue
stk_os_close_ret    equ       5         ; caller return address after save prologue
stk_os_close_path_byte equ       8         ; low byte of path number argument
                    pshs      y,u       ; preserve registers used by OS-9
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    lda       stk_os_close_path_byte,s ; load path number
                    os9       I_Close   ; close the path
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return status through shared helper

__os_delete:
stk_os_delete_saved_dp equ       0         ; saved direct-page byte after save prologue
stk_os_delete_saved_regs equ       1         ; saved Y/U register block after save prologue
stk_os_delete_ret   equ       5         ; caller return address after save prologue
stk_os_delete_path  equ       7         ; pathname pointer argument after save prologue
stk_os_delete_mode_byte equ       10        ; low byte of delete mode argument
                    pshs      y,u       ; preserve registers used by OS-9
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    ldx       stk_os_delete_path,s ; load pathname pointer
                    lda       stk_os_delete_mode_byte,s ; load delete mode byte
                    os9       I_DeletX  ; delete the named path with mode bits
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return status through shared helper

__os_makdir:
stk_os_makdir_saved_dp equ       0         ; saved direct-page byte after save prologue
stk_os_makdir_saved_regs equ       1         ; saved Y/U register block after save prologue
stk_os_makdir_ret   equ       5         ; caller return address after save prologue
stk_os_makdir_path  equ       7         ; pathname pointer argument after save prologue
stk_os_makdir_perm_byte equ       10        ; low byte of directory permission argument
                    pshs      y,u       ; preserve registers used by OS-9
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    ldx       stk_os_makdir_path,s ; load pathname pointer
                    ldb       stk_os_makdir_perm_byte,s ; load directory permission byte
                    os9       I_MakDir  ; create the directory
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return status through shared helper

__os_read:
stk_os_read_saved_y equ       0         ; saved Y register after pshs y
stk_os_read_ret     equ       2         ; caller return address after pshs y
stk_os_read_path_byte equ       5         ; low byte of path number argument
stk_os_read_buffer  equ       6         ; destination buffer pointer
stk_os_read_countp  equ       8         ; caller pointer to requested/actual byte count
                    pshs      y         ; preserve Y while staging count pointer
                    lda       stk_os_read_path_byte,s ; load path number
                    ldx       stk_os_read_buffer,s ; load destination buffer pointer
                    ldy       [stk_os_read_countp,s] ; load requested byte count from caller pointer
                    pshs      y         ; save original count on stack for writeback slot
                    os9       I_Read    ; read bytes from the path
afterread
                    bcc       savecount ; continue if the read succeeded
                    cmpb      #E_EOF    ; treat EOF as a short read rather than hard error
                    bne       readerr   ; branch out for all other OS-9 errors
                    ldy       #0        ; report zero bytes read at end of file
                    bra       savecount ; write back zero count and return success
readerr
                    puls      x,y       ; discard saved count and restore caller's Y
                    lbra      _oserr    ; return OS-9 error through shared helper
savecount
                    sty       [stk_os_read_countp+2,s] ; store actual count through shifted caller pointer
                    puls      x,y       ; discard saved count slot and restore caller's Y
                    lbra      _osret    ; return success through shared helper

__os_readln:
stk_os_readln_saved_y equ       0         ; saved Y register after pshs y
stk_os_readln_ret   equ       2         ; caller return address after pshs y
stk_os_readln_path_byte equ       5         ; low byte of path number argument
stk_os_readln_buffer equ       6         ; destination buffer pointer
stk_os_readln_countp equ       8         ; caller pointer to requested/actual byte count
                    pshs      y         ; preserve Y while staging count pointer
                    lda       stk_os_readln_path_byte,s ; load path number
                    ldx       stk_os_readln_buffer,s ; load destination buffer pointer
                    ldy       [stk_os_readln_countp,s] ; load requested byte count from caller pointer
                    pshs      y         ; save original count on stack for writeback slot
                    os9       I_ReadLn  ; read one line from the path
                    bra       afterread ; share the count/error handling path

__os_write:
stk_os_write_saved_y equ       0         ; saved Y register after pshs y
stk_os_write_ret    equ       2         ; caller return address after pshs y
stk_os_write_path_byte equ       5         ; low byte of path number argument
stk_os_write_buffer equ       6         ; source buffer pointer
stk_os_write_countp equ       8         ; caller pointer to requested/actual byte count
                    pshs      y         ; preserve Y while using it as the count register
                    ldy       [stk_os_write_countp,s] ; load requested byte count from caller pointer
                    beq       writeex   ; treat zero-length write as immediate success
                    lda       stk_os_write_path_byte,s ; load path number
                    ldx       stk_os_write_buffer,s ; load source buffer pointer
                    os9       I_Write   ; write bytes to the path
write_status_check  bcc       store_writeex ; continue if the write succeeded
                    puls      y         ; restore caller's Y before error return
                    lbra      _oserr    ; return OS-9 error through shared helper
store_writeex
                    sty       [stk_os_write_countp,s] ; store actual byte count through caller pointer
writeex
                    puls      y         ; restore caller's Y register
                    lbra      _osret    ; return success through shared helper

__os_writeln:
stk_os_writeln_saved_y equ       0         ; saved Y register after pshs y
stk_os_writeln_ret  equ       2         ; caller return address after pshs y
stk_os_writeln_path_byte equ       5         ; low byte of path number argument
stk_os_writeln_buffer equ       6         ; source buffer pointer
stk_os_writeln_countp equ       8         ; caller pointer to requested/actual byte count
                    pshs      y         ; preserve Y while using it as the count register
                    ldy       [stk_os_writeln_countp,s] ; load requested byte count from caller pointer
                    beq       writeex   ; treat zero-length write as immediate success
                    lda       stk_os_writeln_path_byte,s ; load path number
                    ldx       stk_os_writeln_buffer,s ; load source buffer pointer
                    os9       I_WritLn  ; write bytes followed by line termination
                    bra       write_status_check ; share the count/error handling path

__os_seek:
stk_os_seek_saved_dp equ       0         ; saved direct-page byte after save prologue
stk_os_seek_saved_regs equ       1         ; saved Y/D/X/U register block after save prologue
stk_os_seek_ret     equ       9         ; caller return address after save prologue
stk_os_seek_path_byte equ       12        ; low byte of path number argument
stk_os_seek_pos_hi  equ       13        ; high word of 32-bit absolute position
stk_os_seek_pos_lo  equ       15        ; low word of 32-bit absolute position
                    pshs      y,d,x,u   ; preserve live registers around OS-9 call
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    ldx       stk_os_seek_pos_hi,s ; load high word of 32-bit file position
                    ldu       stk_os_seek_pos_lo,s ; load low word of 32-bit file position
                    lda       stk_os_seek_path_byte,s ; load path number
                    os9       I_Seek    ; perform direct OS-9 seek
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,d,x,u   ; restore preserved registers
                    lbra      _osret    ; return status through shared helper

_lseek:
stk_lseek_saved_u   equ       0         ; saved U register after pshs u
stk_lseek_ret       equ       2         ; caller return address after pshs u
stk_lseek_resultp   equ       4         ; hidden pointer receiving 32-bit return value
stk_lseek_path_byte equ       7         ; low byte of path number argument
stk_lseek_offset_hi equ       8         ; high word of signed 32-bit offset
stk_lseek_offset_lo equ       10        ; low word of signed 32-bit offset
stk_lseek_whence    equ       12        ; seek-origin selector
                    pshs      u         ; preserve caller's U register
                    ldd       stk_lseek_whence,s ; load whence selector
                    bne       lseek10   ; branch for SEEK_CUR/SEEK_END cases
                    ldu       #0        ; SEEK_SET starts from absolute zero low word
                    ldx       #0        ; SEEK_SET starts from absolute zero high word
                    bra       doseek    ; combine base and requested offset

lseek10
                    cmpd      #SEEK_CUR ; test for current-position relative seek
                    beq       here      ; fetch current file position as base
                    cmpd      #SEEK_END ; test for end-of-file relative seek
                    beq       end       ; fetch file size as base
                    ldb       #E_Seek   ; preload invalid-whence error code
lserr
                    clra                ; clear high byte for errno store
                    std       _errno,y  ; update errno with the seek failure code
                    ldd       #-1       ; prepare long -1 return value
                    ldx       stk_lseek_resultp,s ; load hidden pointer to 32-bit return slot
                    std       0,x       ; store high word of -1
                    std       2,x       ; store low word of -1
                    puls      u,pc      ; restore U and return failure

end
                    lda       stk_lseek_path_byte,s ; load path number
                    ldb       #SS_Size  ; request 32-bit file size
                    os9       I_GetStt  ; fetch end-of-file position into X/U
                    bcs       lserr     ; fail if GetStat did not succeed
                    bra       doseek    ; add requested offset to file size

here
                    lda       stk_lseek_path_byte,s ; load path number
                    ldb       #SS_Pos   ; request current 32-bit file position
                    os9       I_GetStt  ; fetch current offset into X/U
                    bcs       lserr     ; fail if GetStat did not succeed

doseek
                    tfr       u,d       ; copy base low word into D
                    addd      stk_lseek_offset_lo,s ; add requested low-word offset
                    std       _flacc+2,y ; save tentative low word in long accumulator
                    tfr       d,u       ; keep combined low word in U for direct seek
                    tfr       x,d       ; copy base high word into D
                    adcb      stk_lseek_offset_hi+1,s ; add carry and requested high-word low byte
                    adca      stk_lseek_offset_hi,s ; add requested high-word high byte
                    bmi       lserr     ; reject negative resulting file positions
                    tfr       d,x       ; keep combined high word in X for direct seek
                    std       _flacc,y  ; save tentative high word in long accumulator
                    lda       stk_lseek_path_byte,s ; load path number
                    os9       I_Seek    ; apply the new absolute file position
                    bcs       lserr     ; fail if the direct seek was rejected
                    ldx       stk_lseek_resultp,s ; load hidden pointer to 32-bit return slot
                    ldd       _flacc,y  ; fetch resulting high word
                    std       0,x       ; store high word through return pointer
                    ldd       _flacc+2,y ; fetch resulting low word
                    std       2,x       ; store low word through return pointer
                    puls      u,pc      ; restore U and return success

                    endsect   ;         end code section
