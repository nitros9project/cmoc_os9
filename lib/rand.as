* Adapted from Deek's KLibc rand.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_rand               EXPORT              ; export this symbol
_srand              EXPORT              ; export this symbol

_lmul               EXTERN              ; import external symbol
_ladd               EXTERN              ; import external symbol

                    section   bss       ; begin bss section
L_next              rmb       4         ; reserve 4 bytes
                    endsect             ; end current section

                    section   code      ; begin code section

_rand
                    pshs      u         ; save U on the hardware stack
                    leax      L_next,y  ; compute effective address into X from L_next,y
                    ldd       ,x        ; load D from memory pointed to by X
                    ldu       2,x       ; load U from indexed value 2,x
                    pshs      d,u       ; save D,U on the hardware stack
                    leax      L_mcon,pcr ; compute effective address into X from L_mcon,pcr
                    lbsr      _lmul     ; long branch to subroutine to _lmul
                    ldd       ,x        ; load D from memory pointed to by X
                    ldu       2,x       ; load U from indexed value 2,x
                    pshs      d,u       ; save D,U on the hardware stack
                    leax      L_acon,pcr ; compute effective address into X from L_acon,pcr
                    lbsr      _ladd     ; long branch to subroutine to _ladd
                    leau      L_next,y  ; compute effective address into U from L_next,y
                    ldd       ,x        ; load D from memory pointed to by X
                    ldx       2,x       ; load X from indexed value 2,x
                    std       ,u        ; store D to memory pointed to by U
                    stx       2,u       ; store X to indexed value 2,u
                    anda      #$7f      ; AND A with immediate value $7f
                    puls      u,pc      ; restore registers and return

_srand
                    leax      L_next,y  ; compute effective address into X from L_next,y
                    ldd       2,s       ; load D from stack-relative value 2,s
                    std       2,x       ; store D to indexed value 2,x
                    clra                ; clear A
                    clrb                ; clear B
                    std       ,x        ; store D to memory pointed to by X
                    rts                 ; return to caller

L_mcon              fdb       16838,20077 ; define word data 16838,20077
L_acon              fdb       0,12345   ; define word data 0,12345

                    endsect             ; end current section
