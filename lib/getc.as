                    section   code      ; begin code section

_getc               EXPORT              ; export this symbol
_ungetc             EXPORT              ; export this symbol
_getw               EXPORT              ; export this symbol

__iob               EXTERN              ; import external symbol

_getc               pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    beq       Loop_05   ; branch if equal/zero to Loop_05
                    lda       6,u       ; load A from indexed value 6,u
                    anda      #1        ; AND A with immediate value 1
                    bne       Loop_05   ; branch if not equal to Loop_05
                    ldx       ,u        ; load X from memory pointed to by U
                    cmpx      4,u       ; compare X against indexed value 4,u
                    bcc       BranchTarget_02 ; branch if carry is clear to BranchTarget_02
Loop_01             ldb       ,x+       ; load B from memory pointed to by X, then advance X
Loop_02             stx       ,u        ; store X to memory pointed to by U
                    clra                ; clear A
                    puls      u,pc      ; restore registers and return

_ungetc             pshs      u         ; save U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    beq       Loop_05   ; branch if equal/zero to Loop_05
                    ldb       7,u       ; load B from indexed value 7,u
                    andb      #1        ; AND B with immediate value 1
                    beq       Loop_05   ; branch if equal/zero to Loop_05
                    ldd       4,s       ; load D from stack-relative value 4,s
                    cmpd      #-1       ; compare D against immediate value -1
                    beq       Loop_05   ; branch if equal/zero to Loop_05
                    ldx       ,u        ; load X from memory pointed to by U
                    cmpx      2,u       ; compare X against indexed value 2,u
                    beq       Loop_05   ; branch if equal/zero to Loop_05
                    stb       ,-x       ; store B to memory pointed to by -X
                    bra       Loop_02   ; branch unconditionally to Loop_02

_getw               pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    pshs      u,pc      ; save U,PC on the hardware stack
                    bsr       _getc     ; branch to subroutine to _getc
                    std       2,s       ; store D to stack-relative value 2,s
                    cmpd      #-1       ; compare D against immediate value -1
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    bsr       _getc     ; branch to subroutine to _getc
                    cmpd      #-1       ; compare D against immediate value -1
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    lda       3,s       ; load A from stack-relative value 3,s
BranchTarget_01     leas      4,s       ; adjust S using 4,s
                    puls      u,pc      ; restore registers and return

Loop_03             ldb       #$10      ; load B from immediate value $10
                    bra       Continue_01 ; branch unconditionally to Continue_01
Loop_04             ldb       #$20      ; load B from immediate value $20
Continue_01         orb       7,u       ; OR B with indexed value 7,u
                    stb       7,u       ; store B to indexed value 7,u
Loop_05             ldd       #-1       ; load D from immediate value -1
                    puls      u,pc      ; restore registers and return

BranchTarget_02     ldd       6,u       ; load D from indexed value 6,u
                    anda      #$80      ; AND A with immediate value $80
                    andb      #$31      ; AND B with immediate value $31
                    cmpb      #1        ; compare B against immediate value 1
                    bne       Loop_05   ; branch if not equal to Loop_05
                    cmpa      #$80      ; compare A against immediate value $80
                    beq       BranchTarget_03 ; branch if equal/zero to BranchTarget_03
                    pshs      u         ; save U on the hardware stack
_setbase            EXTERN              ; import external symbol
                    lbsr      _setbase  ; long branch to subroutine to _setbase
                    leas      2,s       ; adjust S using 2,s
BranchTarget_03     leax      __iob,y   ; compute effective address into X from __iob,y
                    pshs      x         ; save X on the hardware stack
                    cmpu      ,s++      ; compare U against memory pointed to by S+, then advance S+
                    bne       BranchTarget_04 ; branch if not equal to BranchTarget_04
                    ldb       7,u       ; load B from indexed value 7,u
                    andb      #$40      ; AND B with immediate value $40
                    beq       BranchTarget_04 ; branch if equal/zero to BranchTarget_04
                    leax      __iob+13,y ; compute effective address into X from __iob+13,y
                    pshs      x         ; save X on the hardware stack
_fflush             EXTERN              ; import external symbol
                    lbsr      _fflush   ; long branch to subroutine to _fflush
                    leas      2,s       ; adjust S using 2,s
BranchTarget_04     ldb       7,u       ; load B from indexed value 7,u
                    andb      #8        ; AND B with immediate value 8
                    beq       BranchTarget_05 ; branch if equal/zero to BranchTarget_05
                    ldd       11,u      ; load D from indexed value 11,u
                    pshs      d         ; save D on the hardware stack
                    ldx       2,u       ; load X from indexed value 2,u
                    ldd       8,u       ; load D from indexed value 8,u
                    pshs      d,x       ; save D,X on the hardware stack
                    ldb       7,u       ; load B from indexed value 7,u
                    andb      #$40      ; AND B with immediate value $40
                    beq       BranchTarget_06 ; branch if equal/zero to BranchTarget_06
_readln             EXTERN              ; import external symbol
                    lbsr      _readln   ; long branch to subroutine to _readln
                    bra       Continue_02 ; branch unconditionally to Continue_02
BranchTarget_05     ldd       #1        ; load D from immediate value 1
                    pshs      d         ; save D on the hardware stack
                    leax      10,u      ; compute effective address into X from 10,u
                    stx       2,u       ; store X to indexed value 2,u
                    ldd       8,u       ; load D from indexed value 8,u
                    pshs      d,x       ; save D,X on the hardware stack
_read               EXTERN              ; import external symbol
BranchTarget_06     lbsr      _read     ; long branch to subroutine to _read
Continue_02         leas      6,s       ; adjust S using 6,s
                    std       -2,s      ; store D to stack-relative value -2,s
                    beq       Loop_03   ; branch if equal/zero to Loop_03
                    bmi       Loop_04   ; branch if minus to Loop_04
                    ldx       2,u       ; load X from indexed value 2,u
                    leax      d,x       ; compute effective address into X from d,x
                    stx       4,u       ; store X to indexed value 4,u
                    ldx       2,u       ; load X from indexed value 2,u
                    lbra      Loop_01   ; long branch unconditionally to Loop_01

                    endsect             ; end current section
