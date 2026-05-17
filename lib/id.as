* Live cmoc_os9 ABI assembly implementation of OS-9 ID wrappers.

                    section   code      ; begin code section

_os_getpid          EXPORT              ; export this symbol
_os_getuid          EXPORT              ; export this symbol
_os_asetuid         EXPORT              ; export this symbol
_os_setuid          EXPORT              ; export this symbol

_getpid             EXTERNAL            ; import external symbol
_oserr              EXTERNAL            ; import external symbol
_osret              EXTERNAL            ; import external symbol

_os_getpid
                    pshs      y         ; save Y on the hardware stack
                    lbsr      _getpid   ; long branch to subroutine to _getpid
                    ldx       4,s       ; load X from stack-relative value 4,s
                    beq       ReturnZero_01 ; branch if equal/zero to ReturnZero_01
                    std       ,x        ; store D to memory pointed to by X
ReturnZero_01       clra                ; clear A
                    clrb                ; clear B
                    puls      y,pc      ; restore registers and return

_os_getuid
                    pshs      y         ; save Y on the hardware stack
                    os9       $0C       ; invoke OS-9 system call $0C
                    tfr       y,d       ; transfer Y,D
                    puls      y         ; restore Y from the hardware stack
                    lbcs      _oserr    ; long branch if carry is set to _oserr
                    ldx       2,s       ; load X from stack-relative value 2,s
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    std       ,x        ; store D to memory pointed to by X
BranchTarget_01     lbra      _osret    ; long branch unconditionally to _osret

_os_asetuid
                    pshs      y         ; save Y on the hardware stack
                    bra       BranchTarget_02 ; branch unconditionally to BranchTarget_02

* WARNING: Writes to system globals and process descriptor
* won't work for Level 2 fallback path.
_os_setuid
                    pshs      y         ; save Y on the hardware stack
                    os9       $0C       ; invoke OS-9 system call $0C
                    tfr       y,d       ; transfer Y,D
                    std       -2,s      ; store D to stack-relative value -2,s
                    beq       BranchTarget_02 ; branch if equal/zero to BranchTarget_02
                    ldb       #$D6      ; load B from immediate value $D6
Loop_01             puls      y         ; restore Y from the hardware stack
                    lbra      _oserr    ; long branch unconditionally to _oserr
BranchTarget_02     ldy       4,s       ; load Y from stack-relative value 4,s
                    os9       $1C       ; invoke OS-9 system call $1C
                    bcc       BranchTarget_03 ; branch if carry is clear to BranchTarget_03
                    cmpb      #$D0      ; compare B against immediate value $D0
                    bne       Loop_01   ; branch if not equal to Loop_01
                    tfr       y,d       ; transfer Y,D
                    ldy       $004B     ; load Y from $004B
                    std       9,y       ; store D to indexed value 9,y
BranchTarget_03     puls      y         ; restore Y from the hardware stack
                    lbra      _osret    ; long branch unconditionally to _osret

                    endsect             ; end current section
