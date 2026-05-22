* Adapted from cmoc_os9/lib/todo/bsearch.as for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_bsearch            EXPORT    ;         export binary-search entry point

ccmult              EXTERNAL  ;         16-bit multiply helper

_bsearch:
stk_bsearch_ret     equ       0         ; caller return address
stk_bsearch_arg1    equ       2         ; first C argument
stk_bsearch_arg2    equ       4         ; second C argument
stk_bsearch_arg3    equ       6         ; third C argument
stk_bsearch_arg4    equ       8         ; fourth C argument
stk_bsearch_arg5    equ       10        ; comparison-function pointer
stk_bsearch_temp0   equ       0         ; scratch pointer/result slot after pshs d,x,y,u
stk_bsearch_low     equ       2         ; lower search bound stored in saved-X space
stk_bsearch_mid     equ       4         ; midpoint stored in saved-Y space
stk_bsearch_saved_u equ       6         ; saved U register
                    pshs      d,x,y,u   ; preserve U and reserve scratch slots in saved-register space
                    ldu       stk_bsearch_arg1+8,s ; keep the first argument for comparator calls
                    clra                ; initialize lower bound high byte to zero
                    clrb                ; initialize lower bound low byte to zero
Loop_01             addd      #1        ; advance the lower-bound candidate
                    std       stk_bsearch_low,s ; save the updated lower bound
                    ldd       stk_bsearch_arg3+8,s ; load current upper/count argument
Loop_02             subd      stk_bsearch_low,s ; test whether the range is exhausted
                    bmi       ReturnZero_01 ; return NULL when lower bound passed upper bound
                    ldd       stk_bsearch_arg3+8,s ; reload the current upper/count argument
                    addd      stk_bsearch_low,s ; form low+high before dividing by two
                    lsra                ; divide midpoint high byte by two
                    rorb                ; divide midpoint low byte by two through carry
                    std       stk_bsearch_mid,s ; save midpoint index
                    addd      #-1       ; convert midpoint to zero-based element index
                    pshs      d         ; pass index to multiply helper and shift original frame by two
                    ldd       stk_bsearch_arg4+10,s ; load element-size argument after pushed index
                    lbsr      ccmult    ; compute index * element size
                    addd      stk_bsearch_arg1+10,s ; add original first-argument pointer after pushed index
                    std       ,s        ; replace temporary index with computed element pointer
                    pshs      u         ; pass saved first argument as the other comparator argument
                    jsr       [stk_bsearch_arg5+10,s] ; call comparison function after two pushed arguments
                    std       ,s++      ; drop comparator argument while preserving compare result
                    beq       BranchTarget_01 ; comparator matched the current candidate
                    asla                ; move comparison sign into carry for range update
                    ldd       stk_bsearch_mid,s ; reload midpoint index
                    bcc       Loop_01   ; comparison selects the upper half
                    addd      #-1       ; comparison selects the lower half, so reduce upper bound
                    std       stk_bsearch_arg3+8,s ; store new upper/count argument in caller slot
                    bra       Loop_02   ; continue searching the reduced range
ReturnZero_01       clra                ; return NULL high byte
                    clrb                ; return NULL low byte
                    bra       Continue_01 ; skip matched-pointer return
BranchTarget_01     ldd       stk_bsearch_temp0,s ; return matched element pointer
Continue_01         leas      6,s       ; discard scratch D/X/Y slots, leaving saved U on top
                    puls      u,pc      ; restore registers and return

                    endsect   ;         end current section
