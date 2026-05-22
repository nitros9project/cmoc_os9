* Adapted from Deek's KLibc strncpy.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strncpy            EXPORT    ;         export strncpy helper

_strncpy:
stk_strncpy_ret     equ       0         ; caller return address
stk_strncpy_dest    equ       2         ; destination string pointer
stk_strncpy_source  equ       4         ; source string pointer
stk_strncpy_count   equ       6         ; maximum bytes to copy
                    pshs      y,u       ; preserve caller's Y and U registers
                    ldu       stk_strncpy_source+4,s ; load source pointer after saved Y/U
                    ldx       stk_strncpy_dest+4,s ; load destination pointer after saved Y/U
                    ldy       stk_strncpy_count+4,s ; load copy count after saved Y/U
                    beq       BranchTarget_01 ; return immediately for zero count
Loop_01             ldb       ,u+       ; copy next source byte
                    stb       ,x+       ; store byte into destination
                    leay      -1,y      ; count down copied byte
                    beq       BranchTarget_01 ; stop after requested count
                    tstb                ; check for copied NUL terminator
                    bne       Loop_01   ; continue until source NUL or count expires
Loop_02             clr       ,x+       ; pad remaining destination bytes with NUL
                    leay      -1,y      ; count down padding byte
                    bne       Loop_02   ; continue until count is exhausted
BranchTarget_01     ldd       stk_strncpy_dest+4,s ; return destination pointer
                    puls      y,u,pc    ; restore registers and return

                    endsect   ;         end current section
