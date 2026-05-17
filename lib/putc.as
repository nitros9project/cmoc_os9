_putc               EXPORT              ; export buffered/unbuffered character output
_putw               EXPORT              ; export 16-bit word output helper
_fclose             EXPORT              ; export stream close helper
_fflush             EXPORT              ; export stream flush helper

__os_write          EXTERNAL            ; low-level write wrapper
__os_writeln        EXTERNAL            ; low-level writeln wrapper
__os_close          EXTERNAL            ; low-level close wrapper
_setbase            EXTERNAL            ; stdio buffer initializer
_ftell              EXTERNAL            ; buffered current-position helper
_lseek              EXTERNAL            ; long seek helper
__iob               EXTERNAL            ; stdio FILE table base

_WRITE              equ       $02       ; FILE open-for-write flag
_UNBUF              equ       $04       ; FILE unbuffered flag
_ERR                equ       $20       ; FILE error flag
_SCF                equ       $40       ; sequential character file-manager flag
_NFILE              equ       $10       ; number of FILE entries in _iob

                    section   code      ; begin code section

_putc
                    pshs      u         ; preserve caller's U register
                    ldu       6,s       ; load FILE pointer
                    ldd       6,u       ; load FILE flags word
                    anda      #$80      ; isolate initialized bit in high byte
                    andb      #_ERR|_WRITE ; keep only error/write bits
                    cmpb      #_WRITE   ; require writable stream with no error set
                    bne       badexit   ; fail if stream is not writable
                    cmpa      #$80      ; test whether stream buffers are initialized
                    beq       inited    ; skip initialization if already set up
                    pshs      u         ; pass FILE pointer to setbase
                    lbsr      _setbase  ; allocate/setup stream buffering state
                    leas      2,s       ; discard pushed FILE pointer
inited              ldd       6,u       ; reload FILE flags after possible initialization
                    andb      #_UNBUF   ; test whether this stream is unbuffered
                    beq       buffered  ; branch if buffered output is allowed
                    ldd       #1        ; write exactly one byte for unbuffered stream
                    pshs      d         ; push count value
                    leax      ,s        ; point X at count slot for low-level API
                    pshs      x         ; push pointer to count
                    leax      9,s       ; point X at the character argument byte
                    ldd       8,u       ; load underlying path number
                    pshs      d,x       ; push path and data pointer
                    ldb       7,u       ; load low byte of FILE flags
                    andb      #_SCF     ; test whether device is SCF
                    beq       L0035     ; plain block write for non-SCF devices
                    lbsr      __os_writeln ; SCF output wants line semantics
                    bra       L0038     ; share post-write result handling
L0035               lbsr      __os_write ; perform raw byte write
L0038               leas      8,s       ; discard stacked write arguments
                    cmpd      #0        ; low-level wrappers return zero on success
                    beq       L0079     ; return written character on success
                    ldb       7,u       ; reload low byte of FILE flags
                    orb       #_ERR     ; mark stream as having encountered an error
                    stb       7,u       ; save updated error flag
badexit             ldd       #-1       ; return EOF on failure
                    puls      u,pc      ; restore U and return

buffered            anda      #$01      ; test _WRITTEN state in high-byte flag bit
                    bne       L0058     ; skip initial flush if already in write mode
                    pshs      u         ; pass FILE pointer to flush helper
                    lbsr      _flush    ; synchronize buffer for first write after reading
                    std       ,s++      ; discard helper argument and capture return code
                    bne       badexit   ; fail if the flush/setup did not succeed
L0058               ldx       ,u        ; load current buffer pointer
                    ldb       5,s       ; load character argument
                    stb       ,x+       ; store character and advance pointer
                    stx       ,u        ; save updated buffer pointer
                    cmpx      4,u       ; compare against buffer end pointer
                    bcc       L0070     ; flush once the buffer reaches its limit
                    ldb       7,u       ; load low byte of FILE flags
                    andb      #_SCF     ; only SCF streams flush on newline
                    beq       L0079     ; buffered RBF devices can delay the write
                    ldb       5,s       ; reload character argument
                    cmpb      #$0A      ; test for line-feed terminator
                    bne       L0079     ; keep buffering until newline or full buffer
                    ldb       #$0D      ; convert pending line terminator to carriage return
