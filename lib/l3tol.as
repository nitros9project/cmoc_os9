* Adapted from cmoc_os9/lib/todo/l3tol.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_l3tol              EXPORT    ;         export this symbol

_l3tol:
stk_l3tol_saved_u   equ       0         ; saved U register after pshs u
stk_l3tol_ret       equ       2         ; caller return address after pshs u
stk_l3tol_dest      equ       4         ; destination long array pointer
stk_l3tol_source    equ       6         ; source 3-byte integer array pointer, updated in place
stk_l3tol_count     equ       8         ; element count, decremented in place
                    pshs      u         ; preserve caller's U register
                    ldu       stk_l3tol_dest,s ; load destination long array pointer
                    ldd       stk_l3tol_source,s ; prime source pointer update for first element
                    addd      #1        ; point at byte 1 of the first 3-byte source value
                    bra       l3tol_count_down ; enter loop through shared count update
l3tol_copy_loop     clra                ; sign/extension high byte is zero for positive 24-bit input
                    clrb                ; first destination byte is the high byte of the 32-bit long
                    stb       ,u        ; write high byte of converted long
                    ldx       stk_l3tol_source,s ; load adjusted source pointer
                    ldb       -1,x      ; fetch first byte of 3-byte source value
                    stb       1,u       ; store source high byte into long byte 1
                    ldd       [stk_l3tol_source,s] ; fetch remaining two source bytes
                    std       2,u       ; store source middle/low bytes into long bytes 2/3
                    leau      4,u       ; advance destination to next 32-bit long
                    ldd       stk_l3tol_source,s ; reload current adjusted source pointer
                    addd      #3        ; advance source pointer by one 3-byte element
l3tol_count_down    std       stk_l3tol_source,s ; keep updated source pointer in caller slot
                    ldd       stk_l3tol_count,s ; load remaining element count
                    addd      #-1       ; decrement count
                    std       stk_l3tol_count,s ; keep updated count in caller slot
                    subd      #-1       ; test original count before the decrement
                    bgt       l3tol_copy_loop ; copy while original count was positive
                    puls      u,pc      ; restore registers and return

                    endsect   ;         end current section
