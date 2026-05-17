*
* Adapted from cmoc_os9/lib/todo/chmod.a for the live CMOC ABI.
*

                    use       ../include/os9.d ; shared OS-9 service constants
                    use       ../include/fcntl.d ; shared file-mode constants

                    section   code      ; begin code section

_chmod              EXPORT              ; export this symbol

_sysret             EXTERNAL            ; import external symbol

FD_Att              equ       0         ; define constant as 0
FD_Own              equ       1         ; define constant as 1
Bufsize             equ       16        ; define constant as 16

_chmod              pshs      y,u       ; save Y,U on the hardware stack
                    leas      -Bufsize,s ; adjust S using -Bufsize,s

                    bsr       openfile  ; branch to subroutine to openfile
                    bcs       chexit    ; branch if carry is set to chexit

                    pshs      a,y       ; save A,Y on the hardware stack
                    os9       $0c       ; invoke OS-9 system call $0c
                    cmpy      #0        ; compare Y against immediate value 0
                    beq       chmod10   ; branch if equal/zero to chmod10
                    ldb       #$d6      ; load B from immediate value $d6
                    cmpy      FD_Own,x  ; compare Y against indexed value FD_Own,x
                    orcc      #1        ; set condition-code bits with mask #1
                    bne       chexit    ; branch if not equal to chexit

chmod10             ldb       Bufsize+12,s ; load B from stack-relative value Bufsize+12,s
                    stb       FD_Att,x  ; store B to indexed value FD_Att,x
                    puls      a,y       ; restore A,Y from the hardware stack
                    ldb       #SS_FD    ; load B from immediate value SS_FD
                    os9       $8e       ; invoke OS-9 system call $8e
                    bcs       chexit    ; branch if carry is set to chexit
                    os9       $8f       ; invoke OS-9 system call $8f

chexit              leas      Bufsize,s ; adjust S using Bufsize,s
                    puls      y,u       ; restore Y,U from the hardware stack
                    lbra      _sysret   ; long branch unconditionally to _sysret

openfile
                    lda       #FAM_WRITE ; load A from immediate value FAM_WRITE
                    ldx       Bufsize+8,s ; load X from stack-relative value Bufsize+8,s
                    os9       $84       ; invoke OS-9 system call $84
                    bcc       openf10   ; branch if carry is clear to openf10
                    rts                 ; return to caller

openf10             leax      2,s       ; compute effective address into X from 2,s
                    ldy       #Bufsize  ; load Y from immediate value Bufsize
                    ldb       #SS_FD    ; load B from immediate value SS_FD
                    os9       $8d       ; invoke OS-9 system call $8d
                    rts                 ; return to caller

                    endsect             ; end current section
