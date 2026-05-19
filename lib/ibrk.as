*
* Make pointers within initial memory allocation
* Adapted from cmoc_os9/lib/todo/ibrk.a for the live CMOC ABI.
*

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_ibrk               EXPORT    ;         export this symbol

__mtop              EXTERNAL  ;         import external symbol
__stbot             EXTERNAL  ;         import external symbol
_os9err             EXTERNAL  ;         import external symbol

_ibrk:
stk_ibrk_ret        equ       0         ; caller return address
stk_ibrk_size       equ       2         ; requested additional allocation size
stk_ibrk_new_top    equ       0         ; temporary top pointer after pshs d
                    ldd       stk_ibrk_size,s ; get requested allocation size
                    addd      __mtop,y  ; compute proposed heap top
                    bcs       ibrk_fail ; reject arithmetic wraparound
                    cmpd      __stbot,y ; reject allocations that would overlap the stack
                    bhs       ibrk_fail ; proposed top reached or crossed stack bottom
                    pshs      d         ; save proposed heap top while zeroing new memory
                    ldx       __mtop,y  ; start clearing at the previous heap top

                    clra                ; zero byte used to initialize the new allocation
ibrk_clear_loop     cmpx      stk_ibrk_new_top,s ; stop once old top reaches proposed top
                    bhs       ibrk_done ; no more bytes need clearing
                    sta       ,x+       ; clear next byte and advance through the allocation
                    bra       ibrk_clear_loop ; keep clearing the newly exposed memory

ibrk_done           ldd       __mtop,y  ; return previous heap top
                    puls      x         ; recover proposed heap top
                    stx       __mtop,y  ; commit new heap top for future allocations
                    rts                 ; return to caller

ibrk_fail           ldb       #E_NoRAM  ; report insufficient memory
                    lbra      _os9err   ; return failure through OS-9 error helper

                    endsect   ;         end current section
