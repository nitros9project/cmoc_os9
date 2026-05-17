                    section   rodata    ; begin rodata section

* Initialized Data (class G)
atoftbl:            fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $80       ; define byte data $80
                    fcb       $20       ; define byte data $20
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $84       ; define byte data $84
                    fcb       $48       ; define byte data $48
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $87       ; define byte data $87
                    fcb       $7a       ; define byte data $7a
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $8a       ; define byte data $8a
                    fcb       $1c       ; define byte data $1c
                    fcb       $40       ; define byte data $40
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $8e       ; define byte data $8e
                    fcb       $43       ; define byte data $43
                    fcb       $50       ; define byte data $50
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $91       ; define byte data $91
                    fcb       $74       ; define byte data $74
                    fcb       $24       ; define byte data $24
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $94       ; define byte data $94
                    fcb       $18       ; define byte data $18
                    fcb       $96       ; define byte data $96
                    fcb       $80       ; define byte data $80
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $98       ; define byte data $98
                    fcb       $3e       ; define byte data $3e
                    fcb       $bc       ; define byte data $bc
                    fcb       $20       ; define byte data $20
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $9b       ; define byte data $9b
                    fcb       $6e       ; define byte data $6e
                    fcb       $6b       ; define byte data $6b
                    fcb       $28       ; define byte data $28
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $9e       ; define byte data $9e
                    fcb       $15       ; define byte data $15
                    fcb       $02       ; define byte data $02
                    fcb       $f9       ; define byte data $f9
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $a2       ; define byte data $a2
                    fcb       $2d       ; define byte data $2d
                    fcb       $78       ; define byte data $78
                    fcb       $eb       ; define byte data $eb
                    fcb       $c5       ; define byte data $c5
                    fcb       $ac       ; define byte data $ac
                    fcb       $62       ; define byte data $62
                    fcb       $00       ; define byte data $00
                    fcb       $c3       ; define byte data $c3
                    fcb       $49       ; define byte data $49
                    fcb       $f2       ; define byte data $f2
                    fcb       $c9       ; define byte data $c9
                    fcb       $cd       ; define byte data $cd
                    fcb       $04       ; define byte data $04
                    fcb       $67       ; define byte data $67
                    fcb       $4f       ; define byte data $4f
                    fcb       $e4       ; define byte data $e4

                    endsect             ; end current section

                    section   code      ; begin code section

_scale              EXPORT              ; export this symbol

_dmul               EXTERNAL            ; import external symbol
_ddiv               EXTERNAL            ; import external symbol
_dmove              EXTERNAL            ; import external symbol
_dstack             EXTERNAL            ; import external symbol
ccdiv               EXTERNAL            ; import external symbol
ccmod               EXTERNAL            ; import external symbol
_flacc              EXTERNAL            ; import external symbol

Subroutine_01       pshs      u         ; save U on the hardware stack
                    ldd       12,s      ; load D from stack-relative value 12,s
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
                    ldd       14,s      ; load D from stack-relative value 14,s
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    leax      4,s       ; compute effective address into X from 4,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    ldd       20,s      ; load D from stack-relative value 20,s
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    leax      atoftbl,pcr ; compute effective address into X from atoftbl,pcr
                    leax      d,x       ; compute effective address into X from d,x
                    lbsr      _dmul     ; long branch to subroutine to _dmul
                    bra       Continue_01 ; branch unconditionally to Continue_01
BranchTarget_01     leax      4,s       ; compute effective address into X from 4,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    ldd       20,s      ; load D from stack-relative value 20,s
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    leax      atoftbl,y ; compute effective address into X from atoftbl,y
                    leax      d,x       ; compute effective address into X from d,x
                    lbsr      _ddiv     ; long branch to subroutine to _ddiv
                    bra       Continue_01 ; branch unconditionally to Continue_01
BranchTarget_02     leax      4,s       ; compute effective address into X from 4,s
Continue_01         leau      _flacc,y  ; compute effective address into U from _flacc,y
                    pshs      u         ; save U on the hardware stack
                    lbsr      _dmove    ; long branch to subroutine to _dmove
                    puls      u,pc      ; restore registers and return
_scale:             pshs      u         ; save U on the hardware stack
                    ldd       12,s      ; load D from stack-relative value 12,s
                    cmpd      #9        ; compare D against immediate value 9
                    ble       BranchTarget_03 ; branch if less or equal to BranchTarget_03
                    leax      4,s       ; compute effective address into X from 4,s
                    pshs      x         ; save X on the hardware stack
                    ldd       16,s      ; load D from stack-relative value 16,s
                    pshs      d         ; save D on the hardware stack
                    ldd       16,s      ; load D from stack-relative value 16,s
                    pshs      d         ; save D on the hardware stack
                    ldd       #$000a    ; load D from immediate value $000a
                    lbsr      ccdiv     ; long branch to subroutine to ccdiv
                    addd      #9        ; add immediate value 9 into D
                    pshs      d         ; save D on the hardware stack
                    leax      10,s      ; compute effective address into X from 10,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    lbsr      Subroutine_01 ; long branch to subroutine to Subroutine_01
                    leas      12,s      ; adjust S using 12,s
                    lbsr      _dmove    ; long branch to subroutine to _dmove
BranchTarget_03     ldd       14,s      ; load D from stack-relative value 14,s
                    pshs      d         ; save D on the hardware stack
                    ldd       14,s      ; load D from stack-relative value 14,s
                    pshs      d         ; save D on the hardware stack
                    ldd       #$000a    ; load D from immediate value $000a
                    lbsr      ccmod     ; long branch to subroutine to ccmod
                    pshs      d         ; save D on the hardware stack
                    leax      8,s       ; compute effective address into X from 8,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    lbsr      Subroutine_01 ; long branch to subroutine to Subroutine_01
                    leas      12,s      ; adjust S using 12,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section

