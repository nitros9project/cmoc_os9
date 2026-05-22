* CMOC long move helper ABI: X points at the source long and the destination
* pointer is on the caller stack. The helper copies four bytes and repairs the
* stack so the caller resumes with the destination value available.

                    section   code      ; begin code section

_lmove              EXPORT    ;         export this symbol

_lmove:
stk_lmove_ret       equ       0         ; caller return address
stk_lmove_dest      equ       2         ; destination pointer supplied on caller stack
                    pshs      y         ; save CMOC frame pointer before using Y as destination
                    ldy       stk_lmove_dest+2,s ; saved Y shifts the stacked destination pointer by 2 bytes
                    ldd       ,x        ; copy source high word
                    std       ,y        ; store destination high word
                    ldd       2,x       ; copy source low word
                    std       2,y       ; store destination low word
                    puls      x         ; recover saved Y into X for the swap below
                    exg       y,x       ; exchange Y,X
                    puls      d         ; pull caller return address, leaving S at stacked destination
                    std       stk_lmove_dest-2,s ; place return address over the consumed destination pointer
                    rts                 ; return to caller

                    endsect   ;         end current section
