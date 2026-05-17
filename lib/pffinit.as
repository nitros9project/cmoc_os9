* Disassembly by Os9disasm of _pffinit.r

                    section   bss       ; begin bss section

* Uninitialized data (class D)
D0000               rmb       1         ; reserve 1 bytes
* Initialized Data (class H)

                    endsect             ; end current section


                    section   bss       ; begin bss section

* Uninitialized data (class B)
B0000               rmb       1         ; reserve 1 bytes
B0001               rmb       29        ; reserve 29 bytes
B001e               rmb       0         ; reserve 0 bytes

                    endsect             ; end current section

                    section   rodata    ; begin rodata section

* Initialized Data (class G)
G0000               fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $81       ; define byte data $81
                    fcb       $4c       ; define byte data $4c
                    fcb       $cc       ; define byte data $cc
                    fcb       $cc       ; define byte data $cc
                    fcb       $cc       ; define byte data $cc
                    fcb       $cc       ; define byte data $cc
                    fcb       $cc       ; define byte data $cc
                    fcb       $cd       ; define byte data $cd
                    fcb       $7d       ; define byte data $7d
                    fcb       $23       ; define byte data $23
                    fcb       $d7       ; define byte data $d7
                    fcb       $0a       ; define byte data $0a
                    fcb       $3d       ; define byte data $3d
                    fcb       $70       ; define byte data $70
                    fcb       $a3       ; define byte data $a3
                    fcb       $d7       ; define byte data $d7
                    fcb       $7a       ; define byte data $7a
                    fcb       $03       ; define byte data $03
                    fcb       $12       ; define byte data $12
                    fcb       $6e       ; define byte data $6e
                    fcb       $97       ; define byte data $97
                    fcb       $8d       ; define byte data $8d
                    fcb       $4f       ; define byte data $4f
                    fcb       $df       ; define byte data $df
                    fcb       $77       ; define byte data $77
                    fcb       $51       ; define byte data $51
                    fcb       $b7       ; define byte data $b7
                    fcb       $17       ; define byte data $17
                    fcb       $58       ; define byte data $58
                    fcb       $e2       ; define byte data $e2
                    fcb       $19       ; define byte data $19
                    fcb       $65       ; define byte data $65
                    fcb       $73       ; define byte data $73
                    fcb       $27       ; define byte data $27
                    fcb       $c5       ; define byte data $c5
                    fcb       $ac       ; define byte data $ac
                    fcb       $47       ; define byte data $47
                    fcb       $1b       ; define byte data $1b
                    fcb       $47       ; define byte data $47
                    fcb       $84       ; define byte data $84
                    fcb       $70       ; define byte data $70
                    fcb       $06       ; define byte data $06
                    fcb       $37       ; define byte data $37
                    fcb       $bd       ; define byte data $bd
                    fcb       $05       ; define byte data $05
                    fcb       $af       ; define byte data $af
                    fcb       $6c       ; define byte data $6c
                    fcb       $6a       ; define byte data $6a
                    fcb       $6d       ; define byte data $6d
                    fcb       $56       ; define byte data $56
                    fcb       $bf       ; define byte data $bf
                    fcb       $94       ; define byte data $94
                    fcb       $d5       ; define byte data $d5
                    fcb       $e5       ; define byte data $e5
                    fcb       $7a       ; define byte data $7a
                    fcb       $43       ; define byte data $43
                    fcb       $69       ; define byte data $69
                    fcb       $2b       ; define byte data $2b
                    fcb       $cc       ; define byte data $cc
                    fcb       $77       ; define byte data $77
                    fcb       $11       ; define byte data $11
                    fcb       $84       ; define byte data $84
                    fcb       $61       ; define byte data $61
                    fcb       $cf       ; define byte data $cf
                    fcb       $66       ; define byte data $66
                    fcb       $09       ; define byte data $09
                    fcb       $70       ; define byte data $70
                    fcb       $5f       ; define byte data $5f
                    fcb       $41       ; define byte data $41
                    fcb       $36       ; define byte data $36
                    fcb       $b4       ; define byte data $b4
                    fcb       $a6       ; define byte data $a6
                    fcb       $63       ; define byte data $63
                    fcb       $5b       ; define byte data $5b
                    fcb       $e6       ; define byte data $e6
                    fcb       $fe       ; define byte data $fe
                    fcb       $ce       ; define byte data $ce
                    fcb       $bd       ; define byte data $bd
                    fcb       $ed       ; define byte data $ed
                    fcb       $d6       ; define byte data $d6
                    fcb       $5f       ; define byte data $5f
                    fcb       $2f       ; define byte data $2f
                    fcb       $eb       ; define byte data $eb
                    fcb       $ff       ; define byte data $ff
                    fcb       $0b       ; define byte data $0b
                    fcb       $cb       ; define byte data $cb
                    fcb       $24       ; define byte data $24
                    fcb       $ab       ; define byte data $ab
                    fcb       $5c       ; define byte data $5c
                    fcb       $0c       ; define byte data $0c
                    fcb       $bc       ; define byte data $bc
                    fcb       $cc       ; define byte data $cc
                    fcb       $09       ; define byte data $09
                    fcb       $6f       ; define byte data $6f
                    fcb       $50       ; define byte data $50
                    fcb       $89       ; define byte data $89
                    fcb       $59       ; define byte data $59
                    fcb       $61       ; define byte data $61
                    fcb       $2e       ; define byte data $2e
                    fcb       $13       ; define byte data $13
                    fcb       $42       ; define byte data $42
                    fcb       $4b       ; define byte data $4b
                    fcb       $b4       ; define byte data $b4
                    fcb       $0e       ; define byte data $0e
                    fcb       $55       ; define byte data $55
                    fcb       $34       ; define byte data $34
                    fcb       $24       ; define byte data $24
                    fcb       $dc       ; define byte data $dc
                    fcb       $35       ; define byte data $35
                    fcb       $09       ; define byte data $09
                    fcb       $5c       ; define byte data $5c
                    fcb       $d8       ; define byte data $d8
                    fcb       $52       ; define byte data $52
                    fcb       $10       ; define byte data $10
                    fcb       $1d       ; define byte data $1d
                    fcb       $7c       ; define byte data $7c
                    fcb       $f7       ; define byte data $f7
                    fcb       $3a       ; define byte data $3a
                    fcb       $b0       ; define byte data $b0
                    fcb       $ad       ; define byte data $ad
                    fcb       $4f       ; define byte data $4f
                    fcb       $66       ; define byte data $66
                    fcb       $95       ; define byte data $95
                    fcb       $94       ; define byte data $94
                    fcb       $be       ; define byte data $be
                    fcb       $c4       ; define byte data $c4
                    fcb       $4d       ; define byte data $4d
                    fcb       $e1       ; define byte data $e1
                    fcb       $4b       ; define byte data $4b
                    fcb       $38       ; define byte data $38
                    fcb       $77       ; define byte data $77
                    fcb       $aa       ; define byte data $aa
                    fcb       $32       ; define byte data $32
                    fcb       $36       ; define byte data $36
                    fcb       $a4       ; define byte data $a4
                    fcb       $b4       ; define byte data $b4
                    fcb       $48       ; define byte data $48
