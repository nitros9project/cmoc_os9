* Disassembly by Os9disasm of cfloats.r

                    section   code      ; begin code section

* class D external label equates

_flacc              EXTERNAL            ; import external symbol
_rpterr             EXTERNAL            ; import external symbol

D0000               equ       $0000     ; define constant as $0000
D0010               equ       $0010     ; define constant as $0010
D0011               equ       $0011     ; define constant as $0011
D0012               equ       $0012     ; define constant as $0012
D0013               equ       $0013     ; define constant as $0013
D0014               equ       $0014     ; define constant as $0014
D0015               equ       $0015     ; define constant as $0015
D0016               equ       $0016     ; define constant as $0016
D0017               equ       $0017     ; define constant as $0017
D0018               equ       $0018     ; define constant as $0018
D0019               equ       $0019     ; define constant as $0019
D001c               equ       $001c     ; define constant as $001c
D001d               equ       $001d     ; define constant as $001d
D001e               equ       $001e     ; define constant as $001e
D0022               equ       $0022     ; define constant as $0022
D0023               equ       $0023     ; define constant as $0023
D0024               equ       $0024     ; define constant as $0024
D0025               equ       $0025     ; define constant as $0025
D0026               equ       $0026     ; define constant as $0026
D0027               equ       $0027     ; define constant as $0027
D0028               equ       $0028     ; define constant as $0028
D0029               equ       $0029     ; define constant as $0029
D002a               equ       $002a     ; define constant as $002a
D0081               equ       $0081     ; define constant as $0081

_dnorm              EXPORT              ; export this symbol
_dneg               EXPORT              ; export this symbol
_dadd               EXPORT              ; export this symbol
_dsub               EXPORT              ; export this symbol
_ddiv               EXPORT              ; export this symbol
_dmul               EXPORT              ; export this symbol
_ddiv               EXPORT              ; export this symbol
_dtoi               EXPORT              ; export this symbol
_ltod               EXPORT              ; export this symbol
_itod               EXPORT              ; export this symbol
_utod               EXPORT              ; export this symbol
_dtof               EXPORT              ; export this symbol
_ftod               EXPORT              ; export this symbol
_dcmpr              EXPORT              ; export this symbol
_xtofla             EXPORT              ; export this symbol
_dinc               EXPORT              ; export this symbol
_ddec               EXPORT              ; export this symbol
_finc               EXPORT              ; export this symbol
_fdec               EXPORT              ; export this symbol
_fstack             EXPORT              ; export this symbol
_dstack             EXPORT              ; export this symbol
_fmove              EXPORT              ; export this symbol
_dmove              EXPORT              ; export this symbol

_dnorm:             ldx       2,s       ; load X from stack-relative value 2,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       Subroutine_01 ; branch to subroutine to Subroutine_01
                    rts                 ; return to caller
Subroutine_01       pshs      u         ; save U on the hardware stack
                    leas      -30,s     ; adjust S using -30,s
                    tfr       s,u       ; transfer S,U
                    clr       D001d,u   ; clear indexed value D001d,u
                    clr       D0019,u   ; clear indexed value D0019,u
                    lbsr      Subroutine_04 ; long branch to subroutine to Subroutine_04
                    lbra      Continue_01 ; long branch unconditionally to Continue_01
_dneg:              ldb       #7        ; load B from immediate value 7
                    clra                ; clear A
Loop_01             ora       b,x       ; OR A with indexed value b,x
                    decb                ; decrement B
                    bpl       Loop_01   ; branch if plus to Loop_01
                    tsta                ; test A and update condition codes
                    lbeq      _xtofla   ; long branch if equal/zero to _xtofla
                    ldd       ,x        ; load D from memory pointed to by X
                    eora      #$80      ; XOR A with immediate value $80
                    lbra      Continue_07 ; long branch unconditionally to Continue_07
_dadd:              lbsr      Subroutine_12 ; long branch to subroutine to Subroutine_12
                    lbsr      Subroutine_03 ; long branch to subroutine to Subroutine_03
                    lbra      Continue_01 ; long branch unconditionally to Continue_01
_dsub:              lbsr      Subroutine_12 ; long branch to subroutine to Subroutine_12
                    lbsr      Subroutine_02 ; long branch to subroutine to Subroutine_02
                    lbra      Continue_01 ; long branch unconditionally to Continue_01
_dmul:              lbsr      Subroutine_12 ; long branch to subroutine to Subroutine_12
                    lbsr      Subroutine_06 ; long branch to subroutine to Subroutine_06
                    bra       Continue_01 ; branch unconditionally to Continue_01
_ddiv:              lbsr      Subroutine_12 ; long branch to subroutine to Subroutine_12
                    lbsr      Subroutine_08 ; long branch to subroutine to Subroutine_08
                    bra       Continue_01 ; branch unconditionally to Continue_01
_dtol:              lbsr      _xtofla   ; long branch to subroutine to _xtofla
                    lbra      Continue_06 ; long branch unconditionally to Continue_06
_dtoi:              bsr       _dtol     ; branch to subroutine to _dtol
                    ldd       2,x       ; load D from indexed value 2,x
                    rts                 ; return to caller
_ltod:              ldd       ,x        ; load D from memory pointed to by X
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    ldd       2,x       ; load D from indexed value 2,x
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       2,x       ; store D to indexed value 2,x
                    lbra      Continue_05 ; long branch unconditionally to Continue_05
_itod:              leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       2,x       ; store D to indexed value 2,x
                    tfr       a,b       ; transfer A,B
                    sex                 ; sign-extend B into A to form D
                    tfr       a,b       ; transfer A,B
                    std       ,x        ; store D to memory pointed to by X
                    lbra      Continue_05 ; long branch unconditionally to Continue_05
_utod:              leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       2,x       ; store D to indexed value 2,x
                    clr       ,x        ; clear memory pointed to by X
                    clr       1,x       ; clear indexed value 1,x
                    lbra      Continue_05 ; long branch unconditionally to Continue_05
_dtof:              ldd       ,x        ; load D from memory pointed to by X
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    lda       2,x       ; load A from indexed value 2,x
                    ldb       7,x       ; load B from indexed value 7,x
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       2,x       ; store D to indexed value 2,x
                    rts                 ; return to caller
_ftod:              ldd       ,x        ; load D from memory pointed to by X
                    std       _flacc,y  ; store D to indexed value _flacc,y
                    ldd       2,x       ; load D from indexed value 2,x
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    sta       2,x       ; store A to indexed value 2,x
                    stb       7,x       ; store B to indexed value 7,x
                    clr       3,x       ; clear indexed value 3,x
                    clr       4,x       ; clear indexed value 4,x
                    clr       5,x       ; clear indexed value 5,x
                    clr       6,x       ; clear indexed value 6,x
                    rts                 ; return to caller
