* Compact assembly implementation of gets().

                    section   code      ; begin code section

_gets               EXPORT    ;         export this symbol

_getc               EXTERNAL  ;         import character input helper
__iob               EXTERNAL  ;         import stdin FILE entry

_gets:
stk_gets_saved_u    equ       0         ; saved U after entry prologue
stk_gets_ret        equ       2         ; caller return address after entry prologue
stk_gets_buffer     equ       4         ; destination string buffer after entry prologue
                    pshs      u         ; preserve caller U while filling destination
                    ldu       stk_gets_buffer,s ; load destination buffer pointer
                    bra       L_gets_read ; read the first character before storing
L_gets_store
                    stb       ,u+       ; append character and advance destination pointer
L_gets_read
                    leax      __iob,y   ; point X at stdin FILE entry
                    pshs      x         ; pass stdin to _getc()
                    lbsr      _getc     ; read one character from stdin
                    leas      2,s       ; discard staged FILE pointer
                    cmpb      #$0D      ; stop on carriage return
                    beq       L_gets_done ; terminate destination on end-of-line
                    cmpd      #-1       ; EOF or error?
                    bne       L_gets_store ; keep copying ordinary characters
                    clra                ; return NULL high byte on EOF/error
                    clrb                ; return NULL low byte on EOF/error
                    bra       L_gets_exit ; return NULL without writing a terminator
L_gets_done
                    clr       ,u        ; terminate destination string
                    ldd       stk_gets_buffer,s ; return original destination pointer
L_gets_exit
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
