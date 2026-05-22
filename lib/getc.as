                    use       ../include/stdio.d ; shared FILE layout and flag constants

                    section   code      ; begin code section

_getc               EXPORT    ;         export this symbol
_ungetc             EXPORT    ;         export this symbol
_getw               EXPORT    ;         export this symbol

__iob               EXTERN    ;         import FILE table base

_getc:
stk_getc_saved_u    equ       0         ; saved U after entry prologue
stk_getc_read_count equ       -2        ; temporary read count after I/O args are discarded
stk_getc_ret        equ       2         ; caller return address after entry prologue
stk_getc_stream     equ       4         ; FILE * stream argument after entry prologue
                    pshs      u         ; preserve caller U while using it as FILE pointer
                    ldu       stk_getc_stream,s ; load FILE * argument
                    beq       getc_return_eof ; NULL streams fail with EOF
                    lda       FILE_FLAG,u ; read high byte of FILE flags
                    anda      #_WRITTEN_HIGH ; stream was written in update mode?
                    beq       getc_buffer_ready ; ordinary read stream can continue
                    ldx       FILE_PTR,u ; load current buffer pointer
                    cmpx      FILE_END,u ; reads are allowed only after repositioning to the end
                    bne       getc_return_eof ; active buffered write state cannot be read
                    lda       FILE_FLAG,u ; reload high byte of FILE flags
                    anda      #^_WRITTEN_HIGH ; clear write-state after reposition
                    sta       FILE_FLAG,u ; save updated high flag byte
getc_buffer_ready   ldx       FILE_PTR,u ; load next buffered character pointer
                    cmpx      FILE_END,u ; is buffered input still available?
                    bcc       getc_refill_buffer ; refill when pointer reached the end
getc_consume_buffered
                    ldb       ,x+       ; fetch buffered byte and advance FILE pointer
getc_store_ptr_return
                    stx       FILE_PTR,u ; save updated FILE pointer
                    clra                ; clear A
                    puls      u,pc      ; restore registers and return

_ungetc:
stk_ungetc_saved_u  equ       0         ; saved U after entry prologue
stk_ungetc_ret      equ       2         ; caller return address after entry prologue
stk_ungetc_char     equ       4         ; character to push back after entry prologue
stk_ungetc_stream   equ       6         ; FILE * stream argument after entry prologue
                    pshs      u         ; preserve caller U while using it as FILE pointer
                    ldu       stk_ungetc_stream,s ; load FILE * argument
                    beq       getc_return_eof ; NULL streams fail with EOF
                    ldb       FILE_FLAG+1,u ; read low byte of FILE flags
                    andb      #_READ    ; pushback requires a readable stream
                    beq       getc_return_eof ; non-readable streams fail with EOF
                    ldd       stk_ungetc_char,s ; load candidate character
                    cmpd      #-1       ; EOF cannot be pushed back
                    beq       getc_return_eof ; reject EOF
                    ldx       FILE_PTR,u ; load current FILE pointer
                    cmpx      FILE_BASE,u ; cannot push before the buffer base
                    beq       getc_return_eof ; no pushback room remains
                    stb       ,-x       ; store character in the previous buffer slot
                    bra       getc_store_ptr_return ; save decremented FILE pointer and return it

_getw:
stk_getw_saved_u    equ       0         ; saved U after entry prologue
stk_getw_ret        equ       2         ; caller return address after entry prologue
stk_getw_stream     equ       4         ; FILE * stream argument after entry prologue
stk_getw_first_byte equ       3         ; low byte saved beside staged FILE * argument
                    pshs      u         ; preserve caller U while staging FILE pointer
                    ldu       stk_getw_stream,s ; load FILE * argument
                    pshs      u,pc      ; stage FILE * plus a two-byte scratch slot
                    bsr       _getc     ; read the high byte
                    std       stk_getw_first_byte-1,s ; save first byte in scratch slot
                    cmpd      #-1       ; EOF on first byte?
                    beq       getw_done ; return EOF
                    bsr       _getc     ; read the low byte
                    cmpd      #-1       ; EOF on second byte?
                    beq       getw_done ; return EOF
                    lda       stk_getw_first_byte,s ; combine first byte with second byte
getw_done           leas      4,s       ; discard staged FILE pointer and scratch slot
                    puls      u,pc      ; restore registers and return