Continue_01         leax      _flacc,y  ; compute effective address into X from _flacc,y
                    ldd       D0022,u   ; load D from indexed value D0022,u
                    std       ,x        ; store D to memory pointed to by X
                    ldd       D0024,u   ; load D from indexed value D0024,u
                    std       2,x       ; store D to indexed value 2,x
                    ldd       D0026,u   ; load D from indexed value D0026,u
                    std       4,x       ; store D to indexed value 4,x
                    ldd       D0028,u   ; load D from indexed value D0028,u
                    std       6,x       ; store D to indexed value 6,x
                    leas      D001e,u   ; adjust S using D001e,u
                    puls      u         ; restore U from the hardware stack
                    puls      d         ; restore D from the hardware stack
                    std       6,s       ; store D to stack-relative value 6,s
                    leas      6,s       ; adjust S using 6,s
                    rts                 ; return to caller
_dcmpr:             lda       2,s       ; load A from stack-relative value 2,s
                    eora      ,x        ; XOR A with memory pointed to by X
                    bmi       BranchTarget_03 ; branch if minus to BranchTarget_03
                    lda       2,s       ; load A from stack-relative value 2,s
                    bmi       BranchTarget_02 ; branch if minus to BranchTarget_02
                    lda       9,s       ; load A from stack-relative value 9,s
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    ldb       7,x       ; load B from indexed value 7,x
                    beq       BranchTarget_04 ; branch if equal/zero to BranchTarget_04
                    cmpa      7,x       ; compare A against indexed value 7,x
                    bne       Loop_02   ; branch if not equal to Loop_02
                    ldd       2,s       ; load D from stack-relative value 2,s
                    cmpd      ,x        ; compare D against memory pointed to by X
                    bne       Loop_02   ; branch if not equal to Loop_02
                    ldd       4,s       ; load D from stack-relative value 4,s
                    cmpd      2,x       ; compare D against indexed value 2,x
                    bne       Loop_02   ; branch if not equal to Loop_02
                    ldd       6,s       ; load D from stack-relative value 6,s
                    cmpd      4,x       ; compare D against indexed value 4,x
                    bne       Loop_02   ; branch if not equal to Loop_02
                    lda       8,s       ; load A from stack-relative value 8,s
                    anda      #254      ; AND A with immediate value 254
                    pshs      a         ; save A on the hardware stack
                    ldb       6,x       ; load B from indexed value 6,x
                    andb      #254      ; AND B with immediate value 254
                    cmpa      ,s+       ; compare A against memory pointed to by S, then advance S
                    bne       Loop_02   ; branch if not equal to Loop_02
                    bra       Loop_03   ; branch unconditionally to Loop_03
BranchTarget_01     lda       7,x       ; load A from indexed value 7,x
                    bne       BranchTarget_05 ; branch if not equal to BranchTarget_05
                    clra                ; clear A
                    bra       Loop_03   ; branch unconditionally to Loop_03
BranchTarget_02     lda       7,x       ; load A from indexed value 7,x
                    cmpa      9,s       ; compare A against stack-relative value 9,s
Loop_02             bhi       BranchTarget_04 ; branch if higher to BranchTarget_04
                    bcs       BranchTarget_05 ; branch if carry is set to BranchTarget_05
                    ldd       ,x        ; load D from memory pointed to by X
                    cmpd      2,s       ; compare D against stack-relative value 2,s
                    bne       Loop_02   ; branch if not equal to Loop_02
                    ldd       2,x       ; load D from indexed value 2,x
                    cmpd      4,s       ; compare D against stack-relative value 4,s
                    bne       Loop_02   ; branch if not equal to Loop_02
                    ldd       4,x       ; load D from indexed value 4,x
                    cmpd      6,s       ; compare D against stack-relative value 6,s
                    bne       Loop_02   ; branch if not equal to Loop_02
                    lda       6,x       ; load A from indexed value 6,x
                    anda      #254      ; AND A with immediate value 254
                    pshs      a         ; save A on the hardware stack
                    lda       8,s       ; load A from stack-relative value 8,s
                    anda      #254      ; AND A with immediate value 254
                    cmpa      ,s+       ; compare A against memory pointed to by S, then advance S
                    bne       Loop_02   ; branch if not equal to Loop_02
                    bra       Loop_03   ; branch unconditionally to Loop_03
BranchTarget_03     lda       ,x        ; load A from memory pointed to by X
                    bpl       BranchTarget_05 ; branch if plus to BranchTarget_05
BranchTarget_04     lda       #1        ; load A from immediate value 1
                    andcc     #254      ; clear condition-code bits with mask #254
Loop_03             pshs      cc        ; save CC on the hardware stack
                    ldd       1,s       ; load D from stack-relative value 1,s
                    std       9,s       ; store D to stack-relative value 9,s
                    puls      cc        ; restore CC from the hardware stack
                    leas      8,s       ; adjust S using 8,s
                    rts                 ; return to caller
BranchTarget_05     clra                ; clear A
                    cmpa      #1        ; compare A against immediate value 1
                    bra       Loop_03   ; branch unconditionally to Loop_03
Subroutine_02       lda       D0017,u   ; load A from indexed value D0017,u
                    beq       Loop_04   ; branch if equal/zero to Loop_04
                    ldb       D001c,u   ; load B from indexed value D001c,u
                    eorb      #$80      ; XOR B with immediate value $80
                    stb       D001c,u   ; store B to indexed value D001c,u
                    eorb      D0018,u   ; XOR B with indexed value D0018,u
                    stb       D0019,u   ; store B to indexed value D0019,u
                    ldb       D0029,u   ; load B from indexed value D0029,u
                    bne       BranchTarget_06 ; branch if not equal to BranchTarget_06
                    lbsr      Subroutine_14 ; long branch to subroutine to Subroutine_14
                    lda       D0022,u   ; load A from indexed value D0022,u
                    lbra      BranchTarget_15 ; long branch unconditionally to BranchTarget_15
Loop_04             lda       D0022,u   ; load A from indexed value D0022,u
                    ldb       D0018,u   ; load B from indexed value D0018,u
                    lbra      Continue_03 ; long branch unconditionally to Continue_03
