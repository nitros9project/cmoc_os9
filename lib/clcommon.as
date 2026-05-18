* Shared CMOC long helper ABI support.
* _lbexit restores the caller's stacked return address after a helper consumes
* a 32-bit stack operand, returns X pointing at _flacc, and preserves CC.
* _ltoacc copies the X-pointed 32-bit long into _flacc and returns X=_flacc.

                    section   code      ; begin code section

_flacc              EXTERNAL  ;         import external symbol
_lbexit             EXPORT    ;         export this symbol
_ltoacc             EXPORT    ;         export this symbol

_lbexit:
stk_lbexit_ret      equ       0         ; caller return address at helper entry
stk_lbexit_long_hi  equ       2         ; consumed stacked long, bits 31-16
stk_lbexit_long_lo  equ       4         ; consumed stacked long, bits 15-0
                    tfr       cc,a      ; preserve helper condition codes while rearranging the stack
                    puls      x         ; pull caller return address; S now points at consumed long high word
                    stx       stk_lbexit_long_lo-2,s ; move return address over consumed long low word
                    leas      stk_lbexit_long_hi,s ; discard consumed long high word
                    leax      _flacc,y  ; return X pointing at the shared long result
                    tfr       a,cc      ; restore helper condition codes for caller
                    rts                 ; return to caller
_ltoacc:            ldd       ,x        ; copy source long high word into D
                    std       _flacc,y  ; store source high word in result buffer
                    ldd       2,x       ; copy source long low word into D
                    leax      _flacc,y  ; return X pointing at the result buffer
                    std       2,x       ; store source low word in result buffer
                    rts                 ; return to caller

                    endsect   ;         end current section