G0090               fdb       G0090     ; define word data G0090

                    endsect             ; end current section

                    section   code      ; begin code section

_pffinit            EXPORT              ; export this symbol
_pffloat            EXPORT              ; export this symbol
_chcodes            EXTERNAL            ; import external symbol
__iob               EXTERNAL            ; import external symbol
_fprintf            EXTERNAL            ; import external symbol
_exit               EXTERNAL            ; import external symbol
_dmove              EXTERNAL            ; import external symbol
_dstack             EXTERNAL            ; import external symbol
_dmul               EXTERNAL            ; import external symbol
_dcmpr              EXTERNAL            ; import external symbol
_ddiv               EXTERNAL            ; import external symbol
_scale              EXTERNAL            ; import external symbol
ccmult              EXTERNAL            ; import external symbol
ccasr               EXTERNAL            ; import external symbol
ccdiv               EXTERNAL            ; import external symbol
ccmod               EXTERNAL            ; import external symbol

_pffinit:           pshs      u         ; save U on the hardware stack
                    puls      u,pc      ; restore registers and return
_pffloat:           pshs      d,u       ; save D,U on the hardware stack
                    ldx       6,s       ; load X from stack-relative value 6,s
                    bra       Continue_02 ; branch unconditionally to Continue_02
Loop_01             ldd       #1        ; load D from immediate value 1
                    bra       Continue_01 ; branch unconditionally to Continue_01
Loop_02             ldd       #-1       ; load D from immediate value -1
                    bra       Continue_01 ; branch unconditionally to Continue_01
Loop_03             clra                ; clear A
                    clrb                ; clear B
Continue_01         std       ,s        ; store D to memory pointed to by S
                    bra       Continue_03 ; branch unconditionally to Continue_03