Subroutine_03       lbeq      Subroutine_14 ; long branch if equal/zero to Subroutine_14
                    lda       D0017,u   ; load A from indexed value D0017,u
                    beq       Loop_04   ; branch if equal/zero to Loop_04
BranchTarget_06     suba      D0029,u   ; subtract indexed value D0029,u from A
                    beq       BranchTarget_07 ; branch if equal/zero to BranchTarget_07
                    sta       ,u        ; store A to memory pointed to by U
                    bcs       BranchTarget_08 ; branch if carry is set to BranchTarget_08
                    ldb       D0017,u   ; load B from indexed value D0017,u
                    stb       D0029,u   ; store B to indexed value D0029,u
                    ldd       D0022,u   ; load D from indexed value D0022,u
Loop_05             lsra                ; logical shift A right by one bit
                    rorb                ; rotate B right through carry
                    ror       D0024,u   ; rotate indexed value D0024,u right through carry
                    ror       D0025,u   ; rotate indexed value D0025,u right through carry
                    ror       D0026,u   ; rotate indexed value D0026,u right through carry
                    ror       D0027,u   ; rotate indexed value D0027,u right through carry
                    ror       D0028,u   ; rotate indexed value D0028,u right through carry
                    dec       ,u        ; decrement memory pointed to by U
                    bne       Loop_05   ; branch if not equal to Loop_05
                    std       D0022,u   ; store D to indexed value D0022,u
Loop_06             lda       D0019,u   ; load A from indexed value D0019,u
                    bmi       BranchTarget_10 ; branch if minus to BranchTarget_10
                    bra       Continue_02 ; branch unconditionally to Continue_02
BranchTarget_07     inc       ,u        ; increment memory pointed to by U
                    orcc      #1        ; set condition-code bits with mask #1
                    bra       Loop_06   ; branch unconditionally to Loop_06
BranchTarget_08     ldd       D0010,u   ; load D from indexed value D0010,u
Loop_07             lsra                ; logical shift A right by one bit
                    rorb                ; rotate B right through carry
                    ror       D0012,u   ; rotate indexed value D0012,u right through carry
                    ror       D0013,u   ; rotate indexed value D0013,u right through carry
                    ror       D0014,u   ; rotate indexed value D0014,u right through carry
                    ror       D0015,u   ; rotate indexed value D0015,u right through carry
                    ror       D0016,u   ; rotate indexed value D0016,u right through carry
                    inc       ,u        ; increment memory pointed to by U
                    bne       Loop_07   ; branch if not equal to Loop_07
                    std       D0010,u   ; store D to indexed value D0010,u
                    lda       D0019,u   ; load A from indexed value D0019,u
                    bmi       BranchTarget_11 ; branch if minus to BranchTarget_11
Continue_02         ldd       D0027,u   ; load D from indexed value D0027,u
                    adcb      D0016,u   ; add indexed value D0016,u into B
                    adca      D0015,u   ; add indexed value D0015,u into A
                    std       D0027,u   ; store D to indexed value D0027,u
                    ldd       D0025,u   ; load D from indexed value D0025,u
                    adcb      D0014,u   ; add indexed value D0014,u into B
                    adca      D0013,u   ; add indexed value D0013,u into A
                    std       D0025,u   ; store D to indexed value D0025,u
                    ldb       D0024,u   ; load B from indexed value D0024,u
                    adcb      D0012,u   ; add indexed value D0012,u into B
                    stb       D0024,u   ; store B to indexed value D0024,u
                    ldd       D0022,u   ; load D from indexed value D0022,u
                    adcb      D0011,u   ; add indexed value D0011,u into B
                    adca      D0010,u   ; add indexed value D0010,u into A
                    std       D0022,u   ; store D to indexed value D0022,u
                    bcc       BranchTarget_09 ; branch if carry is clear to BranchTarget_09
                    inc       D0029,u   ; increment indexed value D0029,u
                    ror       D0022,u   ; rotate indexed value D0022,u right through carry
                    ror       D0023,u   ; rotate indexed value D0023,u right through carry
                    ror       D0024,u   ; rotate indexed value D0024,u right through carry
                    ror       D0025,u   ; rotate indexed value D0025,u right through carry
                    ror       D0026,u   ; rotate indexed value D0026,u right through carry
                    ror       D0027,u   ; rotate indexed value D0027,u right through carry
                    ror       D0028,u   ; rotate indexed value D0028,u right through carry
BranchTarget_09     lda       D001c,u   ; load A from indexed value D001c,u
                    sta       D0019,u   ; store A to indexed value D0019,u
                    bra       Subroutine_04 ; branch unconditionally to Subroutine_04
BranchTarget_10     rola                ; rotate A left through carry
                    coma
                    asra                ; arithmetic shift A right by one bit
BranchTarget_11     ldd       D0027,u   ; load D from indexed value D0027,u
                    sbcb      D0016,u   ; subtract indexed value D0016,u from B
                    sbca      D0015,u   ; subtract indexed value D0015,u from A
                    std       D0027,u   ; store D to indexed value D0027,u
                    ldd       D0025,u   ; load D from indexed value D0025,u
                    sbcb      D0014,u   ; subtract indexed value D0014,u from B
                    sbca      D0013,u   ; subtract indexed value D0013,u from A
                    std       D0025,u   ; store D to indexed value D0025,u
                    ldd       D0023,u   ; load D from indexed value D0023,u
                    sbcb      D0012,u   ; subtract indexed value D0012,u from B
                    sbca      D0011,u   ; subtract indexed value D0011,u from A
                    std       D0023,u   ; store D to indexed value D0023,u
                    lda       D0022,u   ; load A from indexed value D0022,u
                    sbca      D0010,u   ; subtract indexed value D0010,u from A
                    sta       D0022,u   ; store A to indexed value D0022,u
                    lda       D0018,u   ; load A from indexed value D0018,u
                    bcc       BranchTarget_13 ; branch if carry is clear to BranchTarget_13
                    com       D0022,u
                    com       D0023,u
                    com       D0024,u
                    com       D0025,u
                    com       D0026,u
                    com       D0027,u
                    com       D0028,u
                    lda       ,u        ; load A from memory pointed to by U
                    beq       BranchTarget_12 ; branch if equal/zero to BranchTarget_12
                    lbsr      Subroutine_13 ; long branch to subroutine to Subroutine_13
