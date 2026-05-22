_putc               EXPORT    ;         export buffered/unbuffered character output

__os_write          EXTERNAL  ;         low-level write wrapper
__os_writeln        EXTERNAL  ;         low-level writeln wrapper
_setbase            EXTERNAL  ;         stdio buffer initializer
_flush              EXTERNAL  ;         internal stdio flush helper

_WRITE              equ       $02       ; FILE open-for-write flag
_UNBUF              equ       $04       ; FILE unbuffered flag
_ERR                equ       $20       ; FILE error flag
_SCF                equ       $40       ; sequential character file-manager flag

                    section   code      ; begin code section

_putc:
stk_putc_ret        equ       0         ; caller return address
stk_putc_char       equ       2         ; character argument
stk_putc_char_byte  equ       3         ; low byte of character argument
stk_putc_file       equ       4         ; FILE pointer argument
                    pshs      u         ; preserve caller's U register
                    ldu       stk_putc_file+2,s ; load FILE pointer after saved U
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
                    leax      stk_putc_char_byte+6,s ; point X at character byte after staged count/pointer
                    ldd       8,u       ; load underlying path number
                    pshs      d,x       ; push path and data pointer
                    ldb       7,u       ; load low byte of FILE flags
                    andb      #_SCF     ; test whether device is SCF
                    beq       unbuf_write_block ; plain block write for non-SCF devices
                    lbsr      __os_writeln ; SCF output wants line semantics
                    bra       unbuf_write_done ; share post-write result handling
unbuf_write_block   lbsr      __os_write ; perform raw byte write
unbuf_write_done    leas      8,s       ; discard stacked write arguments
                    cmpd      #0        ; low-level wrappers return zero on success
                    beq       putc_success ; return written character on success
                    ldb       7,u       ; reload low byte of FILE flags
                    orb       #_ERR     ; mark stream as having encountered an error
                    stb       7,u       ; save updated error flag
badexit             ldd       #-1       ; return EOF on failure
                    puls      u,pc      ; restore U and return

buffered            anda      #$01      ; test _WRITTEN state in high-byte flag bit
                    bne       store_buffered_char ; skip initial flush if already in write mode
                    pshs      u         ; pass FILE pointer to flush helper
                    lbsr      _flush    ; synchronize buffer for first write after reading
                    std       ,s++      ; discard helper argument and capture return code
                    bne       badexit   ; fail if the flush/setup did not succeed
store_buffered_char ldx       ,u        ; load current buffer pointer
                    ldb       stk_putc_char_byte+2,s ; load character argument after saved U
                    stb       ,x+       ; store character and advance pointer
                    stx       ,u        ; save updated buffer pointer
                    cmpx      4,u       ; compare against buffer end pointer
                    bcc       flush_buffered_char ; flush once the buffer reaches its limit
                    ldb       7,u       ; load low byte of FILE flags
                    andb      #_SCF     ; only SCF streams flush on newline
                    beq       putc_success ; buffered RBF devices can delay the write
                    ldb       stk_putc_char_byte+2,s ; reload character argument after saved U
                    cmpb      #$0A      ; test for line-feed terminator
                    bne       putc_success ; keep buffering until newline or full buffer
                    ldb       #$0D      ; convert pending line terminator to carriage return
flush_buffered_char pshs      u         ; pass FILE pointer to flush helper
                    lbsr      _flush    ; write buffered data to the underlying path
                    std       ,s++      ; discard helper argument and capture return code
                    bne       badexit   ; fail if the flush did not succeed
putc_success        ldd       stk_putc_char+2,s ; return original character argument
                    puls      u,pc      ; restore U and return

                    endsect   ;         end code section
