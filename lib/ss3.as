* Adapted from cmoc_os9/lib/todo/ss3.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_ss_wtrk            EXPORT              ; export this symbol

_sysret             EXTERNAL            ; import external symbol

_ss_wtrk
                    pshs      y,u       ; save Y,U on the hardware stack
                    ldb       #SS_WTrk  ; request write-track style SetStat
                    ldy       10,s      ; load Y from stack-relative value 10,s
                    ldu       8,s       ; load U from stack-relative value 8,s
                    ldx       14,s      ; load X from stack-relative value 14,s
                    lda       7,s       ; load A from stack-relative value 7,s
                    os9       I_SetStt  ; invoke OS-9 system call I_SetStt
                    puls      y,u       ; restore Y,U from the hardware stack
                    lbra      _sysret   ; long branch unconditionally to _sysret

                    endsect             ; end current section