BranchTarget_12     lda       D001c,u   ; load A from indexed value D001c,u
BranchTarget_13     sta       D0019,u   ; store A to indexed value D0019,u
Subroutine_04       clr       ,u        ; clear memory pointed to by U
Subroutine_05       lda       D0022,u   ; load A from indexed value D0022,u
                    bmi       BranchTarget_15 ; branch if minus to BranchTarget_15
                    ora       D0023,u   ; OR A with indexed value D0023,u
                    ora       D0024,u   ; OR A with indexed value D0024,u
                    ora       D0025,u   ; OR A with indexed value D0025,u
                    ora       D0026,u   ; OR A with indexed value D0026,u
                    ora       D0027,u   ; OR A with indexed value D0027,u
                    ora       D0028,u   ; OR A with indexed value D0028,u
                    beq       BranchTarget_16 ; branch if equal/zero to BranchTarget_16
                    ldd       D0022,u   ; load D from indexed value D0022,u
Loop_08             dec       D0029,u   ; decrement indexed value D0029,u
                    bne       BranchTarget_14 ; branch if not equal to BranchTarget_14
                    dec       D001d,u   ; decrement indexed value D001d,u
BranchTarget_14     asl       ,u        ; shift memory pointed to by U left by one bit
                    rol       D0028,u   ; rotate indexed value D0028,u left through carry
                    rol       D0027,u   ; rotate indexed value D0027,u left through carry
                    rol       D0026,u   ; rotate indexed value D0026,u left through carry
                    rol       D0025,u   ; rotate indexed value D0025,u left through carry
                    rol       D0024,u   ; rotate indexed value D0024,u left through carry
                    rolb                ; rotate B left through carry
                    rola                ; rotate A left through carry
                    bpl       Loop_08   ; branch if plus to Loop_08
                    stb       D0023,u   ; store B to indexed value D0023,u
                    ldb       D0029,u   ; load B from indexed value D0029,u
                    beq       BranchTarget_17 ; branch if equal/zero to BranchTarget_17
BranchTarget_15     ldb       D0019,u   ; load B from indexed value D0019,u
Continue_03         anda      #$7f      ; AND A with immediate value $7f
                    andb      #$80      ; AND B with immediate value $80
                    pshs      b         ; save B on the hardware stack
                    adda      ,s+       ; add memory pointed to by S, then advance S into A
                    sta       D0022,u   ; store A to indexed value D0022,u
                    tst       D001d,u   ; test indexed value D001d,u and update condition codes
                    bne       BranchTarget_17 ; branch if not equal to BranchTarget_17
Return_01           rts                 ; return to caller
BranchTarget_16     sta       D0029,u   ; store A to indexed value D0029,u
                    rts                 ; return to caller
BranchTarget_17     lda       D001d,u   ; load A from indexed value D001d,u
                    ldb       D0029,u   ; load B from indexed value D0029,u
                    subd      #0        ; subtract immediate value 0 from D
                    beq       BranchTarget_18 ; branch if equal/zero to BranchTarget_18
                    bmi       BranchTarget_18 ; branch if minus to BranchTarget_18
Loop_09             ldd       #$0028    ; load D from immediate value $0028
                    lbra      _rpterr   ; long branch unconditionally to _rpterr
BranchTarget_18     lbsr      Subroutine_07 ; long branch to subroutine to Subroutine_07
                    bra       Loop_09   ; branch unconditionally to Loop_09
Subroutine_06       beq       Subroutine_07 ; branch if equal/zero to Subroutine_07
                    lda       D0017,u   ; load A from indexed value D0017,u
                    beq       Subroutine_07 ; branch if equal/zero to Subroutine_07
                    lbsr      Subroutine_10 ; long branch to subroutine to Subroutine_10
                    clra                ; clear A
                    ldb       D0029,u   ; load B from indexed value D0029,u
                    addb      D0017,u   ; add indexed value D0017,u into B
                    adca      #0        ; add immediate value 0 into A
                    subd      #$0080    ; subtract immediate value $0080 from D
                    stb       D0029,u   ; store B to indexed value D0029,u
                    sta       D001d,u   ; store A to indexed value D001d,u
                    lbsr      Subroutine_05 ; long branch to subroutine to Subroutine_05
                    lda       ,u        ; load A from memory pointed to by U
                    bpl       Return_01 ; branch if plus to Return_01
                    lbra      Subroutine_13 ; long branch unconditionally to Subroutine_13
Subroutine_07       clra                ; clear A
                    sta       D0029,u   ; store A to indexed value D0029,u
                    bra       Continue_04 ; branch unconditionally to Continue_04
Subroutine_08       ldb       D0017,u   ; load B from indexed value D0017,u
                    bne       BranchTarget_19 ; branch if not equal to BranchTarget_19
                    ldd       #$0029    ; load D from immediate value $0029
                    lbra      _rpterr   ; long branch unconditionally to _rpterr
BranchTarget_19     tsta                ; test A and update condition codes
                    beq       Subroutine_07 ; branch if equal/zero to Subroutine_07
                    lbsr      Subroutine_11 ; long branch to subroutine to Subroutine_11
                    clra                ; clear A
                    ldb       D0029,u   ; load B from indexed value D0029,u
                    subb      D0017,u   ; subtract indexed value D0017,u from B
                    sbca      #0        ; subtract immediate value 0 from A
                    addd      #$0081    ; add immediate value $0081 into D
                    sta       D001d,u   ; store A to indexed value D001d,u
                    stb       D0029,u   ; store B to indexed value D0029,u
                    lda       6,u       ; load A from indexed value 6,u
                    coma
                    asra                ; arithmetic shift A right by one bit
                    ror       D0022,u   ; rotate indexed value D0022,u right through carry
                    ror       D0023,u   ; rotate indexed value D0023,u right through carry
                    ror       D0024,u   ; rotate indexed value D0024,u right through carry
                    ror       D0025,u   ; rotate indexed value D0025,u right through carry
                    ror       D0026,u   ; rotate indexed value D0026,u right through carry
                    ror       D0027,u   ; rotate indexed value D0027,u right through carry
                    ror       D0028,u   ; rotate indexed value D0028,u right through carry
                    ror       ,u        ; rotate memory pointed to by U right through carry
                    lbsr      Subroutine_05 ; long branch to subroutine to Subroutine_05
                    lda       ,u        ; load A from memory pointed to by U
                    bpl       Return_02 ; branch if plus to Return_02
                    lbra      Subroutine_13 ; long branch unconditionally to Subroutine_13
