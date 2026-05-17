* Adapted from cmoc_os9/lib/todo/qsort.a for the live cmoc_os9 ABI.

                    section   bss       ; begin bss section

_B0000              rmb       2         ; reserve 2 bytes
_B0002              rmb       2         ; reserve 2 bytes

                    endsect             ; end current section

                    section   code      ; begin code section

_qsort              EXPORT              ; export this symbol

_stkcheck           EXTERNAL            ; import external symbol
ccdiv               EXTERNAL            ; import external symbol
ccmult              EXTERNAL            ; import external symbol

_qsort
                    pshs      u         ; save U on the hardware stack
                    ldd       #$ffb8    ; load D from immediate value $ffb8
                    lbsr      _stkcheck ; long branch to subroutine to _stkcheck
                    ldd       8,s       ; load D from stack-relative value 8,s
                    std       _B0000,y  ; store D to indexed value _B0000,y
                    ldd       10,s      ; load D from stack-relative value 10,s
                    std       _B0002,y  ; store D to indexed value _B0002,y
                    ldd       6,s       ; load D from stack-relative value 6,s
                    addd      #-1       ; add immediate value -1 into D
                    pshs      d         ; save D on the hardware stack
                    ldd       _B0000,y  ; load D from indexed value _B0000,y
                    lbsr      ccmult    ; long branch to subroutine to ccmult
                    addd      4,s       ; add stack-relative value 4,s into D
                    pshs      d         ; save D on the hardware stack
                    ldd       6,s       ; load D from stack-relative value 6,s
                    pshs      d         ; save D on the hardware stack
                    bsr       Subroutine_01 ; branch to subroutine to Subroutine_01
                    lbra      Continue_03 ; long branch unconditionally to Continue_03

Subroutine_01
                    pshs      u         ; save U on the hardware stack
                    ldd       #$ffb4    ; load D from immediate value $ffb4
                    lbsr      _stkcheck ; long branch to subroutine to _stkcheck
                    leas      -4,s      ; adjust S using -4,s
                    lbra      Continue_02 ; long branch unconditionally to Continue_02

Loop_01
                    ldu       8,s       ; load U from stack-relative value 8,s
                    ldd       10,s      ; load D from stack-relative value 10,s
                    std       2,s       ; store D to stack-relative value 2,s
                    ldd       10,s      ; load D from stack-relative value 10,s
                    subd      8,s       ; subtract stack-relative value 8,s from D
                    pshs      d         ; save D on the hardware stack
                    ldd       _B0000,y  ; load D from indexed value _B0000,y
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    lbsr      ccdiv     ; long branch to subroutine to ccdiv
                    pshs      d         ; save D on the hardware stack
                    ldd       _B0000,y  ; load D from indexed value _B0000,y
                    lbsr      ccmult    ; long branch to subroutine to ccmult
                    addd      8,s       ; add stack-relative value 8,s into D
                    std       ,s        ; store D to memory pointed to by S
                    bra       Loop_03   ; branch unconditionally to Loop_03

Loop_02
                    ldd       _B0000,y  ; load D from indexed value _B0000,y
                    leau      d,u       ; compute effective address into U from d,u

Loop_03
                    ldd       ,s        ; load D from memory pointed to by S
                    pshs      d         ; save D on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    jsr       [_B0002,y] ; call subroutine at [_B0002,y]
                    leas      4,s       ; adjust S using 4,s
                    std       -2,s      ; store D to stack-relative value -2,s
                    blt       Loop_02   ; branch if less than to Loop_02
                    bra       Continue_01 ; branch unconditionally to Continue_01

Loop_04
                    ldd       2,s       ; load D from stack-relative value 2,s
                    subd      _B0000,y  ; subtract indexed value _B0000,y from D
                    std       2,s       ; store D to stack-relative value 2,s

Continue_01
                    ldd       2,s       ; load D from stack-relative value 2,s
                    pshs      d         ; save D on the hardware stack
                    ldd       2,s       ; load D from stack-relative value 2,s
                    pshs      d         ; save D on the hardware stack
                    jsr       [_B0002,y] ; call subroutine at [_B0002,y]
                    leas      4,s       ; adjust S using 4,s
                    std       -2,s      ; store D to stack-relative value -2,s
                    blt       Loop_04   ; branch if less than to Loop_04
                    cmpu      2,s       ; compare U against stack-relative value 2,s
                    bhi       BranchTarget_03 ; branch if higher to BranchTarget_03
                    cmpu      2,s       ; compare U against stack-relative value 2,s
                    bcc       BranchTarget_02 ; branch if carry is clear to BranchTarget_02
                    ldd       2,s       ; load D from stack-relative value 2,s
                    pshs      d         ; save D on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    lbsr      Subroutine_02 ; long branch to subroutine to Subroutine_02
                    leas      4,s       ; adjust S using 4,s
                    cmpu      ,s        ; compare U against memory pointed to by S
                    bne       BranchTarget_01 ; branch if not equal to BranchTarget_01
                    ldd       2,s       ; load D from stack-relative value 2,s
                    std       ,s        ; store D to memory pointed to by S
                    bra       BranchTarget_02 ; branch unconditionally to BranchTarget_02

