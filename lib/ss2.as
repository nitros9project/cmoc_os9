* Adapted from cmoc_os9/lib/todo/ss2.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_ss_lock            EXPORT              ; export this symbol
_ss_attr            EXPORT              ; export this symbol
_ss_size            EXPORT              ; export this symbol

_sysret             EXTERNAL            ; import external symbol

_ss_lock
                    pshs      u         ; save U on the hardware stack
                    ldb       #$11      ; load B from immediate value $11
                    bra       Continue_01 ; branch unconditionally to Continue_01

_ss_attr
                    pshs      u         ; save U on the hardware stack
                    ldb       #$1c      ; load B from immediate value $1c
                    bra       Continue_02 ; branch unconditionally to Continue_02

_ss_size
                    pshs      u         ; save U on the hardware stack
                    ldb       #2        ; load B from immediate value 2
Continue_01         ldu       8,s       ; load U from stack-relative value 8,s
Continue_02         ldx       6,s       ; load X from stack-relative value 6,s
                    lda       5,s       ; load A from stack-relative value 5,s
                    os9       I_SetStt  ; invoke OS-9 system call I_SetStt
                    puls      u         ; restore U from the hardware stack
                    lbra      _sysret   ; long branch unconditionally to _sysret

                    endsect             ; end current section