Continue_02         cmpx      #'f
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    cmpx      #'e
                    beq       Loop_02   ; branch if equal/zero to Loop_02
                    cmpx      #'E
                    lbeq      Loop_02   ; long branch if equal/zero to Loop_02
                    cmpx      #'g
                    beq       Loop_03   ; branch if equal/zero to Loop_03
                    cmpx      #'G
                    lbeq      Loop_03   ; long branch if equal/zero to Loop_03
Continue_03         ldd       6,s       ; load D from stack-relative value 6,s
                    leax      _chcodes,y ; compute effective address into X from _chcodes,y
                    leax      d,x       ; compute effective address into X from d,x
                    ldb       ,x        ; load B from memory pointed to by X
                    clra                ; clear A
                    andb      #2        ; AND B with immediate value 2
                    pshs      d         ; save D on the hardware stack
                    ldd       2,s       ; load D from stack-relative value 2,s
                    pshs      d         ; save D on the hardware stack
                    ldd       12,s      ; load D from stack-relative value 12,s
                    pshs      d         ; save D on the hardware stack
                    ldd       [16,s]    ; load D from indirect address [16,s]
                    addd      #8        ; add immediate value 8 into D
                    std       [16,s]    ; store D to indirect address [16,s]
                    subd      #8        ; subtract immediate value 8 from D
                    pshs      d         ; save D on the hardware stack
                    bsr       Subroutine_01 ; branch to subroutine to Subroutine_01
                    leas      8,s       ; adjust S using 8,s
                    leas      2,s       ; adjust S using 2,s
                    puls      u,pc      ; restore registers and return
Subroutine_01       pshs      u         ; save U on the hardware stack
                    leas      -32,s     ; adjust S using -32,s
                    ldd       #1        ; load D from immediate value 1
                    std       8,s       ; store D to stack-relative value 8,s
                    leax      ,s        ; compute effective address into X from ,s
                    pshs      x         ; save X on the hardware stack
                    ldx       38,s      ; load X from stack-relative value 38,s
                    lbsr      _dmove    ; long branch to subroutine to _dmove
                    leau      ,s        ; compute effective address into U from ,s
                    ldb       7,u       ; load B from indexed value 7,u
                    bne       BranchTarget_01 ; branch if not equal to BranchTarget_01
                    clra                ; clear A
                    clrb                ; clear B
                    std       24,s      ; store D to stack-relative value 24,s
                    std       26,s      ; store D to stack-relative value 26,s
                    std       18,s      ; store D to stack-relative value 18,s
                    leax      32,s      ; compute effective address into X from 32,s
                    lbra      Continue_09 ; long branch unconditionally to Continue_09
BranchTarget_01     ldb       7,u       ; load B from indexed value 7,u
                    clra                ; clear A
                    addd      #-128     ; add immediate value -128 into D
                    std       22,s      ; store D to stack-relative value 22,s
                    bge       ReturnZero_01 ; branch if greater or equal to ReturnZero_01
                    ldd       22,s      ; load D from stack-relative value 22,s
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    std       22,s      ; store D to stack-relative value 22,s
                    ldd       #1        ; load D from immediate value 1
                    bra       Continue_04 ; branch unconditionally to Continue_04
ReturnZero_01       clra                ; clear A
                    clrb                ; clear B
Continue_04         std       24,s      ; store D to stack-relative value 24,s
                    ldd       22,s      ; load D from stack-relative value 22,s
                    pshs      d         ; save D on the hardware stack
                    ldd       #78       ; load D from immediate value 78
                    lbsr      ccmult    ; long branch to subroutine to ccmult
                    pshs      d         ; save D on the hardware stack
                    ldd       #8        ; load D from immediate value 8
                    lbsr      ccasr     ; long branch to subroutine to ccasr
                    std       20,s      ; store D to stack-relative value 20,s
                    ldd       24,s      ; load D from stack-relative value 24,s
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
                    ldd       20,s      ; load D from stack-relative value 20,s
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    bra       Continue_05 ; branch unconditionally to Continue_05
BranchTarget_02     ldd       20,s      ; load D from stack-relative value 20,s
Continue_05         addd      #1        ; add immediate value 1 into D
                    std       18,s      ; store D to stack-relative value 18,s
                    ldb       ,u        ; load B from memory pointed to by U
                    bge       ReturnZero_02 ; branch if greater or equal to ReturnZero_02
                    ldb       ,u        ; load B from memory pointed to by U
                    clra                ; clear A
                    andb      #$7f      ; AND B with immediate value $7f
                    stb       ,u        ; store B to memory pointed to by U
                    ldd       #1        ; load D from immediate value 1
                    bra       Continue_06 ; branch unconditionally to Continue_06
ReturnZero_02       clra                ; clear A
                    clrb                ; clear B
