* Compact assembly implementation of open()/close().

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_open               EXPORT    ;         export this symbol
_close              EXPORT    ;         export this symbol

_os9err             EXTERNAL  ;         import external symbol
_sysret             EXTERNAL  ;         import external symbol

_open:
stk_open_ret        equ       0         ; caller return address
stk_open_path       equ       2         ; pathname pointer argument
stk_open_mode       equ       4         ; access-mode argument
stk_open_mode_byte  equ       5         ; low byte passed to OS-9 in A
                    ldx       stk_open_path,s ; pass pathname pointer to OS-9
                    lda       stk_open_mode_byte,s ; pass access mode in A
                    os9       I_Open    ; open the path and return descriptor in A
                    lbcs      _os9err   ; convert OS-9 open failure to errno result
                    tfr       a,b       ; move path descriptor into low byte of C int
                    clra                ; clear high byte of C int result
                    rts                 ; return opened path descriptor

_close:
stk_close_ret       equ       0         ; caller return address
stk_close_path      equ       2         ; path descriptor argument
stk_close_path_byte equ       3         ; low byte passed to OS-9 in A
                    lda       stk_close_path_byte,s ; pass path descriptor in A
                    os9       I_Close   ; close the OS-9 path
                    lbra      _sysret   ; return 0 or -1 using carry/error state

                    endsect   ;         end current section
