* Adapted from cmoc_os9/lib/todo/intercept.as for the live cmoc_os9 ABI.
*
* 'signal' and 'intercept' are incompatible by design.  Both modules export
* _sigint so the linker reports an entry-name clash if a program tries to use
* both.

                    section   bss       ; begin bss section

_intsave            rmb       2         ; place for C routine address

                    endsect   ;         end current section

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_sigint             EXPORT    ;         export this symbol
_intercept          EXPORT    ;         export this symbol

_sysret             EXTERNAL  ;         import external symbol

_sigint:
_intercept:
stk_sigint_saved_u  equ       0         ; saved U register after pshs u
stk_sigint_ret      equ       2         ; caller return address after pshs u
stk_sigint_handler  equ       4         ; C signal handler pointer argument
                    pshs      u         ; preserve register variable pointer
                    tfr       y,u       ; make U the data-area pointer for OS-9 intercept
                    ldx       stk_sigint_handler,s ; get C handler function address
                    stx       _intsave,y ; save it for the receiver
                    leax      receiver,pcr ; pass receiver entry point to OS-9
                    os9       F_Icpt    ; install the process intercept routine
                    puls      u         ; restore register variable pointer
                    lbra      _sysret   ; return OS-9 carry/status through shared helper

* This is where OS-9 will pass control when the process has been
* sent a signal. All that is needed is to run the intercept routine
* and execute 'rti'.
receiver
                    tfr       u,y       ; restore CMOC data-area pointer for handler call
                    clra                ; build 16-bit signal argument high byte
                    pshs      d         ; pass signal number as a C int
                    jsr       [_intsave,y] ; call the installed C signal handler
                    leas      2,s       ; discard stacked signal argument
                    rti                 ; return from OS-9 interrupt frame

                    endsect   ;         end current section