Subroutine_09       pshs      a         ; save A on the hardware stack
                    ldd       D0022,u   ; load D from indexed value D0022,u
                    std       ,u        ; store D to memory pointed to by U
                    ldd       D0024,u   ; load D from indexed value D0024,u
                    std       2,u       ; store D to indexed value 2,u
                    ldd       D0026,u   ; load D from indexed value D0026,u
                    std       4,u       ; store D to indexed value 4,u
                    ldb       D0028,u   ; load B from indexed value D0028,u
                    stb       6,u       ; store B to indexed value 6,u
                    puls      a         ; restore A from the hardware stack
Continue_04         sta       D0022,u   ; store A to indexed value D0022,u
                    sta       D0023,u   ; store A to indexed value D0023,u
                    sta       D0024,u   ; store A to indexed value D0024,u
                    sta       D0025,u   ; store A to indexed value D0025,u
                    sta       D0026,u   ; store A to indexed value D0026,u
                    sta       D0027,u   ; store A to indexed value D0027,u
                    sta       D0028,u   ; store A to indexed value D0028,u
Return_02           rts                 ; return to caller
Subroutine_10       clra                ; clear A
                    bsr       Subroutine_09 ; branch to subroutine to Subroutine_09
                    ldb       #$38      ; load B from immediate value $38
                    stb       8,u       ; store B to indexed value 8,u
Loop_10             lda       6,u       ; load A from indexed value 6,u
                    lsra                ; logical shift A right by one bit
                    bcc       BranchTarget_20 ; branch if carry is clear to BranchTarget_20
                    ldd       D0027,u   ; load D from indexed value D0027,u
                    addd      D0015,u   ; add indexed value D0015,u into D
                    std       D0027,u   ; store D to indexed value D0027,u
                    ldd       D0025,u   ; load D from indexed value D0025,u
                    adcb      D0014,u   ; add indexed value D0014,u into B
                    adca      D0013,u   ; add indexed value D0013,u into A
                    std       D0025,u   ; store D to indexed value D0025,u
                    ldd       D0023,u   ; load D from indexed value D0023,u
                    adcb      D0012,u   ; add indexed value D0012,u into B
                    adca      D0011,u   ; add indexed value D0011,u into A
                    std       D0023,u   ; store D to indexed value D0023,u
                    lda       D0022,u   ; load A from indexed value D0022,u
                    adca      D0010,u   ; add indexed value D0010,u into A
                    sta       D0022,u   ; store A to indexed value D0022,u
BranchTarget_20     ror       D0022,u   ; rotate indexed value D0022,u right through carry
                    ror       D0023,u   ; rotate indexed value D0023,u right through carry
                    ror       D0024,u   ; rotate indexed value D0024,u right through carry
                    ror       D0025,u   ; rotate indexed value D0025,u right through carry
                    ror       D0026,u   ; rotate indexed value D0026,u right through carry
                    ror       D0027,u   ; rotate indexed value D0027,u right through carry
                    ror       D0028,u   ; rotate indexed value D0028,u right through carry
                    ror       ,u        ; rotate memory pointed to by U right through carry
                    ror       1,u       ; rotate indexed value 1,u right through carry
                    ror       2,u       ; rotate indexed value 2,u right through carry
                    ror       3,u       ; rotate indexed value 3,u right through carry
                    ror       4,u       ; rotate indexed value 4,u right through carry
                    ror       5,u       ; rotate indexed value 5,u right through carry
                    ror       6,u       ; rotate indexed value 6,u right through carry
                    dec       8,u       ; decrement indexed value 8,u
                    bne       Loop_10   ; branch if not equal to Loop_10
                    rts                 ; return to caller
Subroutine_11       clra                ; clear A
                    lbsr      Subroutine_09 ; long branch to subroutine to Subroutine_09
                    ldb       #$39      ; load B from immediate value $39
                    stb       8,u       ; store B to indexed value 8,u
Loop_11             ldb       ,u        ; load B from memory pointed to by U
                    cmpb      D0010,u   ; compare B against indexed value D0010,u
                    bcs       Loop_12   ; branch if carry is set to Loop_12
                    ldd       5,u       ; load D from indexed value 5,u
                    subd      D0015,u   ; subtract indexed value D0015,u from D
                    std       13,u      ; store D to indexed value 13,u
                    ldd       3,u       ; load D from indexed value 3,u
                    sbcb      D0014,u   ; subtract indexed value D0014,u from B
                    sbca      D0013,u   ; subtract indexed value D0013,u from A
                    std       11,u      ; store D to indexed value 11,u
                    ldb       2,u       ; load B from indexed value 2,u
                    sbcb      D0012,u   ; subtract indexed value D0012,u from B
                    stb       10,u      ; store B to indexed value 10,u
                    ldd       ,u        ; load D from memory pointed to by U
                    sbcb      D0011,u   ; subtract indexed value D0011,u from B
                    sbca      D0010,u   ; subtract indexed value D0010,u from A
                    bcs       Loop_12   ; branch if carry is set to Loop_12
                    std       ,u        ; store D to memory pointed to by U
                    lda       10,u      ; load A from indexed value 10,u
                    sta       2,u       ; store A to indexed value 2,u
                    ldd       11,u      ; load D from indexed value 11,u
                    std       3,u       ; store D to indexed value 3,u
                    ldd       13,u      ; load D from indexed value 13,u
                    std       5,u       ; store D to indexed value 5,u
Loop_12             rol       D0028,u   ; rotate indexed value D0028,u left through carry
                    rol       D0027,u   ; rotate indexed value D0027,u left through carry
                    rol       D0026,u   ; rotate indexed value D0026,u left through carry
                    rol       D0025,u   ; rotate indexed value D0025,u left through carry
                    rol       D0024,u   ; rotate indexed value D0024,u left through carry
                    rol       D0023,u   ; rotate indexed value D0023,u left through carry
                    rol       D0022,u   ; rotate indexed value D0022,u left through carry
                    rol       6,u       ; rotate indexed value 6,u left through carry
                    rol       5,u       ; rotate indexed value 5,u left through carry
                    rol       4,u       ; rotate indexed value 4,u left through carry
                    rol       3,u       ; rotate indexed value 3,u left through carry
                    rol       2,u       ; rotate indexed value 2,u left through carry
                    rol       1,u       ; rotate indexed value 1,u left through carry
                    rol       ,u        ; rotate memory pointed to by U left through carry
                    dec       8,u       ; decrement indexed value 8,u
                    bhi       Loop_11   ; branch if higher to Loop_11
                    beq       BranchTarget_21 ; branch if equal/zero to BranchTarget_21
                    ldd       5,u       ; load D from indexed value 5,u
                    subd      D0015,u   ; subtract indexed value D0015,u from D
                    std       5,u       ; store D to indexed value 5,u
                    ldd       3,u       ; load D from indexed value 3,u
                    sbcb      D0014,u   ; subtract indexed value D0014,u from B
                    sbca      D0013,u   ; subtract indexed value D0013,u from A
                    std       3,u       ; store D to indexed value 3,u
                    ldd       1,u       ; load D from indexed value 1,u
                    sbcb      D0012,u   ; subtract indexed value D0012,u from B
                    sbca      D0011,u   ; subtract indexed value D0011,u from A
                    std       1,u       ; store D to indexed value 1,u
                    lda       ,u        ; load A from memory pointed to by U
                    sbca      D0010,u   ; subtract indexed value D0010,u from A
                    sta       ,u        ; store A to memory pointed to by U
                    clra                ; clear A
                    bra       Loop_12   ; branch unconditionally to Loop_12
