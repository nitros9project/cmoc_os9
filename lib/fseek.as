                    use       ../include/stdio.d ; shared FILE layout and seek constants

_fseek              EXPORT    ;         export buffered seek helper
_rewind             EXPORT    ;         export rewind helper
_ftell              EXPORT    ;         export buffered tell helper

_setbase            EXTERNAL  ;         stdio buffer initializer
_fflush             EXTERNAL  ;         stream flush helper
_lmove              EXTERNAL  ;         long move helper
_lsub               EXTERNAL  ;         long subtract helper
_litol              EXTERNAL  ;         int-to-long helper
_lcmpr              EXTERNAL  ;         long compare helper
_lneg               EXTERNAL  ;         long negate helper
_ladd               EXTERNAL  ;         long add helper
_flacc              EXTERNAL  ;         shared long return accumulator
_lseek              EXTERNAL  ;         absolute long seek helper

                    section   code      ; begin code section

_fseek:
stk_fseek_entry_saved_u equ       0         ; saved U before local scratch allocation
stk_fseek_entry_ret equ       2         ; caller return address before local scratch allocation
stk_fseek_entry_resultp equ       4         ; hidden long return pointer before local scratch allocation
stk_fseek_entry_stream equ       6         ; FILE * argument before local scratch allocation
stk_fseek_entry_pos equ       8         ; long seek offset before local scratch allocation
stk_fseek_entry_whence equ       12        ; seek origin before local scratch allocation
stk_fseek_local_size equ       6         ; bytes reserved for local scratch
stk_fseek_tmp_ptr   equ       0         ; temporary 16-bit pointer after local scratch allocation
stk_fseek_offset    equ       2         ; corrected 32-bit seek offset after local scratch allocation
stk_fseek_saved_u   equ       6         ; saved U after local scratch allocation
stk_fseek_ret       equ       8         ; caller return address after local scratch allocation
stk_fseek_resultp   equ       10        ; hidden long return pointer after local scratch allocation
stk_fseek_stream    equ       12        ; FILE * argument after local scratch allocation
stk_fseek_pos       equ       14        ; original long seek offset after local scratch allocation
stk_fseek_whence    equ       18        ; seek origin after local scratch allocation
                    pshs      u         ; preserve caller's U register
                    ldu       stk_fseek_entry_stream,s ; load FILE pointer after hidden long-return pointer
                    leas      -stk_fseek_local_size,s ; reserve scratch space for long temporaries
                    lbeq      fseek_fail ; reject null stream pointers
                    ldd       FILE_FLAG,u ; load FILE flags word
                    bitb      #_READ|_WRITE ; require an open stream in read or write mode
                    lbeq      fseek_fail ; fail if stream is not active
                    bita      #_INIT_HIGH ; test initialized bit in high byte
                    bne       fseek_stream_ready ; skip initialization if stream is already set up
                    pshs      u         ; pass FILE pointer to setbase
                    lbsr      _setbase  ; allocate/setup stream buffering state
                    leas      2,s       ; discard staged FILE pointer
                    lbra      fseek_seed_offset ; seed seek scratch before real reposition path
fseek_stream_ready  lda       FILE_FLAG,u ; reload high byte so the _WRITTEN test sees the full flag byte
                    bita      #_WRITTEN_HIGH ; test _WRITTEN without destroying other high-byte flags
                    beq       fseek_read_mode ; branch if stream is currently in read mode
                    pshs      u         ; pass FILE pointer to fflush
                    lbsr      _fflush   ; flush pending output before moving the file position
                    leas      2,s       ; discard staged FILE pointer
                    ldb       FILE_FLAG+1,u ; refresh low-byte flags after fflush
                    andb      #_ERR     ; preserve only a possible flush error marker
                    lbne      fseek_fail ; treat flush failure as a failed seek
                    lda       FILE_FLAG,u ; reload high byte of FILE flags
                    anda      #^_WRITTEN_HIGH ; clear _WRITTEN bit after flush, preserve append/init
                    sta       FILE_FLAG,u ; save cleaned update-state flag
                    ldd       FILE_BASE,u ; load buffer base pointer
                    addd      FILE_BUFSIZ,u ; recompute buffer end as base + size
                    std       FILE_END,u ; restore end pointer after flush reset
                    lbra      fseek_seed_offset ; seed seek scratch before real reposition path
