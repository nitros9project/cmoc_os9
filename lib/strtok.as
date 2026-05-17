* Adapted from Deek's KLibc strtok.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strtok             EXPORT              ; export this symbol

_strspn             EXTERN              ; import external symbol
_strpbrk            EXTERN              ; import external symbol

_strtok
                    clra                ; clear A
                    clrb                ; clear B
                    pshs      d,u       ; save D,U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    bne       BranchTarget_01 ; branch if not equal to BranchTarget_01
                    ldu       _save,y   ; load U from indexed value _save,y
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
BranchTarget_01     ldx       8,s       ; load X from stack-relative value 8,s
                    pshs      x         ; save X on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    lbsr      _strspn   ; long branch to subroutine to _strspn
                    leas      4,s       ; adjust S using 4,s
                    leau      d,u       ; compute effective address into U from d,u
                    ldb       ,u        ; load B from memory pointed to by U
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
                    stu       ,s        ; store U to memory pointed to by S
                    ldx       8,s       ; load X from stack-relative value 8,s
                    pshs      x         ; save X on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    lbsr      _strpbrk  ; long branch to subroutine to _strpbrk
                    leas      4,s       ; adjust S using 4,s
                    std       _save,y   ; store D to indexed value _save,y
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
                    tfr       d,x       ; transfer D,X
                    clr       ,x+       ; clear memory pointed to by X, then advance X
                    stx       _save,y   ; store X to indexed value _save,y
BranchTarget_02     puls      d,u,pc    ; restore registers and return

                    section   bss       ; begin bss section

_save               rmb       2         ; reserve 2 bytes

                    endsect             ; end current section