Continue_06         std       26,s      ; store D to stack-relative value 26,s
                    leax      ,s        ; compute effective address into X from ,s
                    pshs      x         ; save X on the hardware stack
                    ldd       26,s      ; load D from stack-relative value 26,s
                    pshs      d         ; save D on the hardware stack
                    ldd       24,s      ; load D from stack-relative value 24,s
                    pshs      d         ; save D on the hardware stack
                    leax      6,s       ; compute effective address into X from 6,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    lbsr      _scale    ; long branch to subroutine to _scale
                    leas      12,s      ; adjust S using 12,s
                    lbsr      _dmove    ; long branch to subroutine to _dmove
                    bra       Continue_07 ; branch unconditionally to Continue_07
Loop_04             leax      ,s        ; compute effective address into X from ,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       Subroutine_02 ; branch to subroutine to Subroutine_02
                    fdb       8192,0,0,132 ; define word data 8192,0,0,132
Subroutine_02       puls      x         ; restore X from the hardware stack
                    lbsr      _dmul     ; long branch to subroutine to _dmul
                    lbsr      _dmove    ; long branch to subroutine to _dmove
                    ldd       18,s      ; load D from stack-relative value 18,s
                    addd      #-1       ; add immediate value -1 into D
                    std       18,s      ; store D to stack-relative value 18,s
Continue_07         leax      ,s        ; compute effective address into X from ,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       Subroutine_03 ; branch to subroutine to Subroutine_03
                    fdb       0,0,0,129 ; define word data 0,0,0,129
Subroutine_03       puls      x         ; restore X from the hardware stack
                    lbsr      _dcmpr    ; long branch to subroutine to _dcmpr
                    blt       Loop_04   ; branch if less than to Loop_04
                    bra       Continue_08 ; branch unconditionally to Continue_08
Loop_05             leax      ,s        ; compute effective address into X from ,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       Subroutine_04 ; branch to subroutine to Subroutine_04
                    fdb       8192,0,0,132 ; define word data 8192,0,0,132
Subroutine_04       puls      x         ; restore X from the hardware stack
                    lbsr      _ddiv     ; long branch to subroutine to _ddiv
                    lbsr      _dmove    ; long branch to subroutine to _dmove
                    ldd       18,s      ; load D from stack-relative value 18,s
                    addd      #1        ; add immediate value 1 into D
                    std       18,s      ; store D to stack-relative value 18,s
Continue_08         leax      ,s        ; compute effective address into X from ,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       Subroutine_05 ; branch to subroutine to Subroutine_05
                    fdb       8192,0,0,132 ; define word data 8192,0,0,132
Subroutine_05       puls      x         ; restore X from the hardware stack
                    lbsr      _dcmpr    ; long branch to subroutine to _dcmpr
                    bge       Loop_05   ; branch if greater or equal to Loop_05
                    bra       Continue_10 ; branch unconditionally to Continue_10
Continue_09         leas      -32,x     ; adjust S using -32,x
Continue_10         leax      B0000,y   ; compute effective address into X from B0000,y
                    stx       30,s      ; store X to stack-relative value 30,s
                    ldd       #'0
                    ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       26,s      ; load D from stack-relative value 26,s
                    beq       BranchTarget_03 ; branch if equal/zero to BranchTarget_03
                    ldd       #'-
                    ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
BranchTarget_03     ldd       38,s      ; load D from stack-relative value 38,s
                    cmpd      #$0010    ; compare D against immediate value $0010
                    ble       BranchTarget_04 ; branch if less or equal to BranchTarget_04
                    ldd       #$0010    ; load D from immediate value $0010
                    bra       Continue_11 ; branch unconditionally to Continue_11
BranchTarget_04     ldd       38,s      ; load D from stack-relative value 38,s
                    bge       ReturnZero_03 ; branch if greater or equal to ReturnZero_03
                    clra                ; clear A
                    clrb                ; clear B
Continue_11         std       38,s      ; store D to stack-relative value 38,s
ReturnZero_03       clra                ; clear A
                    clrb                ; clear B
                    std       10,s      ; store D to stack-relative value 10,s
                    ldd       40,s      ; load D from stack-relative value 40,s
                    bne       BranchTarget_05 ; branch if not equal to BranchTarget_05
                    ldd       #1        ; load D from immediate value 1
                    std       10,s      ; store D to stack-relative value 10,s
                    ldd       18,s      ; load D from stack-relative value 18,s
                    cmpd      #5        ; compare D against immediate value 5
                    lbgt      BranchTarget_08 ; long branch if greater than to BranchTarget_08
                    leax      32,s      ; compute effective address into X from 32,s
                    bra       Continue_13 ; branch unconditionally to Continue_13
