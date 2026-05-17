* Adapted from cmoc_os9/lib/todo/datmods.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_lockdata           EXPORT              ; export this symbol
_unlkdata           EXPORT              ; export this symbol
_datlink            EXPORT              ; export this symbol
_dunlink            EXPORT              ; export this symbol

_os9err             EXTERNAL            ; import external symbol
_sysret             EXTERNAL            ; import external symbol

_lockdata
                    ldx       2,s       ; load X from stack-relative value 2,s
                    pshs      cc        ; save CC on the hardware stack
                    orcc      #$10      ; set condition-code bits with mask #$10
                    inc       ,x        ; increment memory pointed to by X
                    beq       ReturnZero_01 ; branch if equal/zero to ReturnZero_01
                    ldb       ,x        ; load B from memory pointed to by X
                    dec       ,x        ; decrement memory pointed to by X
Loop_01             sex                 ; sign-extend B into A to form D
                    puls      cc,pc     ; restore registers and return

_unlkdata
                    ldx       2,s       ; load X from stack-relative value 2,s
                    pshs      cc        ; save CC on the hardware stack
                    orcc      #$10      ; set condition-code bits with mask #$10
                    ldb       ,x        ; load B from memory pointed to by X
                    bne       Loop_01   ; branch if not equal to Loop_01
                    dec       ,x        ; decrement memory pointed to by X
ReturnZero_01       clra                ; clear A
                    clrb                ; clear B
                    puls      cc,pc     ; restore registers and return

_datlink
                    pshs      y,u       ; save Y,U on the hardware stack
                    clr       ,-s       ; clear memory pointed to by -S
                    clr       ,-s       ; clear memory pointed to by -S
                    ldx       8,s       ; load X from stack-relative value 8,s
                    lda       #$40      ; load A from immediate value $40
                    os9       F_Link    ; invoke OS-9 system call F_Link
                    bcc       BranchTarget_02 ; branch if carry is clear to BranchTarget_02
                    cmpb      #$DD      ; compare B against immediate value $DD
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    coma
Loop_02             puls      x,y,u     ; restore X,Y,U from the hardware stack
                    lbra      _os9err   ; long branch unconditionally to _os9err
BranchTarget_01     ldx       8,s       ; load X from stack-relative value 8,s
                    lda       #$40      ; load A from immediate value $40
                    os9       F_Load    ; invoke OS-9 system call F_Load
                    bcs       Loop_02   ; branch if carry is set to Loop_02
                    inc       1,s       ; increment stack-relative value 1,s
BranchTarget_02     pshs      y         ; save Y on the hardware stack
                    tfr       u,d       ; transfer U,D
                    subd      ,s++      ; subtract memory pointed to by S+, then advance S+ from D
                    std       ,y++      ; store D to memory pointed to by Y+, then advance Y+
                    sty       [10,s]    ; store Y to indirect address [10,s]
                    addd      2,u       ; add indexed value 2,u into D
                    subd      #5        ; subtract immediate value 5 from D
                    std       [12,s]    ; store D to indirect address [12,s]
                    ldd       ,s        ; load D from memory pointed to by S
                    beq       BranchTarget_03 ; branch if equal/zero to BranchTarget_03
                    pshs      y         ; save Y on the hardware stack
                    bsr       _lockdata ; branch to subroutine to _lockdata
                    std       ,s++      ; store D to memory pointed to by S+, then advance S+
                    beq       BranchTarget_03 ; branch if equal/zero to BranchTarget_03
                    clr       1,s       ; clear stack-relative value 1,s
BranchTarget_03     puls      d,y,u,pc  ; restore registers and return

_dunlink
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldd       ,--u      ; load D from memory pointed to by --U
                    leau      d,u       ; compute effective address into U from d,u
                    os9       F_UnLink  ; invoke OS-9 system call F_UnLink
                    puls      u         ; restore U from the hardware stack
                    lbra      _sysret   ; long branch unconditionally to _sysret

                    endsect             ; end current section
