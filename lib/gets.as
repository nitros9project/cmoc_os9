* Compact assembly implementation of gets().

                    section   code      ; begin code section

_gets               EXPORT              ; export this symbol

_getc               EXTERNAL            ; import external symbol
__iob               EXTERNAL            ; import external symbol

_gets
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    bra       L_gets_read ; branch unconditionally to L_gets_read
L_gets_store
                    stb       ,u+       ; store B to memory pointed to by U, then advance U
L_gets_read
                    leax      __iob,y   ; compute effective address into X from __iob,y
                    pshs      x         ; save X on the hardware stack
                    lbsr      _getc     ; long branch to subroutine to _getc
                    leas      2,s       ; adjust S using 2,s
                    cmpb      #$0D      ; compare B against immediate value $0D
                    beq       L_gets_done ; branch if equal/zero to L_gets_done
                    cmpd      #-1       ; compare D against immediate value -1
                    bne       L_gets_store ; branch if not equal to L_gets_store
                    clra                ; clear A
                    clrb                ; clear B
                    bra       L_gets_exit ; branch unconditionally to L_gets_exit
L_gets_done
                    clr       ,u        ; clear memory pointed to by U
                    ldd       4,s       ; load D from stack-relative value 4,s
L_gets_exit
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
