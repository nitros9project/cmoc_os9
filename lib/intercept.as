* Adapted from cmoc_os9/lib/todo/intercept.as for the live cmoc_os9 ABI.
*
* 'signal' and 'intercept' are incompatible by design.  Both modules export
* _sigint so the linker reports an entry-name clash if a program tries to use
* both.

                    section   bss       ; begin bss section

_intsave            rmb       2         ; place for C routine address

                    endsect             ; end current section

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_sigint             EXPORT              ; export this symbol
_intercept          EXPORT              ; export this symbol

_sysret             EXTERNAL            ; import external symbol

_sigint
_intercept
                    pshs      u         ; save register variable
                    tfr       y,u       ; set data area pointer
                    ldx       4,s       ; get C function address
                    stx       _intsave,y ; save it for the receiver
                    leax      receiver,pcr ; get the address for OS-9
                    os9       F_Icpt    ; call OS-9
                    puls      u         ; restore register variable
                    lbra      _sysret   ; long branch unconditionally to _sysret

* This is where OS-9 will pass control when the process has been
* sent a signal. All that is needed is to run the intercept routine
* and execute 'rti'.
receiver
                    tfr       u,y       ; set the data pointer
                    clra                ; clear the MSB
                    pshs      d         ; stack the signal number
                    jsr       [_intsave,y] ; go run the routine
                    leas      2,s       ; reset the stack
                    rti                 ; and return

                    endsect             ; end current section
