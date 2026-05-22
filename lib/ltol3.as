* Adapted from cmoc_os9/lib/todo/ltol3.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_ltol3              EXPORT    ;         export this symbol

_ltol3:
stk_ltol3_saved_u   equ       0         ; saved U register after pshs u
stk_ltol3_ret       equ       2         ; caller return address after pshs u
stk_ltol3_dest      equ       4         ; destination 3-byte array pointer
stk_ltol3_source    equ       6         ; source long array pointer, updated in place
stk_ltol3_count     equ       8         ; element count, decremented in place
                    pshs      u         ; preserve caller's U register
                    ldu       stk_ltol3_dest,s ; load destination 3-byte array pointer
                    leau      1,u       ; bias destination so -1,u is the first output byte
                    bra       ltol3_count_down ; enter loop through shared count update
ltol3_copy_loop     ldx       stk_ltol3_source,s ; load current source long pointer
                    ldb       1,x       ; fetch long byte 1, dropping byte 0
                    stb       -1,u      ; store first 3-byte output byte
                    ldx       stk_ltol3_source,s ; reload current source long pointer
                    ldd       2,x       ; fetch long bytes 2/3
                    std       ,u        ; store remaining 3-byte output bytes
                    ldd       stk_ltol3_source,s ; reload source pointer for update
                    addd      #4        ; advance source by one 32-bit long
                    std       stk_ltol3_source,s ; keep updated source pointer in caller slot
                    leau      3,u       ; advance destination by one 3-byte element
ltol3_count_down    ldd       stk_ltol3_count,s ; load remaining element count
                    addd      #-1       ; decrement count
                    std       stk_ltol3_count,s ; keep updated count in caller slot
                    subd      #-1       ; test original count before the decrement
                    bgt       ltol3_copy_loop ; copy while original count was positive
                    puls      u,pc      ; restore registers and return

                    endsect   ;         end current section
