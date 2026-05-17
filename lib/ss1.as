* Adapted from cmoc_os9/lib/todo/ss1.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_ss_rel             EXPORT              ; export this symbol
_ss_rest            EXPORT              ; export this symbol
_ss_opt             EXPORT              ; export this symbol
_ss_pfd             EXPORT              ; export this symbol
_ss_ssig            EXPORT              ; export this symbol
_ss_tiks            EXPORT              ; export this symbol

_sysret             EXTERNAL            ; import external symbol

_ss_rel
                    ldb       #$1b      ; load B from immediate value $1b
                    bra       Continue_02 ; branch unconditionally to Continue_02

_ss_rest
                    ldb       #3        ; load B from immediate value 3
                    bra       Continue_02 ; branch unconditionally to Continue_02

_ss_opt
                    ldb       #0        ; load B from immediate value 0
                    bra       Continue_01 ; branch unconditionally to Continue_01

_ss_pfd
                    ldb       #$0f      ; load B from immediate value $0f
                    bra       Continue_01 ; branch unconditionally to Continue_01

_ss_ssig
                    ldb       #$1a      ; load B from immediate value $1a
                    bra       Continue_01 ; branch unconditionally to Continue_01

_ss_tiks
                    ldb       #$10      ; load B from immediate value $10
Continue_01         ldx       4,s       ; load X from stack-relative value 4,s
Continue_02         lda       3,s       ; load A from stack-relative value 3,s
                    os9       I_SetStt  ; invoke OS-9 system call I_SetStt
                    lbra      _sysret   ; long branch unconditionally to _sysret

                    endsect             ; end current section