BranchTarget_21     ror       ,u        ; rotate memory pointed to by U right through carry
                    com       D0022,u
                    com       D0023,u
                    com       D0024,u
                    com       D0025,u
                    com       D0026,u
                    com       D0027,u
                    com       D0028,u
                    rts                 ; return to caller
Subroutine_12       puls      d         ; get return address
                    pshs      u         ; save U
                    leas      -30,s     ; allocate 30 bytes
                    tfr       s,u       ; transfer stack to U
                    pshs      d         ; save return address
                    clr       D001d,u   ; clear indexed value D001d,u
                    ldd       6,x       ; get bits 15-0 of double
                    std       D0016,u   ; store on stack
                    ldd       4,x       ; get bits 31-16 of double
                    std       D0014,u   ; store on stack
                    ldd       2,x       ; get bits 47-32 of double
                    std       D0012,u   ; store on stack
                    ldd       ,x        ; get bits 63-48 of double
                    stb       D0011,u   ; store bits 55-48 on stack
                    tfr       a,b       ; copy A into B
                    sta       D001c,u   ; store bits 63-56 on stack
                    ora       #$80      ; get sign bit
                    sta       D0010,u   ; store here
                    eorb      D0022,u   ; XOR B with this location
                    stb       D0019,u   ; store it
                    lda       D0022,u   ; get byte here
                    sta       D0018,u   ; store it
                    ora       #$80      ; get sign bit
                    sta       D0022,u   ; store it
                    lda       D0029,u   ; get byte
return
                    leax      D0022,u   ; compute effective address into X from D0022,u
Continue_05         lda       #$a0      ; load A from immediate value $a0
                    sta       7,x       ; store A to indexed value 7,x
                    clr       4,x       ; clear indexed value 4,x
                    clr       5,x       ; clear indexed value 5,x
                    clr       6,x       ; clear indexed value 6,x
                    lda       ,x        ; load A from memory pointed to by X
                    tfr       a,b       ; transfer A,B
                    orb       1,x       ; OR B with indexed value 1,x
                    orb       2,x       ; OR B with indexed value 2,x
                    orb       3,x       ; OR B with indexed value 3,x
                    beq       BranchTarget_23 ; branch if equal/zero to BranchTarget_23
                    ldb       1,x       ; load B from indexed value 1,x
                    tsta                ; test A and update condition codes
                    bpl       Loop_13   ; branch if plus to Loop_13
                    pshs      d         ; save D on the hardware stack
                    clra                ; clear A
                    clrb                ; clear B
                    subd      2,x       ; subtract indexed value 2,x from D
                    std       2,x       ; store D to indexed value 2,x
                    ldd       #0        ; load D from immediate value 0
                    sbcb      1,s       ; subtract stack-relative value 1,s from B
                    sbca      ,s        ; subtract memory pointed to by S from A
                    leas      2,s       ; adjust S using 2,s
                    bvs       Label_01
Loop_13             dec       7,x       ; decrement indexed value 7,x
                    asl       3,x       ; shift indexed value 3,x left by one bit
                    rol       2,x       ; rotate indexed value 2,x left through carry
                    rolb                ; rotate B left through carry
                    rola                ; rotate A left through carry
                    bpl       Loop_13   ; branch if plus to Loop_13
Label_01            anda      #$7f      ; AND A with immediate value $7f
                    tst       ,x        ; test memory pointed to by X and update condition codes
                    bpl       BranchTarget_22 ; branch if plus to BranchTarget_22
                    ora       #$80      ; OR A with immediate value $80
BranchTarget_22     std       ,x        ; store D to memory pointed to by X
                    rts                 ; return to caller
                    leax      D0022,u   ; compute effective address into X from D0022,u
                    clr       4,x       ; clear indexed value 4,x
                    clr       5,x       ; clear indexed value 5,x
                    clr       6,x       ; clear indexed value 6,x
BranchTarget_23     clr       7,x       ; clear indexed value 7,x
Loop_14             clr       ,x        ; clear memory pointed to by X
                    clr       1,x       ; clear indexed value 1,x
                    clr       2,x       ; clear indexed value 2,x
                    clr       3,x       ; clear indexed value 3,x
                    rts                 ; return to caller
Loop_15             ldd       #$002a    ; load D from immediate value $002a
                    lbra      _rpterr   ; long branch unconditionally to _rpterr
                    leax      D0022,u   ; compute effective address into X from D0022,u
Continue_06         ldb       7,x       ; load B from indexed value 7,x
                    beq       Loop_14   ; branch if equal/zero to Loop_14
                    subb      #$81      ; subtract immediate value $81 from B
                    bcs       BranchTarget_28 ; branch if carry is set to BranchTarget_28
                    negb                ; negate B
                    addb      #$1f      ; add immediate value $1f into B
                    bmi       Loop_15   ; branch if minus to Loop_15
                    bne       BranchTarget_24 ; branch if not equal to BranchTarget_24
                    ldd       ,x        ; load D from memory pointed to by X
                    cmpd      #$8000    ; compare D against immediate value $8000
                    bne       Loop_15   ; branch if not equal to Loop_15
                    lda       2,x       ; load A from indexed value 2,x
                    ora       3,x       ; OR A with indexed value 3,x
                    ora       4,x       ; OR A with indexed value 4,x
                    ora       5,x       ; OR A with indexed value 5,x
                    ora       6,x       ; OR A with indexed value 6,x
                    bne       Loop_15   ; branch if not equal to Loop_15
                    rts                 ; return to caller
BranchTarget_24     pshs      b         ; save B on the hardware stack
                    ldd       ,x        ; load D from memory pointed to by X
                    bmi       BranchTarget_25 ; branch if minus to BranchTarget_25
                    ora       #$80      ; OR A with immediate value $80