BranchTarget_05     ldd       40,s      ; load D from stack-relative value 40,s
                    bge       ReturnZero_04 ; branch if greater or equal to ReturnZero_04
                    bra       Continue_12 ; branch unconditionally to Continue_12
Loop_06             leas      -32,x     ; adjust S using -32,x
Continue_12         ldd       #1        ; load D from immediate value 1
                    std       16,s      ; store D to stack-relative value 16,s
                    ldd       #1        ; load D from immediate value 1
                    std       12,s      ; store D to stack-relative value 12,s
                    leax      ,s        ; compute effective address into X from ,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       Subroutine_06 ; branch to subroutine to Subroutine_06
                    fdb       0,0,0,0   ; define word data 0,0,0,0
Subroutine_06       puls      x         ; restore X from the hardware stack
                    lbsr      _dcmpr    ; long branch to subroutine to _dcmpr
                    bne       BranchTarget_09 ; branch if not equal to BranchTarget_09
                    ldd       #1        ; load D from immediate value 1
                    std       18,s      ; store D to stack-relative value 18,s
                    bra       BranchTarget_09 ; branch unconditionally to BranchTarget_09
Continue_13         leas      -32,x     ; adjust S using -32,x
ReturnZero_04       clra                ; clear A
                    clrb                ; clear B
                    std       16,s      ; store D to stack-relative value 16,s
                    ldd       18,s      ; load D from stack-relative value 18,s
                    std       12,s      ; store D to stack-relative value 12,s
                    bge       BranchTarget_07 ; branch if greater or equal to BranchTarget_07
                    ldd       12,s      ; load D from stack-relative value 12,s
                    addd      38,s      ; add stack-relative value 38,s into D
                    blt       BranchTarget_06 ; branch if less than to BranchTarget_06
                    ldd       38,s      ; load D from stack-relative value 38,s
                    addd      12,s      ; add stack-relative value 12,s into D
                    std       38,s      ; store D to stack-relative value 38,s
                    bra       BranchTarget_09 ; branch unconditionally to BranchTarget_09
BranchTarget_06     ldd       38,s      ; load D from stack-relative value 38,s
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    std       12,s      ; store D to stack-relative value 12,s
                    clra                ; clear A
                    clrb                ; clear B
                    std       38,s      ; store D to stack-relative value 38,s
                    clra                ; clear A
                    clrb                ; clear B
                    std       8,s       ; store D to stack-relative value 8,s
                    bra       BranchTarget_09 ; branch unconditionally to BranchTarget_09
BranchTarget_07     ldd       12,s      ; load D from stack-relative value 12,s
                    addd      38,s      ; add stack-relative value 38,s into D
                    cmpd      #$0019    ; compare D against immediate value $0019
                    ble       BranchTarget_09 ; branch if less or equal to BranchTarget_09
BranchTarget_08     leax      32,s      ; compute effective address into X from 32,s
                    lbra      Loop_06   ; long branch unconditionally to Loop_06
BranchTarget_09     leax      G0000,y   ; compute effective address into X from G0000,y
                    stx       14,s      ; store X to stack-relative value 14,s
                    leax      ,s        ; compute effective address into X from ,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      Subroutine_07 ; long branch to subroutine to Subroutine_07
                    leas      2,s       ; adjust S using 2,s
                    ldd       12,s      ; load D from stack-relative value 12,s
                    bge       BranchTarget_10 ; branch if greater or equal to BranchTarget_10
                    ldd       #'0
                    ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       30,s      ; load D from stack-relative value 30,s
                    std       28,s      ; store D to stack-relative value 28,s
                    ldd       #'.
                    bra       Continue_14 ; branch unconditionally to Continue_14
Loop_07             ldd       #'0
Continue_14         ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       12,s      ; load D from stack-relative value 12,s
                    addd      #1        ; add immediate value 1 into D
                    std       12,s      ; store D to stack-relative value 12,s
                    subd      #1        ; subtract immediate value 1 from D
                    bne       Loop_07   ; branch if not equal to Loop_07
                    bra       BranchTarget_12 ; branch unconditionally to BranchTarget_12
BranchTarget_10     ldd       12,s      ; load D from stack-relative value 12,s
                    bne       BranchTarget_11 ; branch if not equal to BranchTarget_11
                    ldd       #'0
                    bra       Continue_15 ; branch unconditionally to Continue_15
