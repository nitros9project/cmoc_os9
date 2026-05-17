* Adapted from cmoc_os9/lib/ported/calloc.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_calloc             EXPORT              ; export this symbol

ccmult              EXTERN              ; import external symbol
_malloc             EXTERN              ; import external symbol

_calloc
                    pshs      u         ; save U on the hardware stack
                    ldd       4,s       ; load D from stack-relative value 4,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    pshs      x         ; preserve the element count while computing the allocation size
                    lbsr      ccmult    ; multiply the element count by the element size
                    pshs      d         ; save the total allocation size for the post-malloc clear loop
                    lbsr      _malloc   ; long branch to subroutine to _malloc
                    std       -2,s      ; keep the malloc result on the stack as the function return value
                    beq       BranchTarget_01 ; skip the clear loop when malloc returned NULL
                    ldx       ,s        ; load X from memory pointed to by S
                    tfr       d,u       ; copy the allocated block pointer into U for byte-by-byte clearing
Loop_01             clr       ,u+       ; clear memory pointed to by U, then advance U
                    leax      -1,x      ; decrement the remaining byte count
                    bne       Loop_01   ; continue zero-filling until the full block has been cleared
BranchTarget_01     leas      2,s       ; adjust S using 2,s
                    puls      u,pc      ; restore U and return the malloc result in D

                    endsect             ; end current section
