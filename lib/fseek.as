_fseek              EXPORT              ; export buffered seek helper
_rewind             EXPORT              ; export rewind helper
_ftell              EXPORT              ; export buffered tell helper

_setbase            EXTERNAL            ; stdio buffer initializer
_fflush             EXTERNAL            ; stream flush helper
_lmove              EXTERNAL            ; long move helper
_lsub               EXTERNAL            ; long subtract helper
_litol              EXTERNAL            ; int-to-long helper
_lcmpr              EXTERNAL            ; long compare helper
_lneg               EXTERNAL            ; long negate helper
_ladd               EXTERNAL            ; long add helper
_flacc              EXTERNAL            ; shared long return accumulator
_lseek              EXTERNAL            ; absolute long seek helper

_READ               equ       $01       ; FILE open-for-read flag
_WRITE              equ       $02       ; FILE open-for-write flag
_EOF                equ       $10       ; FILE end-of-file flag
_ERR                equ       $20       ; FILE error flag

                    section   code      ; begin code section

_fseek              pshs      u         ; preserve caller's U register
                    ldu       6,s       ; load FILE pointer after hidden long-return pointer
                    leas      -6,s      ; reserve scratch space for long temporaries
                    lbeq      L0114     ; reject null stream pointers
                    ldd       6,u       ; load FILE flags word
                    bitb      #_READ|_WRITE ; require an open stream in read or write mode
                    lbeq      L0114     ; fail if stream is not active
                    bita      #$80      ; test initialized bit in high byte
                    bne       L0020     ; skip initialization if stream is already set up
                    pshs      u         ; pass FILE pointer to setbase
                    lbsr      _setbase  ; allocate/setup stream buffering state
                    leas      2,s       ; discard staged FILE pointer
                    lbra      L00db     ; seed seek scratch before real reposition path
L0020               lda       6,u       ; reload high byte so the _WRITTEN test sees the full flag byte
                    anda      #$01      ; isolate _WRITTEN from all other high-byte flags
                    beq       L003a     ; branch if stream is currently in read mode
                    pshs      u         ; pass FILE pointer to fflush
                    lbsr      _fflush   ; flush pending output before moving the file position
                    leas      2,s       ; discard staged FILE pointer
                    ldb       7,u       ; refresh low-byte flags after fflush
                    andb      #_ERR     ; preserve only a possible flush error marker
                    lbne      L0114     ; treat flush failure as a failed seek
                    lda       6,u       ; reload high byte of FILE flags
                    anda      #^$01     ; clear _WRITTEN bit after flush
                    sta       6,u       ; save cleaned update-state flag
                    ldd       2,u       ; load buffer base pointer
                    addd      11,u      ; recompute buffer end as base + size
                    std       4,u       ; restore end pointer after flush reset
                    lbra      L00db     ; seed seek scratch before real reposition path
L003a               ldd       ,u        ; load current buffer pointer
                    cmpd      4,u       ; compare against buffer end pointer
                    lbhs      L00db     ; seed seek scratch before real reposition path
                    leax      2,s       ; point X at local scratch long
                    pshs      x         ; stage destination pointer for long move
                    leax      14,s      ; point X at requested seek offset argument
                    lbsr      _lmove    ; copy requested offset into local scratch
                    ldx       18,s      ; load whence selector
                    beq       L0059     ; branch for SEEK_SET relative adjustment
                    cmpx      #1        ; test SEEK_CUR case
                    beq       L0072     ; branch for current-position adjustment
                    lbra      L00c8     ; SEEK_END needs extra compensation path
L0059               leax      2,s       ; point X at local scratch long
                    pshs      x         ; stage destination pointer for long move
                    ldd       2,x       ; fetch scratch low word
                    pshs      d         ; stage low word for long subtraction
                    ldd       ,x        ; fetch scratch high word
                    pshs      d         ; stage high word for long subtraction
                    leax      _flacc,y  ; provide hidden long return slot for ftell
                    pshs      x,u       ; pass hidden return slot and FILE pointer to ftell
                    lbsr      _ftell    ; compute current buffered file position
                    leas      4,s       ; discard staged hidden return slot and FILE pointer
                    leax      _flacc,y  ; point X at the returned long value
                    lbsr      _lsub     ; subtract current position from requested absolute target
                    lbsr      _lmove    ; store adjusted offset back into local scratch
