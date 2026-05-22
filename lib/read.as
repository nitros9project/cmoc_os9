* Compact assembly implementation of read()/readln().

                    use       ../include/os9.d ; shared OS-9 service and error constants

                    section   code      ; begin code section

_read               EXPORT    ;         export raw path read helper
_readln             EXPORT    ;         export line-oriented raw path read helper

_os9err             EXTERNAL  ;         import errno-style OS-9 error handler

_read:
stk_read_ret        equ       0         ; caller return address
stk_read_path       equ       2         ; path number argument
stk_read_path_byte  equ       3         ; low byte passed to OS-9 in A
stk_read_buffer     equ       4         ; destination buffer pointer
stk_read_count      equ       6         ; requested byte count
                    pshs      y         ; preserve caller's Y register
                    lda       stk_read_path_byte+2,s ; load path number after saved Y
                    ldx       stk_read_buffer+2,s ; load destination buffer pointer after saved Y
                    ldy       stk_read_count+2,s ; load requested byte count after saved Y
                    pshs      y         ; save original count while OS-9 returns actual count in Y
                    os9       I_Read    ; read up to Y bytes from the path into X
L_read_common
                    bcc       L_read_exit ; return byte count when OS-9 reports success
                    cmpb      #E_EOF    ; EOF is a successful zero-byte read for this API
                    bne       L_read_error ; route other OS-9 errors through errno handling
                    clra                ; return zero bytes read at EOF
                    clrb                ; return zero bytes read at EOF
                    puls      x,y,pc    ; discard saved count, restore Y, and return
L_read_error
                    puls      x,y       ; discard saved count and restore caller's Y register
                    lbra      _os9err   ; convert OS-9 error in B to C return convention
L_read_exit
                    tfr       y,d       ; return actual byte count from OS-9 Y in D
                    puls      x,y,pc    ; discard saved count, restore Y, and return

_readln:
stk_readln_ret      equ       0         ; caller return address
stk_readln_path     equ       2         ; path number argument
stk_readln_path_byte equ       3         ; low byte passed to OS-9 in A
stk_readln_buffer   equ       4         ; destination line buffer pointer
stk_readln_count    equ       6         ; requested byte count
                    pshs      y         ; preserve caller's Y register
                    lda       stk_readln_path_byte+2,s ; load path number after saved Y
                    ldx       stk_readln_buffer+2,s ; load destination buffer pointer after saved Y
                    ldy       stk_readln_count+2,s ; load requested byte count after saved Y
                    pshs      y         ; save original count while OS-9 returns actual count in Y
                    os9       I_ReadLn  ; read one line from the path into X
                    bra       L_read_common ; share EOF/error/count return handling

                    endsect   ;         end current section
