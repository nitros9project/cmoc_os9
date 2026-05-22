* Compact assembly implementation of write()/writeln().

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_write              EXPORT    ;         export write() wrapper
_writeln            EXPORT    ;         export writeln() wrapper

_os9err             EXTERNAL  ;         convert OS-9 carry/error into C return

_write:
stk_write_ret       equ       0         ; caller return address
stk_write_path      equ       2         ; path descriptor argument
stk_write_buffer    equ       4         ; caller data buffer pointer
stk_write_count     equ       6         ; requested byte count
                    pshs      y         ; preserve CMOC data pointer while OS-9 uses Y
                    ldy       stk_write_count+2,s ; pass requested byte count after saved Y
                    beq       L_write_exit ; return zero immediately for empty writes
                    lda       stk_write_path+3,s ; pass low byte of path descriptor in A
                    ldx       stk_write_buffer+2,s ; pass caller data buffer in X
                    os9       I_Write   ; write raw bytes to the OS-9 path
L_write_common
                    bcc       L_write_exit ; return byte count when OS-9 reports success
                    puls      y         ; restore CMOC data pointer before error exit
                    lbra      _os9err   ; return -1 and set errno from OS-9 error
L_write_exit
                    tfr       y,d       ; return byte count written as a C int
                    puls      y,pc      ; restore CMOC data pointer and return

_writeln:
stk_writeln_ret     equ       0         ; caller return address
stk_writeln_path    equ       2         ; path descriptor argument
stk_writeln_buffer  equ       4         ; caller line buffer pointer
stk_writeln_count   equ       6         ; requested byte count
                    pshs      y         ; preserve CMOC data pointer while OS-9 uses Y
                    ldy       stk_writeln_count+2,s ; pass requested byte count after saved Y
                    beq       L_write_exit ; return zero immediately for empty writes
                    lda       stk_writeln_path+3,s ; pass low byte of path descriptor in A
                    ldx       stk_writeln_buffer+2,s ; pass caller line buffer in X
                    os9       I_WritLn  ; write bytes, stopping at line terminator if reached
                    bra       L_write_common ; share success/error return handling

                    endsect   ;         end current section
