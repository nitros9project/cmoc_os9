* Adapted from Deek's KLibc strncat for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strncat            EXPORT    ;         export strncat helper

_strncat:
stk_strncat_ret     equ       0         ; caller return address
stk_strncat_dest    equ       2         ; destination string pointer
stk_strncat_source  equ       4         ; source string pointer
stk_strncat_count   equ       6         ; maximum bytes to append
                    pshs      y,u       ; preserve caller's Y and U registers
                    ldu       stk_strncat_source+4,s ; load source pointer after saved Y/U
                    ldx       stk_strncat_dest+4,s ; load destination pointer after saved Y/U
                    ldy       stk_strncat_count+4,s ; load append count after saved Y/U
                    beq       BranchTarget_02 ; return immediately when count is zero
Loop_01             ldb       ,x+       ; scan destination byte and advance
                    bne       Loop_01   ; continue until destination NUL
                    leax      -1,x      ; back up to append over NUL
Loop_02             ldb       ,u+       ; copy next source byte
                    stb       ,x+       ; store byte into destination
                    leay      -1,y      ; count down available append bytes
                    beq       BranchTarget_01 ; force terminator after count expires
                    tstb                ; check whether copied byte was NUL
                    bne       Loop_02   ; continue until source NUL or count expires
BranchTarget_01     clr       ,x        ; ensure destination remains NUL-terminated
BranchTarget_02     ldd       stk_strncat_dest+4,s ; return destination pointer
                    puls      y,u,pc    ; restore registers and return

                    endsect   ;         end current section