Loop_08             leax      14,s      ; compute effective address into X from 14,s
                    pshs      x         ; save X on the hardware stack
                    leax      2,s       ; compute effective address into X from 2,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      Subroutine_08 ; long branch to subroutine to Subroutine_08
                    leas      4,s       ; adjust S using 4,s
Continue_15         ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
BranchTarget_11     ldd       12,s      ; load D from stack-relative value 12,s
                    addd      #-1       ; add immediate value -1 into D
                    std       12,s      ; store D to stack-relative value 12,s
                    subd      #-1       ; subtract immediate value -1 from D
                    bne       Loop_08   ; branch if not equal to Loop_08
                    ldd       30,s      ; load D from stack-relative value 30,s
                    std       28,s      ; store D to stack-relative value 28,s
                    ldd       38,s      ; load D from stack-relative value 38,s
                    beq       BranchTarget_12 ; branch if equal/zero to BranchTarget_12
                    ldd       #'.
                    bra       Continue_16 ; branch unconditionally to Continue_16
Loop_09             leax      14,s      ; compute effective address into X from 14,s
                    pshs      x         ; save X on the hardware stack
                    leax      2,s       ; compute effective address into X from 2,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      Subroutine_08 ; long branch to subroutine to Subroutine_08
                    leas      4,s       ; adjust S using 4,s
Continue_16         ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
BranchTarget_12     ldd       38,s      ; load D from stack-relative value 38,s
                    addd      #-1       ; add immediate value -1 into D
                    std       38,s      ; store D to stack-relative value 38,s
                    subd      #-1       ; subtract immediate value -1 from D
                    bgt       Loop_09   ; branch if greater than to Loop_09
                    ldd       8,s       ; load D from stack-relative value 8,s
                    lbeq      BranchTarget_14 ; long branch if equal/zero to BranchTarget_14
                    leas      -4,s      ; adjust S using -4,s
                    ldd       34,s      ; load D from stack-relative value 34,s
                    std       ,s        ; store D to memory pointed to by S
                    tfr       d,x       ; transfer D,X
                    pshs      x         ; save X on the hardware stack
                    leax      20,s      ; compute effective address into X from 20,s
                    pshs      x         ; save X on the hardware stack
                    leax      8,s       ; compute effective address into X from 8,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      Subroutine_08 ; long branch to subroutine to Subroutine_08
                    leas      4,s       ; adjust S using 4,s
                    stb       [,s++]    ; store B to indirect address [,s++]
                    ldd       #5        ; load D from immediate value 5
                    std       2,s       ; store D to stack-relative value 2,s
Loop_10             ldb       [,s]      ; load B from indirect address [,s]
                    sex                 ; sign-extend B into A to form D
                    tfr       d,x       ; transfer D,X
                    bra       Continue_17 ; branch unconditionally to Continue_17
Loop_11             ldd       ,s        ; load D from memory pointed to by S
                    addd      #-1       ; add immediate value -1 into D
                    std       ,s        ; store D to memory pointed to by S
                    bra       Continue_18 ; branch unconditionally to Continue_18
Loop_12             ldd       #'-
                    ldx       ,s        ; load X from memory pointed to by S
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       #'0
                    stb       [,s]      ; store B to indirect address [,s]
                    bra       Continue_18 ; branch unconditionally to Continue_18
Continue_17         cmpx      #'.
                    beq       Loop_11   ; branch if equal/zero to Loop_11
                    cmpx      #'-
                    beq       Loop_12   ; branch if equal/zero to Loop_12
Continue_18         ldb       [,s]      ; load B from indirect address [,s]
                    sex                 ; sign-extend B into A to form D
                    addd      2,s       ; add stack-relative value 2,s into D
                    stb       [,s]      ; store B to indirect address [,s]
                    cmpd      #'9
                    ble       ReturnZero_05 ; branch if less or equal to ReturnZero_05
                    ldd       #1        ; load D from immediate value 1
                    bra       Continue_19 ; branch unconditionally to Continue_19
ReturnZero_05       clra                ; clear A
                    clrb                ; clear B
Continue_19         std       2,s       ; store D to stack-relative value 2,s
                    beq       BranchTarget_13 ; branch if equal/zero to BranchTarget_13
                    ldb       [,s]      ; load B from indirect address [,s]
                    sex                 ; sign-extend B into A to form D
                    subd      #10       ; subtract immediate value 10 from D
                    stb       [,s]      ; store B to indirect address [,s]
                    bra       Continue_20 ; branch unconditionally to Continue_20
Continue_20         ldd       ,s        ; load D from memory pointed to by S
                    addd      #-1       ; add immediate value -1 into D
                    std       ,s        ; store D to memory pointed to by S
                    lbra      Loop_10   ; long branch unconditionally to Loop_10
