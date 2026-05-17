                    section   code      ; begin code section

__prgname           EXTERN              ; import external symbol
__iob               EXTERN              ; import external symbol
_fprintf            EXTERN              ; import external symbol

__errmsg            EXPORT              ; export this symbol
__errmsg
                    pshs      u         ; save U on the hardware stack
                    lbsr      __prgname ; long branch to subroutine to __prgname
                    pshs      d         ; save D on the hardware stack
                    leau      errmsg_prefix,pcr ; compute effective address into U from errmsg_prefix,pcr
                    leax      __iob+26,y ; compute effective address into X from __iob+26,y
                    pshs      x,u       ; save X,U on the hardware stack
                    lbsr      _fprintf  ; long branch to subroutine to _fprintf
                    leas      6,s       ; adjust S using 6,s
                    ldu       12,s      ; load U from stack-relative value 12,s
                    ldx       10,s      ; load X from stack-relative value 10,s
                    ldd       8,s       ; load D from stack-relative value 8,s
                    pshs      d,x,u     ; save D,X,U on the hardware stack
                    ldu       12,s      ; load U from stack-relative value 12,s
                    leax      __iob+26,y ; compute effective address into X from __iob+26,y
                    pshs      x,u       ; save X,U on the hardware stack
                    lbsr      _fprintf  ; long branch to subroutine to _fprintf
                    leas      10,s      ; adjust S using 10,s
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

errmsg_prefix
                    fcc       "%s:      ; "
                    fcb       0         ; define byte data 0

                    endsect             ; end current section