fseek_read_mode     ldd       FILE_PTR,u ; load current buffer pointer
                    cmpd      FILE_END,u ; compare against buffer end pointer
                    lbhs      fseek_seed_offset ; seed seek scratch before real reposition path
                    leax      stk_fseek_offset,s ; point X at local scratch long
                    pshs      x         ; stage destination pointer for long move
                    leax      stk_fseek_pos,s ; point X at requested seek offset argument
                    lbsr      _lmove    ; copy requested offset into local scratch
                    ldx       stk_fseek_whence,s ; load whence selector
                    beq       fseek_adjust_set ; branch for SEEK_SET relative adjustment
                    cmpx      #SEEK_CUR ; test SEEK_CUR case
                    beq       fseek_check_buffer ; branch for current-position adjustment
                    lbra      fseek_compensate_unread ; SEEK_END needs extra compensation path
fseek_adjust_set    leax      stk_fseek_offset,s ; point X at local scratch long
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
fseek_check_buffer  ldd       FILE_BUFSIZ,u ; load buffer size
                    lbsr      _litol    ; convert buffer size to long in _flacc
                    ldd       2,x       ; fetch low word of buffer-size long
                    pshs      d         ; stage low word for compare
                    ldd       ,x        ; fetch high word of buffer-size long
                    pshs      d         ; stage high word for compare
                    leax      stk_fseek_offset+4,s ; stacked buffer-size long shifts offset scratch by four bytes
                    ldd       2,x       ; fetch scratch low word
                    pshs      d         ; stage low word for compare
                    ldd       ,x        ; fetch scratch high word
                    pshs      d         ; stage high word for compare
                    leax      fseek_long_zero,pcr ; point X at zero long constant
                    lbsr      _lcmpr    ; compare requested offset against zero
                    bge       fseek_nonnegative_offset ; keep sign for non-negative offset
                    leax      stk_fseek_offset+4,s ; stacked buffer-size long shifts offset scratch by four bytes
                    lbsr      _lneg     ; negate negative offset for magnitude compare
                    bra       fseek_compare_magnitude ; continue with normalized magnitude
fseek_nonnegative_offset leax      stk_fseek_offset+4,s ; stacked buffer-size long shifts offset scratch by four bytes
fseek_compare_magnitude lbsr      _lcmpr    ; compare offset magnitude against buffer size
                    blt       fseek_real_seek_needed ; skip optimization if offset reaches beyond buffer
                    ldd       stk_fseek_offset+2,s ; load low word of offset scratch
                    addd      FILE_PTR,u ; add offset to current buffer pointer
                    std       stk_fseek_tmp_ptr,s ; save tentative new buffer pointer
                    cmpd      FILE_BASE,u ; ensure new pointer does not precede buffer base
                    bcs       fseek_real_seek_needed ; fall back to real seek if it underflows base
                    ldd       stk_fseek_tmp_ptr,s ; reload tentative new buffer pointer
                    cmpd      FILE_END,u ; ensure new pointer stays before buffer end
                    bcc       fseek_real_seek_needed ; fall back to real seek if it reaches/passes end
                    ldd       stk_fseek_tmp_ptr,s ; reload tentative new buffer pointer
                    std       FILE_PTR,u ; update current buffer pointer only
                    ldb       FILE_FLAG+1,u ; load low byte of FILE flags
                    andb      #^_EOF    ; clear EOF flag after successful reposition
                    stb       FILE_FLAG+1,u ; save updated flag byte
                    lbra      fseek_success ; return success without touching the file descriptor