BranchTarget_13     leas      4,s       ; adjust S using 4,s
BranchTarget_14     ldd       16,s      ; load D from stack-relative value 16,s
                    lbeq      BranchTarget_17 ; long branch if equal/zero to BranchTarget_17
                    ldd       42,s      ; load D from stack-relative value 42,s
                    beq       BranchTarget_15 ; branch if equal/zero to BranchTarget_15
                    ldd       #'E
                    bra       Continue_21 ; branch unconditionally to Continue_21
BranchTarget_15     ldd       #'e
Continue_21         ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       18,s      ; load D from stack-relative value 18,s
                    addd      #-1       ; add immediate value -1 into D
                    std       18,s      ; store D to stack-relative value 18,s
                    bge       BranchTarget_16 ; branch if greater or equal to BranchTarget_16
                    ldd       18,s      ; load D from stack-relative value 18,s
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    std       18,s      ; store D to stack-relative value 18,s
                    ldd       #$002d    ; load D from immediate value $002d
                    bra       Continue_22 ; branch unconditionally to Continue_22
BranchTarget_16     ldd       #'+
Continue_22         ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       18,s      ; load D from stack-relative value 18,s
                    pshs      d         ; save D on the hardware stack
                    ldd       #10       ; load D from immediate value 10
                    lbsr      ccdiv     ; long branch to subroutine to ccdiv
                    addd      #'0
                    ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       18,s      ; load D from stack-relative value 18,s
                    pshs      d         ; save D on the hardware stack
                    ldd       #10       ; load D from immediate value 10
                    lbsr      ccmod     ; long branch to subroutine to ccmod
                    addd      #'0
                    ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    bra       ReturnZero_06 ; branch unconditionally to ReturnZero_06
BranchTarget_17     ldd       10,s      ; load D from stack-relative value 10,s
                    beq       ReturnZero_06 ; branch if equal/zero to ReturnZero_06
                    ldd       30,s      ; load D from stack-relative value 30,s
                    cmpd      28,s      ; compare D against stack-relative value 28,s
                    beq       ReturnZero_06 ; branch if equal/zero to ReturnZero_06
                    bra       BranchTarget_18 ; branch unconditionally to BranchTarget_18
Loop_13             ldb       [30,s]    ; load B from indirect address [30,s]
                    cmpb      #'0
                    beq       BranchTarget_18 ; branch if equal/zero to BranchTarget_18
                    ldd       30,s      ; load D from stack-relative value 30,s
                    addd      #1        ; add immediate value 1 into D
                    std       30,s      ; store D to stack-relative value 30,s
                    bra       ReturnZero_06 ; branch unconditionally to ReturnZero_06
BranchTarget_18     ldd       30,s      ; load D from stack-relative value 30,s
                    addd      #-1       ; add immediate value -1 into D
                    std       30,s      ; store D to stack-relative value 30,s
                    cmpd      28,s      ; compare D against stack-relative value 28,s
                    bne       Loop_13   ; branch if not equal to Loop_13
ReturnZero_06       clra                ; clear A
                    clrb                ; clear B
                    stb       [30,s]    ; store B to indirect address [30,s]
                    leax      B001e,y   ; compute effective address into X from B001e,y
                    cmpx      30,s      ; compare X against stack-relative value 30,s
                    bhi       BranchTarget_19 ; branch if higher to BranchTarget_19
                    leax      Label_01,pcr ; compute effective address into X from Label_01,pcr
                    pshs      x         ; save X on the hardware stack
                    leax      __iob+26,y ; compute effective address into X from __iob+26,y
                    pshs      x         ; save X on the hardware stack
                    lbsr      _fprintf  ; long branch to subroutine to _fprintf
                    leas      4,s       ; adjust S using 4,s
                    ldd       #1        ; load D from immediate value 1
                    pshs      d         ; save D on the hardware stack
                    lbsr      _exit     ; long branch to subroutine to _exit
                    leas      2,s       ; adjust S using 2,s
BranchTarget_19     ldb       B0000,y   ; load B from indexed value B0000,y
                    cmpb      #'0
                    bne       BranchTarget_20 ; branch if not equal to BranchTarget_20
                    leax      B0001,y   ; compute effective address into X from B0001,y
                    bra       Continue_23 ; branch unconditionally to Continue_23
BranchTarget_20     leax      B0000,y   ; compute effective address into X from B0000,y
Continue_23         tfr       x,d       ; transfer X,D
                    leas      32,s      ; adjust S using 32,s
                    puls      u,pc      ; restore registers and return
