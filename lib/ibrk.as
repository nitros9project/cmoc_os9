*
* Make pointers within initial memory allocation
* Adapted from cmoc_os9/lib/todo/ibrk.a for the live CMOC ABI.
*

                    section   code      ; begin code section

_ibrk               EXPORT              ; export this symbol

__mtop              EXTERNAL            ; import external symbol
__stbot             EXTERNAL            ; import external symbol
_os9err             EXTERNAL            ; import external symbol

_ibrk               ldd       2,s       ; get the size required
                    addd      __mtop,y  ; add current top
                    bcs       ibrk20    ; if it wraps, error
                    cmpd      __stbot,y ; overlap stack?
                    bhs       ibrk20    ; branch if higher or same to ibrk20
                    pshs      d         ; save new top
                    ldx       __mtop,y  ; reset to bottom

                    clra                ; clear A
sbloop              cmpx      0,s       ; reached the end?
                    bhs       ibrk10    ; branch if higher or same to ibrk10
                    sta       ,x+       ; store A to memory pointed to by X, then advance X
                    bra       sbloop    ; branch unconditionally to sbloop

ibrk10              ldd       __mtop,y  ; return old top
                    puls      x         ; restore new top
                    stx       __mtop,y  ; save for next time
                    rts                 ; return to caller

ibrk20              ldb       #$ED      ; E$NoRAM
                    lbra      _os9err   ; long branch unconditionally to _os9err

                    endsect             ; end current section
