* Compact assembly implementation of atoi().

                    section   code      ; begin code section

_atoi               EXPORT              ; export this symbol

_atoi
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    clra                ; clear A
                    clrb                ; clear B
                    pshs      d         ; save D on the hardware stack
                    pshs      b         ; save B on the hardware stack
L_atoi_skip
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    cmpb      #$20      ; compare B against ASCII space
                    beq       L_atoi_skip ; branch if equal/zero to L_atoi_skip
                    cmpb      #9        ; compare B against immediate value 9
                    beq       L_atoi_skip ; branch if equal/zero to L_atoi_skip
                    cmpb      #'-'      ; compare B against character literal '-'
                    bne       L_atoi_plus ; branch if not equal to L_atoi_plus
                    stb       ,s        ; store B to memory pointed to by S
                    bra       L_atoi_next ; branch unconditionally to L_atoi_next

L_atoi_plus
                    cmpb      #'+'      ; compare B against character literal '+'
                    bne       L_atoi_check ; branch if not equal to L_atoi_check
                    bra       L_atoi_next ; branch unconditionally to L_atoi_next

L_atoi_accum
                    ldd       1,s       ; load D from stack-relative value 1,s
                    aslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    aslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    addd      1,s       ; add stack-relative value 1,s into D
                    aslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    pshs      d         ; save D on the hardware stack
                    ldb       -1,u      ; load B from indexed value -1,u
                    clra                ; clear A
                    subb      #'0'      ; subtract character literal '0' from B
                    addd      ,s++      ; add memory pointed to by S+, then advance S+ into D
                    std       1,s       ; store D to stack-relative value 1,s

L_atoi_next
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U

L_atoi_check
                    cmpb      #'0'      ; compare B against character literal '0'
                    blo       L_atoi_done ; branch if lower to L_atoi_done
                    cmpb      #'9'      ; compare B against character literal '9'
                    bls       L_atoi_accum ; branch if lower or same to L_atoi_accum

L_atoi_done
                    tst       ,s+       ; test memory pointed to by S, then advance S and update condition codes
                    puls      d         ; restore D from the hardware stack
                    beq       L_atoi_exit ; branch if equal/zero to L_atoi_exit
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A

L_atoi_exit
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