BranchTarget_01
                    ldd       ,s        ; load D from memory pointed to by S
                    cmpd      2,s       ; compare D against stack-relative value 2,s
                    bne       BranchTarget_02 ; branch if not equal to BranchTarget_02
                    stu       ,s        ; store U to memory pointed to by S

BranchTarget_02
                    ldd       _B0000,y  ; load D from indexed value _B0000,y
                    leau      d,u       ; compute effective address into U from d,u
                    ldd       2,s       ; load D from stack-relative value 2,s
                    subd      _B0000,y  ; subtract indexed value _B0000,y from D
                    std       2,s       ; store D to stack-relative value 2,s

BranchTarget_03
                    cmpu      2,s       ; compare U against stack-relative value 2,s
                    lbls      Loop_03   ; long branch if lower or same to Loop_03
                    ldd       2,s       ; load D from stack-relative value 2,s
                    subd      8,s       ; subtract stack-relative value 8,s from D
                    pshs      d         ; save D on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    ldd       14,s      ; load D from stack-relative value 14,s
                    subd      ,s++      ; subtract memory pointed to by S+, then advance S+ from D
                    cmpd      ,s++      ; compare D against memory pointed to by S+, then advance S+
                    bge       BranchTarget_04 ; branch if greater or equal to BranchTarget_04
                    ldd       10,s      ; load D from stack-relative value 10,s
                    pshs      d         ; save D on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    lbsr      Subroutine_01 ; long branch to subroutine to Subroutine_01
                    leas      4,s       ; adjust S using 4,s
                    ldd       2,s       ; load D from stack-relative value 2,s
                    std       10,s      ; store D to stack-relative value 10,s
                    bra       Continue_02 ; branch unconditionally to Continue_02

BranchTarget_04
                    ldd       2,s       ; load D from stack-relative value 2,s
                    pshs      d         ; save D on the hardware stack
                    ldd       10,s      ; load D from stack-relative value 10,s
                    pshs      d         ; save D on the hardware stack
                    lbsr      Subroutine_01 ; long branch to subroutine to Subroutine_01
                    leas      4,s       ; adjust S using 4,s
                    stu       8,s       ; store U to stack-relative value 8,s

Continue_02
                    ldd       8,s       ; load D from stack-relative value 8,s
                    cmpd      10,s      ; compare D against stack-relative value 10,s
                    lblo      Loop_01   ; long branch if lower to Loop_01

Continue_03
                    leas      4,s       ; adjust S using 4,s
                    puls      u,pc      ; restore registers and return

Subroutine_02
                    pshs      u         ; save U on the hardware stack
                    ldd       #$ffbd    ; load D from immediate value $ffbd
                    lbsr      _stkcheck ; long branch to subroutine to _stkcheck
                    ldu       4,s       ; load U from stack-relative value 4,s
                    leas      -3,s      ; adjust S using -3,s
                    ldd       _B0000,y  ; load D from indexed value _B0000,y
                    std       1,s       ; store D to stack-relative value 1,s
                    bra       Continue_04 ; branch unconditionally to Continue_04

Loop_05
                    ldb       ,u        ; load B from memory pointed to by U
                    stb       ,s        ; store B to memory pointed to by S
                    ldb       [9,s]     ; load B from indirect address [9,s]
                    stb       ,u+       ; store B to memory pointed to by U, then advance U
                    ldb       ,s        ; load B from memory pointed to by S
                    ldx       9,s       ; load X from stack-relative value 9,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       9,s       ; store X to stack-relative value 9,s
                    stb       -1,x      ; store B to indexed value -1,x

Continue_04
                    ldd       1,s       ; load D from stack-relative value 1,s
                    addd      #-1       ; add immediate value -1 into D
                    std       1,s       ; store D to stack-relative value 1,s
                    subd      #-1       ; subtract immediate value -1 from D
                    bne       Loop_05   ; branch if not equal to Loop_05
                    leas      3,s       ; adjust S using 3,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