L0070               pshs      u         ; pass FILE pointer to flush helper
                    lbsr      _flush    ; write buffered data to the underlying path
                    std       ,s++      ; discard helper argument and capture return code
                    bne       badexit   ; fail if the flush did not succeed
L0079               ldd       4,s       ; return original character argument
                    puls      u,pc      ; restore U and return

_putw               pshs      u         ; preserve caller's U register
                    ldu       6,s       ; load FILE pointer
                    ldb       4,s       ; load high byte of word argument
                    pshs      d,u       ; stage first character and FILE pointer for putc
                    lbsr      _putc     ; write high byte first
                    ldb       9,s       ; load low byte of original word argument
                    stb       1,s       ; replace staged character with low byte
                    lbsr      _putc     ; write low byte second
                    leas      4,s       ; discard staged arguments
                    cmpd      #-1       ; propagate EOF if either byte write failed
                    beq       putwbye   ; leave failure code intact
                    clra                ; return zero on success
                    clrb                ; return zero on success
putwbye             puls      u,pc      ; restore U and return

_tidyup             pshs      u         ; preserve caller's U register
                    leax      __iob,y   ; point at the first FILE entry
                    ldb       #_NFILE   ; load number of entries to close
                    pshs      b         ; keep countdown on the stack
L009d               pshs      x         ; stage current FILE pointer for fclose
                    lbsr      _fclose   ; attempt to close this stream
                    puls      x         ; recover FILE pointer for iteration
                    leax      13,x      ; advance to next FILE structure
                    dec       ,s        ; count one stream down
                    bne       L009d     ; continue until all FILE entries were visited
                    puls      b,u,pc    ; discard counter, restore U, and return

_fclose             pshs      u         ; preserve caller's U register
                    ldu       4,s       ; load FILE pointer
                    lbeq      badexit   ; reject null stream pointers
                    ldd       6,u       ; load FILE flags word
                    lbeq      badexit   ; reject unopened streams
                    andb      #_WRITE   ; check whether stream is writable
                    beq       L00c5     ; skip flush for read-only streams
                    pshs      u         ; pass FILE pointer to fflush
                    lbsr      _fflush   ; flush pending buffered output
                    leas      2,s       ; discard staged FILE pointer
                    bra       L00c7     ; continue with close regardless of flush result
L00c5               clra                ; synthesize zero status for read-only streams
                    clrb                ; synthesize zero status for read-only streams
L00c7               pshs      d         ; preserve flush status across low-level close
                    ldd       8,u       ; load underlying path number
                    pshs      d         ; stage path number for __os_close
                    lbsr      __os_close ; close the underlying OS-9 path
                    leas      2,s       ; discard staged path number
                    clra                ; clear high byte for zero flag word
                    clrb                ; clear low byte for zero flag word
                    std       6,u       ; mark FILE entry as unused
                    puls      d,u,pc    ; restore flush status and caller's U, then return

_fflush             pshs      u         ; preserve caller's U register
                    ldu       4,s       ; load FILE pointer
                    lbeq      badexit   ; reject null stream pointers
                    ldd       6,u       ; load FILE flags word
                    andb      #_ERR|_WRITE ; require writable stream with no error set
                    cmpb      #_WRITE   ; compare against clean writable state
                    lbne      badexit   ; reject streams that cannot be flushed
                    anda      #$80      ; test initialized bit in high byte
                    bne       finited   ; skip setup if buffering is already initialized
                    pshs      u         ; pass FILE pointer to setbase
                    lbsr      _setbase  ; allocate/setup stream buffering state
                    leas      2,s       ; discard staged FILE pointer