Loop_16             lsra                ; logical shift A right by one bit
                    rorb                ; rotate B right through carry
                    ror       2,x       ; rotate indexed value 2,x right through carry
                    ror       3,x       ; rotate indexed value 3,x right through carry
                    dec       ,s        ; decrement memory pointed to by S
                    bne       Loop_16   ; branch if not equal to Loop_16
                    std       ,x        ; store D to memory pointed to by X
                    puls      b,pc      ; restore registers and return
BranchTarget_25     clr       ,-s       ; clear memory pointed to by -S
Loop_17             lsra                ; logical shift A right by one bit
                    rorb                ; rotate B right through carry
                    ror       2,x       ; rotate indexed value 2,x right through carry
                    ror       3,x       ; rotate indexed value 3,x right through carry
                    ror       4,x       ; rotate indexed value 4,x right through carry
                    ror       5,x       ; rotate indexed value 5,x right through carry
                    ror       6,x       ; rotate indexed value 6,x right through carry
                    bcc       BranchTarget_26 ; branch if carry is clear to BranchTarget_26
                    inc       ,s        ; increment memory pointed to by S
BranchTarget_26     dec       1,s       ; decrement stack-relative value 1,s
                    bne       Loop_17   ; branch if not equal to Loop_17
                    std       ,x        ; store D to memory pointed to by X
                    ldd       ,s++      ; load D from memory pointed to by S+, then advance S+
                    bne       BranchTarget_27 ; branch if not equal to BranchTarget_27
                    lda       4,x       ; load A from indexed value 4,x
                    ora       5,x       ; OR A with indexed value 5,x
                    ora       6,x       ; OR A with indexed value 6,x
                    beq       ReturnZero_01 ; branch if equal/zero to ReturnZero_01
BranchTarget_27     ldd       2,x       ; load D from indexed value 2,x
                    addd      #1        ; add immediate value 1 into D
                    std       2,x       ; store D to indexed value 2,x
                    ldd       ,x        ; load D from memory pointed to by X
                    adcb      #0        ; add immediate value 0 into B
                    adca      #0        ; add immediate value 0 into A
                    bcs       Loop_15   ; branch if carry is set to Loop_15
                    std       ,x        ; store D to memory pointed to by X
ReturnZero_01       clra                ; clear A
                    clrb                ; clear B
                    subd      2,x       ; subtract indexed value 2,x from D
                    std       2,x       ; store D to indexed value 2,x
                    ldd       #0        ; load D from immediate value 0
                    sbcb      1,x       ; subtract indexed value 1,x from B
                    sbca      ,x        ; subtract memory pointed to by X from A
                    std       ,x        ; store D to memory pointed to by X
                    rts                 ; return to caller
BranchTarget_28     lda       ,x        ; load A from memory pointed to by X
                    lbpl      Loop_14   ; long branch if plus to Loop_14
                    ldd       #-1       ; load D from immediate value -1
                    std       2,x       ; store D to indexed value 2,x
                    std       ,x        ; store D to memory pointed to by X
                    rts                 ; return to caller
Subroutine_13       inc       D0028,u   ; increment indexed value D0028,u
                    bne       Return_03 ; branch if not equal to Return_03
                    inc       D0027,u   ; increment indexed value D0027,u
                    bne       Return_03 ; branch if not equal to Return_03
                    inc       D0026,u   ; increment indexed value D0026,u
                    bne       Return_03 ; branch if not equal to Return_03
                    inc       D0025,u   ; increment indexed value D0025,u
                    bne       Return_03 ; branch if not equal to Return_03
                    inc       D0024,u   ; increment indexed value D0024,u
                    bne       Return_03 ; branch if not equal to Return_03
                    inc       D0023,u   ; increment indexed value D0023,u
                    bne       Return_03 ; branch if not equal to Return_03
                    ldb       D0022,u   ; load B from indexed value D0022,u
                    tfr       b,a       ; transfer B,A
                    anda      #$7f      ; AND A with immediate value $7f
                    inca                ; increment A
                    bpl       BranchTarget_29 ; branch if plus to BranchTarget_29
                    inc       D0029,u   ; increment indexed value D0029,u
                    anda      #$7f      ; AND A with immediate value $7f
BranchTarget_29     andb      #$80      ; AND B with immediate value $80
                    pshs      b         ; save B on the hardware stack
                    adda      ,s+       ; add memory pointed to by S, then advance S into A
                    sta       D0022,u   ; store A to indexed value D0022,u
Return_03           rts                 ; return to caller
Label_02            neg       D0000     ; negate D0000
                    neg       D0000     ; negate D0000
                    neg       D0000     ; negate D0000
                    neg       D0081     ; negate D0081
                    leax      >Label_02,pcr ; compute effective address into X from >Label_02,pcr
Subroutine_14       pshs      a         ; save A on the hardware stack
                    ldd       ,x        ; load D from memory pointed to by X
                    std       D0022,u   ; store D to indexed value D0022,u
                    ldd       2,x       ; load D from indexed value 2,x
                    std       D0024,u   ; store D to indexed value D0024,u
                    ldd       4,x       ; load D from indexed value 4,x
                    std       D0026,u   ; store D to indexed value D0026,u
                    ldd       6,x       ; load D from indexed value 6,x
                    std       D0028,u   ; store D to indexed value D0028,u
                    puls      a,pc      ; restore registers and return
Subroutine_15       pshs      a         ; save A on the hardware stack
                    ldd       D0022,u   ; load D from indexed value D0022,u
                    std       ,x        ; store D to memory pointed to by X
                    ldd       D0024,u   ; load D from indexed value D0024,u
                    std       2,x       ; store D to indexed value 2,x
                    ldd       D0026,u   ; load D from indexed value D0026,u
                    std       4,x       ; store D to indexed value 4,x
                    ldd       D0028,u   ; load D from indexed value D0028,u
                    std       6,x       ; store D to indexed value 6,x
                    puls      a,pc      ; restore registers and return
_xtofla:            ldd       ,x        ; load D from memory pointed to by X
Continue_07         std       _flacc,y  ; store D to indexed value _flacc,y
                    ldd       2,x       ; load D from indexed value 2,x
                    std       _flacc+2,y ; store D to indexed value _flacc+2,y
                    ldd       4,x       ; load D from indexed value 4,x
                    std       _flacc+4,y ; store D to indexed value _flacc+4,y
                    ldd       6,x       ; load D from indexed value 6,x
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    std       6,x       ; store D to indexed value 6,x
                    rts                 ; return to caller
