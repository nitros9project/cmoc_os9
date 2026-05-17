* Compact assembly implementation of strchr/strrchr and index/rindex aliases.

                    section   code      ; begin code section

_strchr             EXPORT              ; export this symbol
_index              EXPORT              ; export this symbol
_strrchr            EXPORT              ; export this symbol
_rindex             EXPORT              ; export this symbol

_strchr
_index
                    ldx       2,s       ; load X from stack-relative value 2,s
L_strchr_loop
                    ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    beq       L_strchr_not_found ; branch if equal/zero to L_strchr_not_found
                    cmpb      5,s       ; compare B against stack-relative value 5,s
                    bne       L_strchr_loop ; branch if not equal to L_strchr_loop
                    tfr       x,d       ; transfer X,D
                    bra       L_strrchr_done ; branch unconditionally to L_strrchr_done

L_strchr_not_found
                    clra                ; clear A
                    rts                 ; return to caller

_strrchr
_rindex
                    ldx       2,s       ; load X from stack-relative value 2,s
                    ldd       #1        ; load D from immediate value 1
                    pshs      d         ; save D on the hardware stack
                    bra       L_strrchr_scan ; branch unconditionally to L_strrchr_scan

L_strrchr_match
                    cmpb      7,s       ; compare B against stack-relative value 7,s
                    bne       L_strrchr_scan ; branch if not equal to L_strrchr_scan
                    stx       ,s        ; store X to memory pointed to by S

L_strrchr_scan
                    ldb       ,x+       ; load B from memory pointed to by X, then advance X
                    bne       L_strrchr_match ; branch if not equal to L_strrchr_match
                    puls      d         ; restore D from the hardware stack

L_strrchr_done
                    subd      #1        ; subtract immediate value 1 from D
                    rts                 ; return to caller

                    endsect             ; end current section