finited             pshs      u         ; pass FILE pointer to internal flush helper
                    bsr       _flush    ; write any buffered output and reset pointers
                    leas      2,s       ; discard staged FILE pointer
                    puls      u,pc      ; restore U and return helper status

_flush              pshs      u         ; preserve caller's U register
                    ldu       4,s       ; load FILE pointer
                    leas      -4,s      ; reserve local word/count scratch space
                    lda       6,u       ; load high byte of FILE flags
                    anda      #1        ; test _WRITTEN bit
                    bne       L012c     ; skip seek correction once stream is in write mode
                    ldd       ,u        ; load current buffer pointer
                    cmpd      4,u       ; compare against buffer end pointer
                    beq       L012c     ; no correction needed when buffer is already full
                    clra                ; build zero offset for ftell/seek correction
                    clrb                ; build zero offset for ftell/seek correction
                    pshs      d         ; stage zero long low word
                    pshs      u         ; stage FILE pointer for ftell
                    lbsr      _ftell    ; compute current buffered file position
                    leas      2,s       ; discard staged FILE pointer
                    ldd       2,x       ; fetch low word of current file position
                    pshs      d         ; stage low word for lseek
                    ldd       ,x        ; fetch high word of current file position
                    pshs      d         ; stage high word for lseek
                    ldd       8,u       ; load underlying path number
                    pshs      d         ; stage path number for lseek
                    lbsr      _lseek    ; synchronize OS-9 file position with buffer state
                    leas      8,s       ; discard staged lseek arguments
L012c               ldd       ,u        ; load current buffer pointer
                    subd      2,u       ; compute buffered byte count as ptr-base
                    std       2,s       ; save pending-byte count in local scratch
                    lbeq      L0194     ; nothing to flush if the buffer is empty
                    ldd       6,u       ; reload FILE flags word
                    anda      #1        ; test _WRITTEN bit
                    lbeq      L0194     ; do not flush if buffer only contains read data
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
                    bne       L0185     ; branch if the device write failed
                    ldd       2,s       ; fetch pending-byte count
                    subd      -4,s      ; subtract amount written this iteration
                    std       2,s       ; update pending-byte count
                    ldd       ,u        ; reload current buffer pointer
                    addd      -4,s      ; advance by amount written this iteration
_flush3             std       ,u        ; save updated current buffer pointer
                    ldd       2,s       ; fetch remaining byte count
                    bne       _flush2   ; loop until all SCF bytes are written
                    bra       L0194     ; finalize successful flush

_flushrbf           leax      2,s       ; point X at pending-byte count
                    pshs      x         ; pass pointer-to-count
                    ldd       2,u       ; load buffer base pointer
                    pshs      d         ; pass data pointer
                    ldd       8,u       ; load underlying path number
                    pshs      d         ; pass path number
                    lbsr      __os_write ; write buffered block to non-SCF device
                    leas      6,s       ; discard staged write arguments
                    bne       L0185     ; branch if the block write failed
                    bra       L0194     ; finalize successful flush
L0185               ldb       7,u       ; load low byte of FILE flags
                    orb       #_ERR     ; mark stream as having encountered an error
                    stb       7,u       ; save updated error flag
                    ldd       4,u       ; load buffer end pointer
                    std       ,u        ; move current pointer to end to prevent reuse
                    ldd       #-1       ; return EOF on flush failure
                    bra       L01a4     ; share final stack teardown

L0194               lda       6,u       ; load high byte of FILE flags
                    ora       #1        ; mark stream as being in written/update state
                    sta       6,u       ; save updated write-state flag
                    ldd       2,u       ; load buffer base pointer
                    std       ,u        ; reset current pointer back to buffer base
                    addd      11,u      ; compute buffer end as base + buffer size
                    std       4,u       ; save refreshed buffer end pointer
                    clra                ; return zero on successful flush
                    clrb                ; return zero on successful flush
L01a4               leas      4,s       ; discard local scratch space
                    puls      u,pc      ; restore U and return

                    endsect             ; end code section
