_fflush             EXPORT    ;         export stream flush helper
_flush              EXPORT    ;         export internal stdio flush helper

__os_write          EXTERNAL  ;         low-level write wrapper
__os_writeln        EXTERNAL  ;         low-level writeln wrapper
_setbase            EXTERNAL  ;         stdio buffer initializer
_ftell              EXTERNAL  ;         buffered current-position helper
_lseek              EXTERNAL  ;         long seek helper
_flacc              EXTERNAL  ;         shared long accumulator used as lseek return slot

_WRITE              equ       $02       ; FILE open-for-write flag
_APPEND             equ       $02       ; high-byte FILE append-mode flag
_ERR                equ       $20       ; FILE error flag
_SCF                equ       $40       ; sequential character file-manager flag

                    section   code      ; begin code section

_fflush:
stk_fflush_ret      equ       0         ; caller return address
stk_fflush_file     equ       2         ; FILE pointer argument
                    pshs      u         ; preserve caller's U register
                    ldu       stk_fflush_file+2,s ; load FILE pointer after saved U
                    beq       L_fflush_bad ; reject null stream pointers
                    ldd       6,u       ; load FILE flags word
                    andb      #_ERR|_WRITE ; require writable stream with no error set
                    cmpb      #_WRITE   ; compare against clean writable state
                    bne       L_fflush_bad ; reject streams that cannot be flushed
                    anda      #$80      ; test initialized bit in high byte
                    bne       L_fflush_inited ; skip setup if buffering is already initialized
                    pshs      u         ; pass FILE pointer to setbase
                    lbsr      _setbase  ; allocate/setup stream buffering state
                    leas      2,s       ; discard staged FILE pointer
L_fflush_inited     pshs      u         ; pass FILE pointer to internal flush helper
                    bsr       _flush    ; write any buffered output and reset pointers
                    leas      2,s       ; discard staged FILE pointer
                    puls      u,pc      ; restore U and return helper status
L_fflush_bad        ldd       #-1       ; return EOF on failure
                    puls      u,pc      ; restore U and return

_flush:
stk_flush_ret       equ       0         ; caller return address
stk_flush_file      equ       2         ; FILE pointer argument
                    pshs      u         ; preserve caller's U register
                    ldu       stk_flush_file+2,s ; load FILE pointer after saved U
                    leas      -4,s      ; reserve local word/count scratch space
                    lda       6,u       ; load high byte of FILE flags
                    anda      #_APPEND  ; test append-mode behavior before any sync correction
                    beq       flush_sync_existing ; non-append streams keep the existing synchronization path
                    ldd       #2        ; build SEEK_END selector for append streams
                    pshs      d         ; stage whence for _lseek
                    clra                ; zero offset high byte for append seek
                    clrb                ; zero offset low byte for append seek
                    pshs      d         ; stage zero offset low word
                    pshs      d         ; stage zero offset high word
                    ldd       8,u       ; load underlying path number
                    pshs      d         ; stage path number for _lseek
                    leax      _flacc,y  ; provide hidden long return slot for _lseek
                    pshs      x         ; stage hidden return pointer
                    lbsr      _lseek    ; force descriptor position back to EOF before writing
                    leas      10,s      ; discard staged _lseek arguments
                    bra       flush_pending_bytes ; continue into normal pending-byte flush logic
flush_sync_existing
                    lda       6,u       ; load high byte of FILE flags
                    anda      #1        ; test _WRITTEN bit
                    bne       flush_pending_bytes ; skip seek correction once stream is in write mode
                    ldd       ,u        ; load current buffer pointer
                    cmpd      4,u       ; compare against buffer end pointer
                    beq       flush_pending_bytes ; no correction needed when buffer is already full
                    clra                ; build zero offset for ftell/seek correction
                    clrb                ; build zero offset for ftell/seek correction
                    pshs      d         ; keep SEEK_SET-style whence 0 for the later _lseek call
                    leax      _flacc,y  ; provide hidden long return slot for ftell
                    pshs      x,u       ; stage hidden return slot and FILE pointer for ftell
                    lbsr      _ftell    ; compute current buffered file position
                    leas      4,s       ; discard staged hidden return slot and FILE pointer
                    leax      _flacc,y  ; point X at the returned long value
                    ldd       2,x       ; fetch low word of current file position
                    pshs      d         ; stage low word for lseek
                    ldd       ,x        ; fetch high word of current file position
                    pshs      d         ; stage high word for lseek
                    ldd       8,u       ; load underlying path number
                    pshs      d         ; stage path number for lseek
                    leax      _flacc,y  ; provide hidden long return slot for lseek
                    pshs      x         ; stage hidden return pointer
                    lbsr      _lseek    ; synchronize OS-9 file position with buffer state
                    leas      10,s      ; discard staged lseek arguments
