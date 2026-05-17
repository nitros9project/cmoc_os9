                    use       ../include/os9.d ; shared OS-9 service constants

__os_create         EXPORT              ; export low-level create wrapper
__os_open           EXPORT              ; export low-level open wrapper
__os_close          EXPORT              ; export low-level close wrapper
__os_delete         EXPORT              ; export low-level delete wrapper
__os_makdir         EXPORT              ; export low-level make-directory wrapper
__os_read           EXPORT              ; export low-level read wrapper
__os_readln         EXPORT              ; export low-level readln wrapper
__os_write          EXPORT              ; export low-level write wrapper
__os_writeln        EXPORT              ; export low-level writeln wrapper
__os_seek           EXPORT              ; export direct OS-9 seek wrapper
_lseek              EXPORT              ; export stdio-style long seek helper

_oserr              EXTERNAL            ; common OS-9 error-return helper
_osret              EXTERNAL            ; common OS-9 success-return helper
_errno              EXTERNAL            ; C errno storage
_flacc              EXTERNAL            ; shared long return accumulator

                    section   code      ; begin code section

__os_create
                    pshs      y,u       ; preserve registers used by OS-9
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    ldx       7,s       ; load pathname pointer
                    lda       14,s      ; load permissions byte
                    tfr       a,b       ; copy permissions into B for masking
                    andb      #$24      ; keep public write/share bits only
                    orb       #$0B      ; force owner read/write and public read
                    os9       I_Create  ; try to create the path
                    bcc       createok  ; continue on successful create
                    cmpb      #$DA      ; check for already-exists error
                    bne       createerr ; fail immediately for any other error
                    lda       10,s      ; load requested mode byte
                    bita      #$80      ; test directory bit in mode
                    bne       createerr ; do not retry open for directory create
                    anda      #7        ; keep low-level access mode bits only
                    ldx       7,s       ; reload pathname pointer
                    os9       I_Open    ; fall back to opening the existing file
                    bcs       createerr ; fail if open also failed
                    pshs      d         ; save returned path descriptor
                    tfr       a,b       ; normalize path number into D
                    clra                ; clear high byte for 16-bit store
                    std       [13,s]    ; write opened path number to caller output pointer
                    puls      d         ; recover original path descriptor bytes
                    pshs      a,u       ; save path and U around SetStat call
                    ldx       #0        ; pass null X parameter
                    leau      ,x        ; pass null U parameter
                    ldb       #2        ; request SS_Size style truncation-on-create update
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
                    std       [11,s]    ; store created path through caller's output pointer
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return success through shared helper

__os_open
                    pshs      y,u       ; preserve registers used by OS-9
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    ldx       7,s       ; load pathname pointer
                    lda       10,s      ; load open mode byte
                    os9       I_Open    ; open the requested path
                    lblo      openerr   ; branch to error path on carry set
                    pshs      d         ; save returned path descriptor bytes
                    tfr       a,b       ; normalize path number into D
                    clra                ; clear high byte for 16-bit store
                    std       [13,s]    ; write opened path to caller output pointer
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

__os_close
                    pshs      y,u       ; preserve registers used by OS-9
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    lda       8,s       ; load path number
                    os9       I_Close   ; close the path
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return status through shared helper

__os_delete
                    pshs      y,u       ; preserve registers used by OS-9
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    ldx       7,s       ; load pathname pointer
                    lda       10,s      ; load mode byte
                    os9       I_DeletX  ; delete the named path with mode bits
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return status through shared helper

__os_makdir
                    pshs      y,u       ; preserve registers used by OS-9
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    ldx       7,s       ; load pathname pointer
                    ldb       10,s      ; load permission byte
                    os9       I_MakDir  ; create the directory
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,u       ; restore preserved registers
                    lbra      _osret    ; return status through shared helper

__os_read
                    pshs      y         ; preserve Y while staging count pointer
                    lda       5,s       ; load path number
                    ldx       6,s       ; load destination buffer pointer
                    ldy       [8,s]     ; load requested byte count from caller pointer
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
                    sty       [10,s]    ; store actual byte count through caller pointer
                    puls      x,y       ; discard saved count slot and restore caller's Y
                    lbra      _osret    ; return success through shared helper

__os_readln
                    pshs      y         ; preserve Y while staging count pointer
                    lda       5,s       ; load path number
                    ldx       6,s       ; load destination buffer pointer
                    ldy       [8,s]     ; load requested byte count from caller pointer
                    pshs      y         ; save original count on stack for writeback slot
                    os9       I_ReadLn  ; read one line from the path
                    bra       afterread ; share the count/error handling path

