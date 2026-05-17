* Compact assembly implementation of creat/create/ocreat().

                    use       ../include/os9.d ; shared OS-9 service and error constants

                    section   code      ; begin code section

_creat              EXPORT              ; export this symbol
_create             EXPORT              ; export this symbol
_ocreat             EXPORT              ; export this symbol

_os9err             EXTERNAL            ; import external symbol

_creat
                    pshs      u         ; save U on the hardware stack
                    ldx       4,s       ; load X from stack-relative value 4,s
                    lda       7,s       ; load A from stack-relative value 7,s
                    tfr       a,b       ; transfer A,B
                    andb      #$24      ; AND B with immediate value $24
                    orb       #$0B      ; OR B with immediate value $0B
                    os9       I_Create  ; invoke OS-9 create path call
                    bcc       L_creat_ret ; branch if carry is clear to L_creat_ret
                    cmpb      #E_CEF    ; creating existing file?
                    bne       L_create_err ; branch if not equal to L_create_err
                    lda       7,s       ; load A from stack-relative value 7,s
                    bita      #$80      ; test bits in A against immediate value $80
                    bne       L_create_err ; branch if not equal to L_create_err
                    anda      #7        ; AND A with immediate value 7
                    ldx       4,s       ; load X from stack-relative value 4,s
                    os9       I_Open    ; try opening the existing file
                    bcs       L_create_err ; branch if carry is set to L_create_err
                    pshs      a,u       ; save A,U on the hardware stack
                    ldx       #0        ; load X from immediate value 0
                    leau      ,x        ; compute effective address into U from ,x
                    ldb       #$02      ; load B from immediate value $02
                    os9       I_SetStt  ; set file size to zero for truncation
                    puls      a,u       ; restore A,U from the hardware stack
                    bcc       L_creat_ret ; branch if carry is clear to L_creat_ret
                    pshs      b         ; save B on the hardware stack
                    os9       I_Close   ; close partially opened path on failure
                    puls      b         ; restore B from the hardware stack
L_create_err
                    leas      2,s       ; adjust S using 2,s
                    lbra      _os9err   ; long branch unconditionally to _os9err

_create
                    pshs      u         ; save U on the hardware stack
                    ldx       4,s       ; load X from stack-relative value 4,s
                    lda       7,s       ; load A from stack-relative value 7,s
                    ldb       9,s       ; load B from stack-relative value 9,s
                    os9       I_Create  ; invoke OS-9 create path call
                    bcs       L_ocreat_retry ; branch if carry is set to L_ocreat_retry
                    bra       L_creat_ret ; branch unconditionally to L_creat_ret

L_ocreat_retry
                    cmpb      #E_CEF    ; creating existing file?
                    bne       L_create_err ; branch if not equal to L_create_err
                    ldx       4,s       ; load X from stack-relative value 4,s
                    os9       I_Delete  ; remove old file before retrying create
                    bcs       L_create_err ; branch if carry is set to L_create_err
                    puls      u         ; restore U from the hardware stack
                    bra       _ocreat   ; branch unconditionally to _ocreat

_ocreat
                    pshs      u         ; save U on the hardware stack
                    ldx       4,s       ; load X from stack-relative value 4,s
                    lda       7,s       ; load A from stack-relative value 7,s
                    ldb       9,s       ; load B from stack-relative value 9,s
                    os9       I_Create  ; invoke OS-9 create path call
                    bcs       L_ocreat_retry ; branch if carry is set to L_ocreat_retry

L_creat_ret
                    leas      2,s       ; adjust S using 2,s
                    tfr       a,b       ; transfer A,B
                    clra                ; clear A
                    rts                 ; return to caller

                    endsect             ; end current section