L0072               ldd       11,u      ; load buffer size
                    lbsr      _litol    ; convert buffer size to long in _flacc
                    ldd       2,x       ; fetch low word of buffer-size long
                    pshs      d         ; stage low word for compare
                    ldd       ,x        ; fetch high word of buffer-size long
                    pshs      d         ; stage high word for compare
                    leax      6,s       ; point X at requested/adjusted offset scratch
                    ldd       2,x       ; fetch scratch low word
                    pshs      d         ; stage low word for compare
                    ldd       ,x        ; fetch scratch high word
                    pshs      d         ; stage high word for compare
                    leax      L011f,pcr ; point X at zero long constant
                    lbsr      _lcmpr    ; compare requested offset against zero
                    bge       L0099     ; keep sign for non-negative offset
                    leax      6,s       ; point X back at offset scratch
                    lbsr      _lneg     ; negate negative offset for magnitude compare
                    bra       L009b     ; continue with normalized magnitude
L0099               leax      6,s       ; point X at non-negative offset scratch
L009b               lbsr      _lcmpr    ; compare offset magnitude against buffer size
                    blt       L00bf     ; skip optimization if offset reaches beyond buffer
                    ldd       4,s       ; load low word of offset scratch
                    addd      ,u        ; add offset to current buffer pointer
                    std       ,s        ; save tentative new buffer pointer
                    cmpd      2,u       ; ensure new pointer does not precede buffer base
                    bcs       L00bf     ; fall back to real seek if it underflows base
                    ldd       ,s        ; reload tentative new buffer pointer
                    cmpd      4,u       ; ensure new pointer stays before buffer end
                    bcc       L00bf     ; fall back to real seek if it reaches/passes end
                    ldd       ,s        ; reload tentative new buffer pointer
                    std       ,u        ; update current buffer pointer only
                    ldb       7,u       ; load low byte of FILE flags
                    andb      #^_EOF    ; clear EOF flag after successful reposition
                    stb       7,u       ; save updated flag byte
                    lbra      L0119     ; return success without touching the file descriptor
L00bf               ldd       18,s      ; load whence selector
                    cmpd      #1        ; test SEEK_CUR case
                    bne       L00e1     ; only SEEK_CUR needs read-buffer compensation
L00c8               leax      14,s      ; point X at original seek offset argument
                    pshs      x         ; stage destination pointer for long move
                    ldd       2,x       ; fetch original low word
                    pshs      d         ; stage low word for subtraction
                    ldd       ,x        ; fetch original high word
                    pshs      d         ; stage high word for subtraction
                    ldd       4,u       ; load buffer end pointer
                    subd      ,u        ; compute unread bytes left in buffer
                    lbsr      _litol    ; convert unread-byte count to long
                    lbsr      _lsub     ; subtract unread bytes from requested offset
                    lbsr      _lmove    ; store corrected offset back into local scratch
                    bra       L00e1     ; use corrected scratch without reseeding it
L00db               ldd       14,s      ; copy original offset high word into scratch when no adjustment ran
                    std       2,s       ; save scratch high word
                    ldd       16,s      ; copy original offset low word into scratch when no adjustment ran
                    std       4,s       ; save scratch low word
L00e1               ldd       4,u       ; load buffer end pointer
L00e3               std       ,u        ; move current pointer to buffer end
L00e5               ldb       7,u       ; load low byte of FILE flags
                    andb      #^_EOF    ; clear EOF flag before real reposition
                    stb       7,u       ; save updated flag byte
                    ldd       18,s      ; load whence selector
                    pshs      d         ; stage whence for _lseek
                    leax      16,s      ; point X at corrected seek offset scratch after pushing whence
                    ldd       2,x       ; fetch corrected low word
                    pshs      d         ; stage low word for _lseek
                    ldd       ,x        ; fetch corrected high word
                    pshs      d         ; stage high word for _lseek
                    ldd       8,u       ; load underlying path number
                    pshs      d         ; stage path number for _lseek
                    leax      _flacc,y  ; provide hidden long return slot for _lseek
                    pshs      x         ; stage hidden return pointer
                    lbsr      _lseek    ; perform absolute reposition through low-level helper
                    leas      10,s      ; discard staged _lseek arguments
                    ldd       2,x       ; fetch returned low word from _flacc pointer
                    pshs      d         ; stage low word for compare against -1
                    ldd       ,x        ; fetch returned high word from _flacc pointer
                    pshs      d         ; stage high word for compare against -1
                    leax      L0123,pcr ; point X at long -1 constant
                    lbsr      _lcmpr    ; check whether _lseek signaled failure
                    bne       L0119     ; non--1 return means seek succeeded