getc_mark_eof       ldb       #_EOF     ; prepare EOF flag for FILE status
                    bra       getc_set_status ; merge status and return EOF
getc_mark_error     ldb       #_ERR     ; prepare ERR flag for FILE status
getc_set_status     orb       FILE_FLAG+1,u ; merge new status with low FILE flags
                    stb       FILE_FLAG+1,u ; save updated low flag byte
getc_return_eof     ldd       #-1       ; return EOF
                    puls      u,pc      ; restore registers and return

getc_refill_buffer  ldd       FILE_FLAG,u ; load both FILE flag bytes
                    anda      #_INIT_HIGH ; isolate initialized-buffer flag
                    andb      #_READ|_EOF|_ERR ; keep readable, EOF, and error state
                    bitb      #_EOF|_ERR ; reject streams already marked EOF or ERR
                    bne       getc_return_eof ; status already prevents more reads
                    bitb      #_READ    ; require read permission, but allow update streams too
                    beq       getc_return_eof ; stream is not readable
                    cmpa      #_INIT_HIGH ; has the stream buffer been initialized?
                    beq       getc_buffer_initialized ; skip setup when initialized
                    pshs      u         ; pass FILE * to _setbase()
_setbase            EXTERN    ;         import FILE buffer initializer
                    lbsr      _setbase  ; long branch to subroutine to _setbase
                    leas      2,s       ; adjust S using 2,s
getc_buffer_initialized
                    leax      __iob,y   ; point X at stdin FILE entry
                    pshs      x         ; stage stdin pointer for comparison
                    cmpu      ,s++      ; is this read from stdin?
                    bne       getc_read_from_stream ; only stdin can trigger stdout flush
                    ldb       FILE_FLAG+1,u ; load low FILE flags
                    andb      #_SCF     ; test for interactive SCF input
                    beq       getc_read_from_stream ; non-SCF stdin does not flush stdout
                    leax      __iob+FILE_SIZE,y ; point X at stdout FILE entry
                    pshs      x         ; pass stdout to _fflush()
_fflush             EXTERN    ;         import FILE flush helper
                    lbsr      _fflush   ; long branch to subroutine to _fflush
                    leas      2,s       ; adjust S using 2,s
getc_read_from_stream
                    ldb       FILE_FLAG+1,u ; load low FILE flags
                    andb      #_BIGBUF  ; does the FILE own a real input buffer?
                    beq       getc_single_byte ; use the one-byte save area for unbuffered streams
                    ldd       FILE_BUFSIZ,u ; load buffer size
                    pshs      d         ; pass read count
                    ldx       FILE_BASE,u ; load buffer base
                    ldd       FILE_FD,u ; load OS-9 path number
                    pshs      d,x       ; pass path and buffer pointer
                    ldb       FILE_FLAG+1,u ; reload low FILE flags
                    andb      #_SCF     ; SCF paths use line input
                    beq       getc_call_read ; RBF paths use raw read
_readln             EXTERN    ;         import OS-9 line-read wrapper
                    lbsr      _readln   ; long branch to subroutine to _readln
                    bra       getc_after_read ; normalize the returned byte count
getc_single_byte    ldd       #1        ; request one byte
                    pshs      d         ; pass read count
                    leax      FILE_SAVE,u ; use FILE._save as the one-byte buffer
                    stx       FILE_BASE,u ; make the save byte the active buffer base
                    ldd       FILE_FD,u ; load OS-9 path number
                    pshs      d,x       ; pass path and buffer pointer
_read               EXTERN    ;         import OS-9 read wrapper
getc_call_read      lbsr      _read     ; read bytes into the selected buffer
getc_after_read     leas      6,s       ; discard count, pointer, and path arguments
                    std       stk_getc_read_count,s ; keep byte count while testing it
                    beq       getc_mark_eof ; zero bytes read means EOF
                    bmi       getc_mark_error ; negative result means OS-9 error
                    ldx       FILE_BASE,u ; reload buffer base
                    leax      d,x       ; compute end pointer from bytes read
                    stx       FILE_END,u ; save new buffer end
                    ldx       FILE_BASE,u ; start consuming at buffer base
                    lbra      getc_consume_buffered ; return the first freshly read byte

                    endsect   ;         end current section
