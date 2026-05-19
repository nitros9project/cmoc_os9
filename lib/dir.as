* Adapted from cmoc_os9/lib/todo/dir.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants
                    use       ../include/fcntl.d ; shared file access constants

                    section   code      ; begin code section

_chdir              EXPORT    ;         export this symbol
_chxdir             EXPORT    ;         export this symbol

_sysret             EXTERNAL  ;         import external symbol

_chdir:
stk_chdir_ret       equ       0         ; caller return address
stk_chdir_path      equ       2         ; directory path argument
                    lda       #FAM_READ ; change the data directory
chgdir_common       ldx       stk_chdir_path,s ; load directory path pointer
                    os9       I_ChgDir  ; invoke OS-9 system call I_ChgDir
                    lbra      _sysret   ; convert OS-9 status to C return convention

_chxdir:
stk_chxdir_ret      equ       0         ; caller return address
stk_chxdir_path     equ       2         ; execution-directory path argument
                    lda       #S_IEXEC  ; change the execution directory
                    bra       chgdir_common ; share I$ChgDir call path

                    endsect   ;         end current section