L0114               ldd       #-1       ; return EOF-style failure for unsuccessful seek
                    bra       L011a     ; share hidden-result store path
L0119               clra                ; return zero on success
                    clrb                ; return zero on success
L011a               ldx       10,s      ; load hidden long-return pointer
                    std       0,x       ; store high word of return value
                    std       2,x       ; store low word of return value
L011b               leas      6,s       ; discard local scratch space
                    puls      u,pc      ; restore U and return
L011f               fdb       $0000,$0000 ; 32-bit zero constant for long compares
L0123               fdb       $FFFF,$FFFF ; 32-bit -1 constant for error compare

_rewind             clra                ; build zero seek offset high byte
                    clrb                ; build zero seek offset low byte
                    pshs      d         ; stage whence 0
                    pshs      d         ; stage zero offset low word
                    pshs      d         ; stage zero offset high word
                    ldd       8,s       ; reload FILE pointer
                    pshs      d         ; stage FILE pointer
                    leax      _flacc,y  ; provide hidden long return slot for fseek
                    pshs      x         ; stage hidden return pointer
                    lbsr      _fseek    ; seek to offset 0 from start of file
                    leas      10,s      ; discard staged arguments
                    rts                 ; rewind has no explicit return value

_ftell              pshs      u         ; preserve caller's U register
                    ldu       6,s       ; load FILE pointer after hidden long-return pointer
                    beq       L0143     ; reject null stream pointers
                    ldd       6,u       ; load FILE flags word
                    andb      #_READ|_WRITE ; require an open readable/writable stream
                    bne       L0150     ; continue if stream is active
L0143               ldx       4,s       ; load hidden long-return pointer
                    ldd       #-1       ; prepare long -1 error result
                    std       ,x        ; store high word of -1
                    std       2,x       ; store low word of -1
                    puls      u,pc      ; restore U and return
L0150               anda      #$80      ; test initialized bit in high byte
                    bne       L015b     ; skip setup if stream is already initialized
                    pshs      u         ; pass FILE pointer to setbase
                    lbsr      _setbase  ; allocate/setup stream buffering state
                    leas      2,s       ; discard staged FILE pointer
L015b               ldd       #1        ; build SEEK_CUR selector
                    pshs      d         ; stage whence for _lseek
                    clrb                ; build zero offset low byte
                    pshs      d         ; stage zero offset low word
                    pshs      d         ; stage zero offset high word
                    ldd       8,u       ; load underlying path number
                    pshs      d         ; stage path number for _lseek
                    leax      _flacc,y  ; provide hidden long return slot for _lseek
                    pshs      x         ; stage hidden return pointer
                    lbsr      _lseek    ; fetch current descriptor position through low-level helper
                    leas      10,s      ; discard staged _lseek arguments
                    ldd       2,x       ; fetch returned low word from _flacc pointer
                    pshs      d         ; stage low word for adjusted total
                    ldd       ,x        ; fetch returned high word from _flacc pointer
                    pshs      d         ; stage high word for adjusted total
                    lda       6,u       ; load high byte of FILE flags
                    anda      #$01      ; test _WRITTEN state
                    beq       L0180     ; read mode uses buffer end for unread-byte correction
                    ldd       2,u       ; write mode uses buffer base for unwritten-byte correction
                    bra       L0182     ; share subtraction path
L0180               ldd       4,u       ; read mode uses current buffer end pointer
L0182               pshs      d         ; stage reference pointer for subtraction
                    ldd       ,u        ; load current buffer pointer
                    subd      ,s++      ; compute buffered delta against reference pointer
                    lbsr      _litol    ; convert buffered delta to long in _flacc
                    lbsr      _ladd     ; add buffered delta to descriptor position
                    ldx       4,s       ; load hidden long-return pointer
                    ldd       _flacc,y  ; fetch resulting high word
                    std       0,x       ; store high word through hidden pointer
                    ldd       _flacc+2,y ; fetch resulting low word
                    std       2,x       ; store low word through hidden pointer
                    puls      u,pc      ; restore U and return

                    endsect             ; end code section
