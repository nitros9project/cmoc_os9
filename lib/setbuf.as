* Adapted from cmoc_os9/lib/ported/setbuf.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_setbuf             EXPORT              ; export this symbol

_fflush             EXTERN              ; import external symbol

_setbuf
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    beq       BranchTarget_04 ; branch if equal/zero to BranchTarget_04
                    lda       6,u       ; load A from indexed value 6,u
                    anda      #1        ; AND A with immediate value 1
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    pshs      u         ; save U on the hardware stack
                    lbsr      _fflush   ; long branch to subroutine to _fflush
                    leas      2,s       ; adjust S using 2,s
BranchTarget_01     ldd       6,u       ; load D from indexed value 6,u
                    anda      #^1       ; AND A with immediate value ^1
                    andb      #$f3      ; AND B with immediate value $f3
                    std       6,u       ; store D to indexed value 6,u
                    ldx       6,s       ; load X from stack-relative value 6,s
                    beq       BranchTarget_03 ; branch if equal/zero to BranchTarget_03
                    ldd       11,u      ; load D from indexed value 11,u
                    bne       BranchTarget_02 ; branch if not equal to BranchTarget_02
                    ldd       #$0100    ; load D from immediate value $0100
                    std       11,u      ; store D to indexed value 11,u
BranchTarget_02     stx       2,u       ; store X to indexed value 2,u
                    leax      d,x       ; compute effective address into X from d,x
                    ldb       #8        ; load B from immediate value 8
                    bra       Continue_01 ; branch unconditionally to Continue_01
BranchTarget_03     leax      11,u      ; compute effective address into X from 11,u
                    ldb       #4        ; load B from immediate value 4
Continue_01         orb       7,u       ; OR B with indexed value 7,u
                    stb       7,u       ; store B to indexed value 7,u
                    stx       4,u       ; store X to indexed value 4,u
                    stx       ,u        ; store X to memory pointed to by U
BranchTarget_04     puls      u,pc      ; restore registers and return

                    endsect             ; end current section
