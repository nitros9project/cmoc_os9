* Compact assembly implementation of mktemp().

                    section   code      ; begin code section

_mktemp             EXPORT              ; export this symbol

_getpid             EXTERNAL            ; import external symbol
_itoa               EXTERNAL            ; import external symbol

_mktemp
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
L_mktemp_scan
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    beq       L_mktemp_done ; branch if equal/zero to L_mktemp_done
                    cmpb      #'X
                    bne       L_mktemp_scan ; branch if not equal to L_mktemp_scan
                    leau      -1,u      ; compute effective address into U from -1,u
                    pshs      u         ; save U on the hardware stack
                    ldd       #5        ; load D from immediate value 5
L_mktemp_zero
                    sta       ,u+       ; store A to memory pointed to by U, then advance U
                    decb                ; decrement B
                    bne       L_mktemp_zero ; branch if not equal to L_mktemp_zero
                    puls      u         ; restore U from the hardware stack
                    lbsr      _getpid   ; long branch to subroutine to _getpid
                    pshs      d,u       ; save D,U on the hardware stack
                    lbsr      _itoa     ; long branch to subroutine to _itoa
                    leas      4,s       ; adjust S using 4,s
L_mktemp_done
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