fseek_real_seek_needed ldd       stk_fseek_whence,s ; load whence selector
                    cmpd      #SEEK_CUR ; test SEEK_CUR case
                    bne       fseek_real_seek ; only SEEK_CUR needs read-buffer compensation
fseek_compensate_unread leax      stk_fseek_pos,s ; point X at original seek offset argument
                    pshs      x         ; stage destination pointer for long move
                    ldd       2,x       ; fetch original low word
                    pshs      d         ; stage low word for subtraction
                    ldd       ,x        ; fetch original high word
                    pshs      d         ; stage high word for subtraction
                    ldd       FILE_END,u ; load buffer end pointer
                    subd      FILE_PTR,u ; compute unread bytes left in buffer
                    lbsr      _litol    ; convert unread-byte count to long
                    lbsr      _lsub     ; subtract unread bytes from requested offset
                    lbsr      _lmove    ; store corrected offset back into local scratch
                    bra       fseek_real_seek ; use corrected scratch without reseeding it
fseek_seed_offset   ldd       stk_fseek_pos,s ; copy original offset high word into scratch when no adjustment ran
                    std       stk_fseek_offset,s ; save scratch high word
                    ldd       stk_fseek_pos+2,s ; copy original offset low word into scratch when no adjustment ran
                    std       stk_fseek_offset+2,s ; save scratch low word
fseek_real_seek     ldd       FILE_END,u ; load buffer end pointer
fseek_end_buffer    std       FILE_PTR,u ; move current pointer to buffer end
fseek_clear_eof     ldb       FILE_FLAG+1,u ; load low byte of FILE flags
                    andb      #^_EOF    ; clear EOF flag before real reposition
                    stb       FILE_FLAG+1,u ; save updated flag byte
                    ldd       stk_fseek_whence,s ; load whence selector
                    pshs      d         ; stage whence for _lseek
                    leax      stk_fseek_pos+2,s ; staged whence shifts original/corrected offset reference by two bytes
                    ldd       2,x       ; fetch corrected low word
                    pshs      d         ; stage low word for _lseek
                    ldd       ,x        ; fetch corrected high word
                    pshs      d         ; stage high word for _lseek
                    ldd       FILE_FD,u ; load underlying path number
                    pshs      d         ; stage path number for _lseek
                    leax      _flacc,y  ; provide hidden long return slot for _lseek
                    pshs      x         ; stage hidden return pointer
                    lbsr      _lseek    ; perform absolute reposition through low-level helper
                    leas      10,s      ; discard staged _lseek arguments
                    ldd       2,x       ; fetch returned low word from _flacc pointer
                    pshs      d         ; stage low word for compare against -1
                    ldd       ,x        ; fetch returned high word from _flacc pointer
                    pshs      d         ; stage high word for compare against -1
                    leax      fseek_long_minus_one,pcr ; point X at long -1 constant
                    lbsr      _lcmpr    ; check whether _lseek signaled failure
                    bne       fseek_success ; non--1 return means seek succeeded
fseek_fail          ldd       #-1       ; return EOF-style failure for unsuccessful seek
                    bra       fseek_store_result ; share hidden-result store path
fseek_success       clra                ; return zero on success
                    clrb                ; return zero on success
fseek_store_result  ldx       stk_fseek_resultp,s ; load hidden long-return pointer
                    std       0,x       ; store high word of return value
                    std       2,x       ; store low word of return value
fseek_done          leas      stk_fseek_local_size,s ; discard local scratch space
                    puls      u,pc      ; restore U and return
fseek_long_zero     fdb       $0000,$0000 ; 32-bit zero constant for long compares
fseek_long_minus_one fdb       $FFFF,$FFFF ; 32-bit -1 constant for error compare

