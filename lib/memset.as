* Adapted from Deek's KLibc memset.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_memset             EXPORT    ;         export this symbol

_memset:
stk_memset_saved_u  equ       0         ; saved U register after pshs u
stk_memset_ret      equ       2         ; caller return address after pshs u
stk_memset_dest     equ       4         ; destination buffer pointer
stk_memset_char     equ       6         ; 16-bit fill character argument
stk_memset_char_byte equ       7         ; low byte used as fill value
stk_memset_count    equ       8         ; byte count
                    pshs      u         ; preserve U used as destination cursor
                    ldu       stk_memset_dest,s ; load destination pointer
                    ldx       stk_memset_count,s ; load fill byte count
                    beq       memset_done ; zero length leaves destination unchanged
                    ldb       stk_memset_char_byte,s ; load fill byte
memset_loop         stb       ,u+       ; store fill byte and advance destination
                    leax      -1,x      ; decrement remaining byte count
                    bne       memset_loop ; continue until all bytes are written
memset_done         ldd       stk_memset_dest,s ; return original destination pointer
                    puls      u,pc      ; restore registers and return

                    endsect   ;         end current section
