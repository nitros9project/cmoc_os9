* Adapted from cmoc_os9/lib/todo/dir.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_chdir              EXPORT              ; export this symbol
_chxdir             EXPORT              ; export this symbol

_sysret             EXTERNAL            ; import external symbol

_chdir              lda       #1        ; load A from immediate value 1
Loop_01             ldx       2,s       ; load X from stack-relative value 2,s
                    os9       I_ChgDir  ; invoke OS-9 system call I_ChgDir
                    lbra      _sysret   ; long branch unconditionally to _sysret

_chxdir             lda       #4        ; load A from immediate value 4
                    bra       Loop_01   ; branch unconditionally to Loop_01

                    endsect             ; end current section
