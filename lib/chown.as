*
* Adapted from cmoc_os9/lib/todo/chown.as for the live CMOC ABI.
*

                    use       ../include/os9.d ; shared OS-9 service constants
                    use       ../include/fcntl.d ; shared file-mode constants

                    section   code      ; begin code section

_chown              EXPORT              ; export this symbol

_sysret             EXTERNAL            ; import external symbol

Bufsize             equ       16        ; define constant as 16

_chown              pshs      y,u       ; save Y,U on the hardware stack
                    leas      -Bufsize,s ; adjust S using -Bufsize,s
                    os9       $0c       ; invoke OS-9 system call $0c
                    bcs       chxit     ; branch if carry is set to chxit
                    ldb       #$d6      ; load B from immediate value $d6
                    cmpy      #0        ; compare Y against immediate value 0
                    orcc      #1        ; set condition-code bits with mask #1
                    bne       chxit     ; branch if not equal to chxit
                    bsr       openfile  ; branch to subroutine to openfile
                    bcs       chxit     ; branch if carry is set to chxit
                    pshs      a         ; save A on the hardware stack
                    ldd       25,s      ; load D from stack-relative value 25,s
                    std       1,x       ; store D to indexed value 1,x
                    puls      a         ; restore A from the hardware stack
                    ldb       #SS_FD    ; load B from immediate value SS_FD
                    os9       $8e       ; invoke OS-9 system call $8e
                    bcs       chxit     ; branch if carry is set to chxit
                    os9       $8f       ; invoke OS-9 system call $8f
chxit               leas      Bufsize,s ; adjust S using Bufsize,s
                    puls      y,u       ; restore Y,U from the hardware stack
                    lbra      _sysret   ; long branch unconditionally to _sysret

openfile
                    lda       #FAM_WRITE ; load A from immediate value FAM_WRITE
                    ldx       24,s      ; load X from stack-relative value 24,s
                    os9       $84       ; invoke OS-9 system call $84
                    bcc       openf10   ; branch if carry is clear to openf10
                    rts                 ; return to caller

openf10             leax      2,s       ; compute effective address into X from 2,s
                    ldy       #Bufsize  ; load Y from immediate value Bufsize
                    ldb       #SS_FD    ; load B from immediate value SS_FD
                    os9       $8d       ; invoke OS-9 system call $8d
                    rts                 ; return to caller

                    endsect             ; end current section
