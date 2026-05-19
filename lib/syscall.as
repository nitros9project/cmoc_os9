__os_syscall        EXPORT    ;         export generic system-call wrapper

_oserr              EXTERNAL  ;         common OS-9 error return helper
_osret              EXTERNAL  ;         common successful return helper

                    section   code      ; begin code section

__os_syscall:
stk_os_syscall_ret  equ       0         ; caller return address
stk_os_syscall_code equ       2         ; OS-9 call code argument
stk_os_syscall_regs equ       4         ; register block pointer argument
                    pshs      y,u       ; preserve Y and U while staging the call
                    lda       stk_os_syscall_code+5,s ; load low byte of requested OS-9 call code
                    ldb       #$39      ; build trailing RTS opcode for stub frame
                    pshs      d         ; push call code and RTS byte onto the stack
                    ldd       #$103F    ; load SWI2 prefix used by OS-9 system calls
                    pshs      d         ; push SWI2 opcode ahead of the call code
                    ldu       stk_os_syscall_regs+8,s ; load pointer after saved Y/U and stub
                    ldd       1,u       ; restore caller's A and B into D
                    ldx       4,u       ; restore caller's X register
                    ldy       6,u       ; restore caller's Y register
                    ldu       8,u       ; restore caller's U register
                    jsr       ,s        ; execute the synthesized system-call stub
                    pshs      cc,u      ; save returned condition codes and U
                    ldu       stk_os_syscall_regs+11,s ; reload register block pointer after return save
                    leau      8,u       ; point at the saved U field within the block
                    pshu      d,dp,x,y  ; store returned D, DP, X, and Y values
                    puls      a,x       ; recover returned CC into A and U into X
                    sta       ,-u       ; store returned condition codes ahead of saved U
                    stx       8,u       ; store returned U value into the register block
                    leas      4,s       ; discard synthesized SWI2/call/RTS stub
                    puls      y,u       ; restore caller's Y and U registers
                    bita      #1        ; test carry flag from returned condition codes
                    lbeq      _osret    ; branch if the system call succeeded
                    lbra      _oserr    ; dispatch carry-set failures through errno path

                    endsect   ;         end code section