_rewind:
stk_rewind_ret      equ       0         ; caller return address
stk_rewind_stream   equ       2         ; FILE * argument
                    clra                ; build zero seek offset high byte
                    clrb                ; build zero seek offset low byte
                    pshs      d         ; stage SEEK_SET whence
                    pshs      d         ; stage zero offset low word
                    pshs      d         ; stage zero offset high word
                    ldd       stk_rewind_stream+6,s ; staged whence and long offset shift FILE pointer by six bytes
                    pshs      d         ; stage FILE pointer
                    leax      _flacc,y  ; provide hidden long return slot for fseek
                    pshs      x         ; stage hidden return pointer
                    lbsr      _fseek    ; seek to offset 0 from start of file
                    leas      10,s      ; discard staged arguments
                    rts                 ; rewind has no explicit return value

_ftell:
stk_ftell_saved_u   equ       0         ; saved U after entry prologue
stk_ftell_ret       equ       2         ; caller return address after entry prologue
stk_ftell_resultp   equ       4         ; hidden long return pointer after entry prologue
stk_ftell_stream    equ       6         ; FILE * argument after entry prologue
                    pshs      u         ; preserve caller's U register
                    ldu       stk_ftell_stream,s ; load FILE pointer after hidden long-return pointer
                    beq       ftell_fail ; reject null stream pointers
                    ldd       FILE_FLAG,u ; load FILE flags word
                    andb      #_READ|_WRITE ; require an open readable/writable stream
                    bne       ftell_stream_active ; continue if stream is active
ftell_fail          ldx       stk_ftell_resultp,s ; load hidden long-return pointer
                    ldd       #-1       ; prepare long -1 error result
                    std       ,x        ; store high word of -1
                    std       2,x       ; store low word of -1
                    puls      u,pc      ; restore U and return
ftell_stream_active anda      #_INIT_HIGH ; test initialized bit in high byte
                    bne       ftell_query_position ; skip setup if stream is already initialized
                    pshs      u         ; pass FILE pointer to setbase
                    lbsr      _setbase  ; allocate/setup stream buffering state
                    leas      2,s       ; discard staged FILE pointer
ftell_query_position ldd       #SEEK_CUR ; build SEEK_CUR selector
                    pshs      d         ; stage whence for _lseek
                    clrb                ; build zero offset low byte
                    pshs      d         ; stage zero offset low word
                    pshs      d         ; stage zero offset high word
                    ldd       FILE_FD,u ; load underlying path number
                    pshs      d         ; stage path number for _lseek
                    leax      _flacc,y  ; provide hidden long return slot for _lseek
                    pshs      x         ; stage hidden return pointer
                    lbsr      _lseek    ; fetch current descriptor position through low-level helper
                    leas      10,s      ; discard staged _lseek arguments
                    ldd       2,x       ; fetch returned low word from _flacc pointer
                    pshs      d         ; stage low word for adjusted total
                    ldd       ,x        ; fetch returned high word from _flacc pointer
                    pshs      d         ; stage high word for adjusted total
                    lda       FILE_FLAG,u ; load high byte of FILE flags
                    anda      #_WRITTEN_HIGH ; test _WRITTEN state
                    beq       ftell_read_reference ; read mode uses buffer end for unread-byte correction
                    ldd       FILE_BASE,u ; write mode uses buffer base for unwritten-byte correction
                    bra       ftell_apply_delta ; share subtraction path
ftell_read_reference ldd       FILE_END,u ; read mode uses current buffer end pointer
ftell_apply_delta   pshs      d         ; stage reference pointer for subtraction
                    ldd       FILE_PTR,u ; load current buffer pointer
                    subd      ,s++      ; compute buffered delta against reference pointer
                    lbsr      _litol    ; convert buffered delta to long in _flacc
                    lbsr      _ladd     ; add buffered delta to descriptor position
                    ldx       stk_ftell_resultp,s ; load hidden long-return pointer
                    ldd       _flacc,y  ; fetch resulting high word
                    std       0,x       ; store high word through hidden pointer
                    ldd       _flacc+2,y ; fetch resulting low word
                    std       2,x       ; store low word through hidden pointer
                    puls      u,pc      ; restore U and return

                    endsect   ;         end code section
