* Adapted from cmoc_os9/lib/todo/gs1.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_gs_size            EXPORT              ; export this symbol
_gs_pos             EXPORT              ; export this symbol

_flacc              EXTERNAL            ; import external symbol
_errno              EXTERNAL            ; import external symbol

_gs_size
                    ldb       #2        ; load B from immediate value 2
                    bra       Continue_01 ; branch unconditionally to Continue_01

_gs_pos
                    ldb       #5        ; load B from immediate value 5
Continue_01         pshs      u         ; save U on the hardware stack
                    lda       5,s       ; load A from stack-relative value 5,s
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    bcc       BranchTarget_01 ; branch if carry is clear to BranchTarget_01
                    ldx       #-1       ; load X from immediate value -1
                    tfr       x,u       ; transfer X,U
                    clra                ; clear A
                    std       _errno,y  ; store D to indexed value _errno,y
BranchTarget_01     stx       _flacc,y  ; store X to indexed value _flacc,y
                    leax      _flacc,y  ; compute effective address into X from _flacc,y
                    stu       2,x       ; store U to indexed value 2,x
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