Subroutine_07       pshs      u         ; save U on the hardware stack
                    ldx       4,s       ; load X from stack-relative value 4,s
                    lda       7,x       ; load A from indexed value 7,x
                    suba      #$80      ; subtract immediate value $80 from A
                    bcs       BranchTarget_22 ; branch if carry is set to BranchTarget_22
                    ldb       ,x        ; load B from memory pointed to by X
                    orb       #$80      ; OR B with immediate value $80
                    stb       ,x        ; store B to memory pointed to by X
                    clr       7,x       ; clear indexed value 7,x
                    suba      #4        ; subtract immediate value 4 from A
                    beq       BranchTarget_21 ; branch if equal/zero to BranchTarget_21
Loop_14             lsr       ,x        ; logical shift memory pointed to by X right by one bit
                    ror       1,x       ; rotate indexed value 1,x right through carry
                    ror       2,x       ; rotate indexed value 2,x right through carry
                    ror       3,x       ; rotate indexed value 3,x right through carry
                    ror       4,x       ; rotate indexed value 4,x right through carry
                    ror       5,x       ; rotate indexed value 5,x right through carry
                    ror       6,x       ; rotate indexed value 6,x right through carry
                    ror       7,x       ; rotate indexed value 7,x right through carry
                    inca                ; increment A
                    bne       Loop_14   ; branch if not equal to Loop_14
BranchTarget_21     lda       #8        ; load A from immediate value 8
Loop_15             deca                ; decrement A
                    bmi       BranchTarget_22 ; branch if minus to BranchTarget_22
                    ldb       a,x       ; load B from indexed value a,x
                    beq       Loop_15   ; branch if equal/zero to Loop_15
BranchTarget_22     sta       D0000     ; store A to D0000
                    clra                ; clear A
                    clrb                ; clear B
                    puls      u,pc      ; restore registers and return
Subroutine_08       ldx       2,s       ; load X from stack-relative value 2,s
                    clra                ; clear A
                    ldb       ,x        ; load B from memory pointed to by X
                    lsrb                ; logical shift B right by one bit
                    lsrb                ; logical shift B right by one bit
                    lsrb                ; logical shift B right by one bit
                    lsrb                ; logical shift B right by one bit
                    addb      #'0
                    pshs      d,u       ; save D,U on the hardware stack
                    ldb       ,x        ; load B from memory pointed to by X
                    andb      #$0f      ; AND B with immediate value $0f
                    stb       ,x        ; store B to memory pointed to by X
                    bsr       Subroutine_09 ; branch to subroutine to Subroutine_09
                    lda       D0000     ; load A from D0000
                    bmi       BranchTarget_24 ; branch if minus to BranchTarget_24
Loop_16             ldb       a,x       ; load B from indexed value a,x
                    bne       BranchTarget_23 ; branch if not equal to BranchTarget_23
                    deca                ; decrement A
                    bpl       Loop_16   ; branch if plus to Loop_16
BranchTarget_23     sta       D0000     ; store A to D0000
                    bmi       BranchTarget_24 ; branch if minus to BranchTarget_24
                    leas      -8,s      ; adjust S using -8,s
Loop_17             ldb       a,x       ; load B from indexed value a,x
                    stb       a,s       ; store B to stack-relative value a,s
                    deca                ; decrement A
                    bpl       Loop_17   ; branch if plus to Loop_17
                    bsr       Subroutine_09 ; branch to subroutine to Subroutine_09
                    bsr       Subroutine_09 ; branch to subroutine to Subroutine_09
                    lda       D0000     ; load A from D0000
                    clrb                ; clear B
Loop_18             ldb       a,x       ; load B from indexed value a,x
                    adcb      a,s       ; add stack-relative value a,s into B
                    stb       a,x       ; store B to indexed value a,x
                    deca                ; decrement A
                    bpl       Loop_18   ; branch if plus to Loop_18
                    leas      8,s       ; adjust S using 8,s
BranchTarget_24     puls      d,u,pc    ; restore registers and return
Subroutine_09       lda       D0000     ; load A from D0000
                    bmi       Return_01 ; branch if minus to Return_01
                    asl       a,x       ; shift indexed value a,x left by one bit
                    bra       Continue_24 ; branch unconditionally to Continue_24
Loop_19             rol       a,x       ; rotate indexed value a,x left through carry
Continue_24         deca                ; decrement A
                    bpl       Loop_19   ; branch if plus to Loop_19
Return_01           rts                 ; return to caller
Label_01            fcc       "_pffinit ; buffer overflow"
                    fcb       $0d,$00   ; define byte data $0d,$00

                    endsect             ; end current section
