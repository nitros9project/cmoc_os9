__os_syscall        EXPORT              ; export generic system-call wrapper

_oserr              EXTERNAL            ; common OS-9 error return helper
_osret              EXTERNAL            ; common successful return helper

                    section   code      ; begin code section

__os_syscall
                    pshs      y,u       ; preserve Y and U while staging the call
                    lda       7,s       ; load low byte of requested OS-9 call code
                    ldb       #$39      ; build trailing RTS opcode for stub frame
                    pshs      d         ; push call code and RTS byte onto the stack
                    ldd       #$103F    ; load SWI2 prefix used by OS-9 system calls
                    pshs      d         ; push SWI2 opcode ahead of the call code
                    ldu       12,s      ; load pointer to caller-supplied register block
                    ldd       1,u       ; restore caller's A and B into D
                    ldx       4,u       ; restore caller's X register
                    ldy       6,u       ; restore caller's Y register
                    ldu       8,u       ; restore caller's U register
                    jsr       ,s        ; execute the synthesized system-call stub
                    pshs      cc,u      ; save returned condition codes and U
                    ldu       15,s      ; reload pointer to register block
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

                    endsect             ; end code section
