* Adapted from cmoc_os9/lib/todo/gs2.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_gs_rdy             EXPORT              ; export this symbol
_gs_eof             EXPORT              ; export this symbol
_gs_opt             EXPORT              ; export this symbol
_gs_devn            EXPORT              ; export this symbol
_gs_gfd             EXPORT              ; export this symbol

_os9err             EXTERNAL            ; import external symbol
_sysret             EXTERNAL            ; import external symbol

_gs_rdy
                    ldb       #SS_Ready ; request readiness status
                    lda       3,s       ; load A from stack-relative value 3,s
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    lblo      _os9err   ; long branch if lower to _os9err
                    clra                ; clear A
                    rts                 ; return to caller

_gs_eof
                    ldb       #SS_EOF   ; request end-of-file status
                    bra       Continue_01 ; branch unconditionally to Continue_01

_gs_opt
                    ldb       #SS_Opt   ; request path options packet
                    ldx       4,s       ; load X from stack-relative value 4,s
Continue_01         lda       3,s       ; load A from stack-relative value 3,s
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    bra       BranchTarget_01 ; branch unconditionally to BranchTarget_01

_gs_devn
                    ldb       #SS_DevNm ; request device name string
                    ldx       4,s       ; load X from stack-relative value 4,s
                    lda       3,s       ; load A from stack-relative value 3,s
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    bcs       BranchTarget_01 ; branch if carry is set to BranchTarget_01
Loop_01             lda       ,x+       ; load A from memory pointed to by X, then advance X
                    bpl       Loop_01   ; branch if plus to Loop_01
                    anda      #$7f      ; AND A with immediate value $7f
                    sta       -1,x      ; store A to indexed value -1,x
                    clr       ,x        ; clear memory pointed to by X
                    rts                 ; return to caller

_gs_gfd
                    pshs      y         ; save Y on the hardware stack
                    ldb       #SS_FD    ; request file descriptor sector block
                    lda       5,s       ; load A from stack-relative value 5,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldy       8,s       ; load Y from stack-relative value 8,s
                    os9       I_GetStt  ; invoke OS-9 system call I_GetStt
                    puls      y         ; restore Y from the hardware stack
BranchTarget_01     lbra      _sysret   ; long branch unconditionally to _sysret

                    endsect             ; end current section
