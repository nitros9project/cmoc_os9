* Adapted from Deek's KLibc strclr_a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strclr             EXPORT    ;         export string clear helper

_strclr:
stk_strclr_ret      equ       0         ; caller return address
stk_strclr_dest     equ       2         ; destination pointer
stk_strclr_count    equ       4         ; byte count to clear
                    pshs      u         ; preserve caller's U register
                    ldu       stk_strclr_dest+2,s ; load destination pointer after saved U
                    clrb                ; prepare zero byte for clearing
                    ldx       stk_strclr_count+2,s ; load byte count after saved U
                    beq       BranchTarget_01 ; return immediately for zero length
Loop_01             stb       ,u+       ; clear next destination byte
                    leax      -1,x      ; count down remaining bytes
                    bne       Loop_01   ; continue until buffer is cleared
BranchTarget_01     ldd       stk_strclr_dest+2,s ; return destination pointer
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
