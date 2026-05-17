* Compact assembly implementation of reverse().

                    section   code      ; begin code section

_reverse            EXPORT              ; export this symbol

_strlen             EXTERNAL            ; import external symbol

_reverse
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    pshs      u         ; save U on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    lbsr      _strlen   ; long branch to subroutine to _strlen
                    leas      2,s       ; adjust S using 2,s
                    addd      ,s++      ; add memory pointed to by S+, then advance S+ into D
                    tfr       d,x       ; transfer D,X
                    bra       L_reverse_check ; branch unconditionally to L_reverse_check

L_reverse_loop
                    ldb       ,u        ; load B from memory pointed to by U
                    lda       ,-x       ; load A from memory pointed to by -X
                    sta       ,u+       ; store A to memory pointed to by U, then advance U
                    stb       ,x        ; store B to memory pointed to by X

L_reverse_check
                    pshs      x         ; save X on the hardware stack
                    cmpu      ,s++      ; compare U against memory pointed to by S+, then advance S+
                    blo       L_reverse_loop ; branch if lower to L_reverse_loop
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