_dinc:              pshs      x         ; save X on the hardware stack
                    bsr       _dstack   ; branch to subroutine to _dstack
                    leax      <Label_02,pcr ; compute effective address into X from <Label_02,pcr
                    pshs      x         ; save X on the hardware stack
                    lbsr      Subroutine_12 ; long branch to subroutine to Subroutine_12
                    lbsr      Subroutine_03 ; long branch to subroutine to Subroutine_03
Loop_18             ldx       D002a,u   ; load X from indexed value D002a,u
                    bsr       Subroutine_15 ; branch to subroutine to Subroutine_15
                    ldx       D001e,u   ; load X from indexed value D001e,u
                    leas      D002a,u   ; adjust S using D002a,u
                    tfr       x,u       ; transfer X,U
                    puls      x,pc      ; restore registers and return
_ddec:              pshs      x         ; save X on the hardware stack
                    bsr       _dstack   ; branch to subroutine to _dstack
                    leax      >Label_02,pcr ; compute effective address into X from >Label_02,pcr
                    pshs      x         ; save X on the hardware stack
                    lbsr      Subroutine_12 ; long branch to subroutine to Subroutine_12
                    lbsr      Subroutine_02 ; long branch to subroutine to Subroutine_02
                    bra       Loop_18   ; branch unconditionally to Loop_18
_finc:              pshs      x         ; save X on the hardware stack
                    bsr       _fstack   ; branch to subroutine to _fstack
                    leax      Label_02,pcr ; compute effective address into X from Label_02,pcr
                    pshs      x         ; save X on the hardware stack
                    lbsr      Subroutine_12 ; long branch to subroutine to Subroutine_12
                    lbsr      Subroutine_03 ; long branch to subroutine to Subroutine_03
Loop_19             ldx       D002a,u   ; load X from indexed value D002a,u
                    ldd       D0022,u   ; load D from indexed value D0022,u
                    std       ,x        ; store D to memory pointed to by X
                    lda       D0024,u   ; load A from indexed value D0024,u
                    ldb       D0029,u   ; load B from indexed value D0029,u
                    std       2,x       ; store D to indexed value 2,x
                    ldx       D001e,u   ; load X from indexed value D001e,u
                    leas      D002a,u   ; adjust S using D002a,u
                    tfr       x,u       ; transfer X,U
                    puls      x,pc      ; restore registers and return
_fdec:              pshs      x         ; save X on the hardware stack
                    bsr       _fstack   ; branch to subroutine to _fstack
                    leax      Label_02,pcr ; compute effective address into X from Label_02,pcr
                    pshs      x         ; save X on the hardware stack
                    lbsr      Subroutine_12 ; long branch to subroutine to Subroutine_12
                    lbsr      Subroutine_02 ; long branch to subroutine to Subroutine_02
                    bra       Loop_19   ; branch unconditionally to Loop_19
_fstack:            leas      -8,s      ; adjust S using -8,s
                    ldd       8,s       ; load D from stack-relative value 8,s
                    std       ,s        ; store D to memory pointed to by S
                    clra                ; clear A
                    clrb                ; clear B
                    std       5,s       ; store D to stack-relative value 5,s
                    std       7,s       ; store D to stack-relative value 7,s
                    ldd       ,x        ; load D from memory pointed to by X
                    std       2,s       ; store D to stack-relative value 2,s
                    ldd       2,x       ; load D from indexed value 2,x
                    sta       4,s       ; store A to stack-relative value 4,s
                    stb       9,s       ; store B to stack-relative value 9,s
                    rts                 ; return to caller
_dstack:            leas      -8,s      ; adjust S using -8,s
                    ldd       8,s       ; load D from stack-relative value 8,s
                    std       ,s        ; store D to memory pointed to by S
                    ldd       ,x        ; load D from memory pointed to by X
                    std       2,s       ; store D to stack-relative value 2,s
                    ldd       2,x       ; load D from indexed value 2,x
                    std       4,s       ; store D to stack-relative value 4,s
                    ldd       4,x       ; load D from indexed value 4,x
                    std       6,s       ; store D to stack-relative value 6,s
                    ldd       6,x       ; load D from indexed value 6,x
                    std       8,s       ; store D to stack-relative value 8,s
                    rts                 ; return to caller
_fmove:             pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    exg       x,u       ; exchange X,U
                    ldd       ,u        ; load D from memory pointed to by U
                    std       ,x        ; store D to memory pointed to by X
                    ldd       2,u       ; load D from indexed value 2,u
                    std       2,x       ; store D to indexed value 2,x
                    bra       Continue_08 ; branch unconditionally to Continue_08

* move double
* entry:
* X   = address of src - 8 byte double
* 2,s = address of destination
_dmove:             pshs      u         ; save U on the hardware stack
                    ldu       2+2,s     ; get ptr to double in U
                    exg       x,u       ; swap so that U points to src, X points to destination
                    ldd       ,u        ; get 2 bytes from src
                    std       ,x        ; save it
                    ldd       2,u       ; get next 2 bytes from src
                    std       2,x       ; save it
                    ldd       4,u       ; get next 2 bytes from src
                    std       4,x       ; save it
                    ldd       6,u       ; get next 2 bytes from src
                    std       6,x       ; save it
Continue_08         puls      u         ; recover U pushed earlier
                    puls      d         ; get return address off stack
                    std       ,s        ; save back and return
                    rts                 ; return to caller


* XXX: Should be in the compiler's runtime/builtin
copyDWord           IMPORT
copySingle          EXPORT              ; export this symbol
copySingle
                    lbra      copyDWord ; long branch unconditionally to copyDWord

* XXX: Should be in the compiler's runtime/builtin
divSingleSingle     EXPORT              ; export this symbol
divSingleSingle
                    rts                 ; return to caller

* XXX: Should be in the compiler's runtime/builtin
mulSingleSingle     EXPORT              ; export this symbol
mulSingleSingle
                    rts                 ; return to caller

* XXX: Should be in the compiler's runtime/builtin
cmpSingleSingle     EXPORT              ; export this symbol
cmpSingleSingle                         ; compare   SINGLESINGLE against the current operand
                    rts                 ; return to caller

* XXX: Should be in the compiler's runtime/builtin
isSingleZero        EXPORT              ; export this symbol
isSingleZero
                    rts                 ; return to caller

* XXX: Should be in the compiler's runtime/builtin
subSingleSingle     EXPORT              ; export this symbol
subSingleSingle
                    rts                 ; return to caller

                    endsect             ; end current section

