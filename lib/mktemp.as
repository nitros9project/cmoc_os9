* Compact assembly implementation of mktemp().

                    section   code      ; begin code section

_mktemp             EXPORT    ;         export this symbol

_getpid             EXTERNAL  ;         import external symbol
_itoa               EXTERNAL  ;         import external symbol

_mktemp:
stk_mktemp_saved_u  equ       0         ; saved U register after pshs u
stk_mktemp_ret      equ       2         ; caller return address after pshs u
stk_mktemp_template equ       4         ; template string pointer
                    pshs      u         ; preserve U while scanning template
                    ldu       stk_mktemp_template,s ; load template string pointer
mktemp_scan
                    ldb       ,u+       ; read next template byte and advance cursor
                    beq       mktemp_done ; no X run found before terminator
                    cmpb      #'X
                    bne       mktemp_scan ; keep scanning until first X
                    leau      -1,u      ; back up to the first X
                    pshs      u         ; save replacement start pointer
                    ldd       #5        ; clear five template bytes before writing the PID
mktemp_zero_loop
                    sta       ,u+       ; write NUL and advance through X run
                    decb                ; count one cleared template byte
                    bne       mktemp_zero_loop ; clear the fixed five-byte replacement field
                    puls      u         ; recover replacement start pointer
                    lbsr      _getpid   ; get current process ID
                    pshs      d,u       ; pass pid and replacement buffer to itoa()
                    lbsr      _itoa     ; write decimal pid into template
                    leas      4,s       ; discard itoa() arguments
mktemp_done
                    ldd       stk_mktemp_template,s ; return original template pointer
                    puls      u,pc      ; restore registers and return

                    endsect   ;         end current section