flush_pending_bytes ldd       ,u        ; load current buffer pointer
                    subd      2,u       ; compute buffered byte count as ptr-base
                    std       2,s       ; save pending-byte count in local scratch
                    lbeq      flush_success ; nothing to flush if the buffer is empty
                    ldd       6,u       ; reload FILE flags word
                    anda      #1        ; test _WRITTEN bit
                    lbeq      flush_success ; do not flush if buffer only contains read data
                    andb      #_SCF     ; test whether device is SCF
                    beq       _flushrbf ; block-write path for non-SCF devices
                    ldd       2,u       ; start SCF writes from the buffer base
                    bra       _flush3   ; share pointer update logic
_flush2             pshs      x         ; preserve X while staging write arguments
                    pshs      d         ; stage remaining byte count
                    leax      ,s        ; point X at count slot
                    pshs      x         ; pass pointer-to-count
                    ldd       ,u        ; load current buffer pointer
                    pshs      d         ; pass data pointer
                    ldd       8,u       ; load underlying path number
                    pshs      d         ; pass path number
                    lbsr      __os_writeln ; write buffered data to SCF device
                    leas      10,s      ; discard staged arguments and preserved X
                    cmpd      #0        ; low-level wrappers return zero on success
                    bne       flush_error ; branch if the device write failed
                    ldd       2,s       ; fetch pending-byte count
                    subd      -4,s      ; subtract amount written this iteration
                    std       2,s       ; update pending-byte count
                    ldd       ,u        ; reload current buffer pointer
                    addd      -4,s      ; advance by amount written this iteration
_flush3             std       ,u        ; save updated current buffer pointer
                    ldd       2,s       ; fetch remaining byte count
                    bne       _flush2   ; loop until all SCF bytes are written
                    bra       flush_success ; finalize successful flush

_flushrbf           leax      2,s       ; point X at pending-byte count
                    pshs      x         ; pass pointer-to-count
                    ldd       2,u       ; load buffer base pointer
                    pshs      d         ; pass data pointer
                    ldd       8,u       ; load underlying path number
                    pshs      d         ; pass path number
                    lbsr      __os_write ; write buffered block to non-SCF device
                    leas      6,s       ; discard staged write arguments
                    bne       flush_error ; branch if the block write failed
                    bra       flush_success ; finalize successful flush
flush_error         ldb       7,u       ; load low byte of FILE flags
                    orb       #_ERR     ; mark stream as having encountered an error
                    stb       7,u       ; save updated error flag
                    ldd       4,u       ; load buffer end pointer
                    std       ,u        ; move current pointer to end to prevent reuse
                    ldd       #-1       ; return EOF on flush failure
                    bra       flush_return ; share final stack teardown

flush_success       lda       6,u       ; load high byte of FILE flags
                    ora       #1        ; mark stream as being in written/update state
                    sta       6,u       ; save updated write-state flag
                    ldd       2,u       ; load buffer base pointer
                    std       ,u        ; reset current pointer back to buffer base
                    addd      11,u      ; compute buffer end as base + buffer size
                    std       4,u       ; save refreshed buffer end pointer
                    clra                ; return zero on successful flush
                    clrb                ; return zero on successful flush
flush_return        leas      4,s       ; discard local scratch space
                    puls      u,pc      ; restore U and return

                    endsect   ;         end code section
