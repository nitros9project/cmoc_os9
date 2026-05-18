* Adapted from cmoc_os9/lib/ported/calloc.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_calloc             EXPORT    ;         export this symbol

ccmult              EXTERN    ;         import external symbol
_malloc             EXTERN    ;         import external symbol

_calloc:
stk_calloc_ret      equ       0         ; caller return address
stk_calloc_count    equ       2         ; number of elements requested
stk_calloc_size     equ       4         ; size of each element
stk_calloc_alloc_size equ       0         ; temporary malloc byte-count argument after PSHS D
                    pshs      u         ; save U on the hardware stack
                    ldd       stk_calloc_count+2,s ; load element count after saved U
                    ldx       stk_calloc_size+2,s ; load element size after saved U
                    pshs      x         ; pass size as the stacked operand to ccmult
                    lbsr      ccmult    ; compute count * size in D
                    pshs      d         ; pass total allocation size to malloc and keep it for clearing
                    lbsr      _malloc   ; allocate the requested byte count
                    std       stk_calloc_alloc_size-2,s ; place malloc result in the caller's return slot
                    beq       BranchTarget_01 ; skip the clear loop when malloc returned NULL
                    ldx       stk_calloc_alloc_size,s ; reload allocation byte count for zero-fill loop
                    tfr       d,u       ; copy the allocated block pointer into U for byte-by-byte clearing
Loop_01             clr       ,u+       ; clear memory pointed to by U, then advance U
                    leax      -1,x      ; decrement the remaining byte count
                    bne       Loop_01   ; continue zero-filling until the full block has been cleared
BranchTarget_01     leas      stk_calloc_alloc_size+2,s ; discard malloc byte-count argument
                    puls      u,pc      ; restore U and return the malloc result in D

                    endsect   ;         end current section