__os_write
                    pshs      y         ; preserve Y while using it as the count register
                    ldy       [8,s]     ; load requested byte count from caller pointer
                    beq       writeex   ; treat zero-length write as immediate success
                    lda       5,s       ; load path number
                    ldx       6,s       ; load source buffer pointer
                    os9       I_Write   ; write bytes to the path
L00xe               bcc       store_writeex ; continue if the write succeeded
                    puls      y         ; restore caller's Y before error return
                    lbra      _oserr    ; return OS-9 error through shared helper
store_writeex
                    sty       [8,s]     ; store actual byte count through caller pointer
writeex
                    puls      y         ; restore caller's Y register
                    lbra      _osret    ; return success through shared helper

__os_writeln
                    pshs      y         ; preserve Y while using it as the count register
                    ldy       [8,s]     ; load requested byte count from caller pointer
                    beq       writeex   ; treat zero-length write as immediate success
                    lda       5,s       ; load path number
                    ldx       6,s       ; load source buffer pointer
                    os9       I_WritLn  ; write bytes followed by line termination
                    bra       L00xe     ; share the count/error handling path

__os_seek
                    pshs      y,d,x,u   ; preserve live registers around OS-9 call
                    tfr       dp,a      ; save caller's direct-page register
                    pshs      a         ; keep saved DP on the stack
                    ldx       13,s      ; load high word of 32-bit file position
                    ldu       15,s      ; load low word of 32-bit file position
                    lda       12,s      ; load path number
                    os9       I_Seek    ; perform direct OS-9 seek
                    puls      a         ; recover saved direct-page byte
                    tfr       a,dp      ; restore caller's direct-page register
                    puls      y,d,x,u   ; restore preserved registers
                    lbra      _osret    ; return status through shared helper

_lseek
                    pshs      u         ; preserve caller's U register
                    ldd       12,s      ; load whence selector
                    bne       lseek10   ; branch for SEEK_CUR/SEEK_END cases
                    ldu       #0        ; SEEK_SET starts from absolute zero low word
                    ldx       #0        ; SEEK_SET starts from absolute zero high word
                    bra       doseek    ; combine base and requested offset

lseek10
                    cmpd      #1        ; test for SEEK_CUR
                    beq       here      ; fetch current file position as base
                    cmpd      #2        ; test for SEEK_END
                    beq       end       ; fetch file size as base
                    ldb       #E_Seek   ; preload invalid-whence error code
lserr
                    clra                ; clear high byte for errno store
                    std       _errno,y  ; update errno with the seek failure code
                    ldd       #-1       ; prepare long -1 return value
                    ldx       4,s       ; load hidden pointer to 32-bit return slot
                    std       0,x       ; store high word of -1
                    std       2,x       ; store low word of -1
                    puls      u,pc      ; restore U and return failure

end
                    lda       7,s       ; load path number
                    ldb       #SS_Size  ; request 32-bit file size
                    os9       I_GetStt  ; fetch end-of-file position into X/U
                    bcs       lserr     ; fail if GetStat did not succeed
                    bra       doseek    ; add requested offset to file size

here
                    lda       7,s       ; load path number
                    ldb       #SS_Pos   ; request current 32-bit file position
                    os9       I_GetStt  ; fetch current offset into X/U
                    bcs       lserr     ; fail if GetStat did not succeed

doseek
                    tfr       u,d       ; copy base low word into D
                    addd      10,s      ; add requested low-word offset
                    std       _flacc+2,y ; save tentative low word in long accumulator
                    tfr       d,u       ; keep combined low word in U for direct seek
                    tfr       x,d       ; copy base high word into D
                    adcb      7,s       ; add carry and requested low byte of high word
                    adca      6,s       ; add requested high byte of high word
                    bmi       lserr     ; reject negative resulting file positions
                    tfr       d,x       ; keep combined high word in X for direct seek
                    std       _flacc,y  ; save tentative high word in long accumulator
                    lda       5,s       ; load path number
                    os9       I_Seek    ; apply the new absolute file position
                    bcs       lserr     ; fail if the direct seek was rejected
                    ldx       4,s       ; load hidden pointer to 32-bit return slot
                    ldd       _flacc,y  ; fetch resulting high word
                    std       0,x       ; store high word through return pointer
                    ldd       _flacc+2,y ; fetch resulting low word
                    std       2,x       ; store low word through return pointer
                    puls      u,pc      ; restore U and return success

                    endsect             ; end code section
