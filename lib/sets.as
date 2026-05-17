* Adapted from cmoc_os9/lib/todo/sets.as

                    section   code      ; begin code section

_allocset           EXPORT              ; export this symbol
_addc2set           EXPORT              ; export this symbol
_adds2set           EXPORT              ; export this symbol
_rmfmset            EXPORT              ; export this symbol
_smember            EXPORT              ; export this symbol
_dupset             EXPORT              ; export this symbol
_copyset            EXPORT              ; export this symbol
_sunion             EXPORT              ; export this symbol
_sintersect         EXPORT              ; export this symbol
_sdifference        EXPORT              ; export this symbol

_malloc             EXTERNAL            ; import external symbol

_allocset
                    ldd       #$0020    ; load D from immediate value $0020
                    pshs      d         ; save D on the hardware stack
                    lbsr      _malloc   ; long branch to subroutine to _malloc
                    puls      x,pc      ; restore registers and return

_addc2set
                    bsr       bitaddr   ; branch to subroutine to bitaddr
                    orb       a,x       ; OR B with indexed value a,x
                    stb       a,x       ; store B to indexed value a,x
                    tfr       x,d       ; transfer X,D
                    rts                 ; return to caller

_adds2set
                    pshs      u         ; save U on the hardware stack
                    ldu       6,s       ; load U from stack-relative value 6,s
                    ldx       4,s       ; load X from stack-relative value 4,s
                    bra       adds_loop_load ; branch unconditionally to adds_loop_load
adds_loop
                    bsr       bitmask   ; branch to subroutine to bitmask
                    orb       a,x       ; OR B with indexed value a,x
                    stb       a,x       ; store B to indexed value a,x
adds_loop_load
                    lda       ,u+       ; load A from memory pointed to by U, then advance U
                    bne       adds_loop ; branch if not equal to adds_loop
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

_rmfmset
                    bsr       bitaddr   ; branch to subroutine to bitaddr
                    comb
                    andb      a,x       ; AND B with indexed value a,x
                    stb       a,x       ; store B to indexed value a,x
                    clrb                ; clear B
                    tfr       x,d       ; transfer X,D
                    rts                 ; return to caller

_smember
                    bsr       bitaddr   ; branch to subroutine to bitaddr
                    andb      a,x       ; AND B with indexed value a,x
                    clra                ; clear A
                    rts                 ; return to caller

bitaddr
                    ldx       4,s       ; load X from stack-relative value 4,s
                    lda       7,s       ; load A from stack-relative value 7,s
bitmask
                    pshs      a         ; save A on the hardware stack
                    ldb       #1        ; load B from immediate value 1
                    anda      #7        ; AND A with immediate value 7
                    beq       bitmask_done ; branch if equal/zero to bitmask_done
bitmask_shift
                    lslb                ; shift B left by one bit
                    deca                ; decrement A
                    bne       bitmask_shift ; branch if not equal to bitmask_shift
bitmask_done
                    puls      a         ; restore A from the hardware stack
                    asra                ; arithmetic shift A right by one bit
                    asra                ; arithmetic shift A right by one bit
                    asra                ; arithmetic shift A right by one bit
                    rts                 ; return to caller

_dupset
                    bsr       _allocset ; branch to subroutine to _allocset
                    ldx       2,s       ; load X from stack-relative value 2,s
                    pshs      d,x       ; save D,X on the hardware stack
                    bsr       _copyset  ; branch to subroutine to _copyset
                    puls      d,x,pc    ; restore registers and return

_copyset
                    pshs      u         ; save U on the hardware stack
                    ldx       4,s       ; load X from stack-relative value 4,s
                    ldu       6,s       ; load U from stack-relative value 6,s
                    ldb       #$20      ; load B from immediate value $20
copy_loop
                    lda       ,u+       ; load A from memory pointed to by U, then advance U
                    sta       ,x+       ; store A to memory pointed to by X, then advance X
                    decb                ; decrement B
                    bne       copy_loop ; branch if not equal to copy_loop
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

_sunion
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldb       #$20      ; load B from immediate value $20
union_loop
                    lda       ,x+       ; load A from memory pointed to by X, then advance X
                    ora       ,u        ; OR A with memory pointed to by U
                    sta       ,u+       ; store A to memory pointed to by U, then advance U
                    decb                ; decrement B
                    bne       union_loop ; branch if not equal to union_loop
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

_sintersect
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldb       #$20      ; load B from immediate value $20
intersect_loop
                    lda       ,x+       ; load A from memory pointed to by X, then advance X
                    anda      ,u        ; AND A with memory pointed to by U
                    sta       ,u+       ; store A to memory pointed to by U, then advance U
                    decb                ; decrement B
                    bne       intersect_loop ; branch if not equal to intersect_loop
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

_sdifference
                    pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldb       #$20      ; load B from immediate value $20
difference_loop
                    lda       ,x+       ; load A from memory pointed to by X, then advance X
                    eora      ,u        ; XOR A with memory pointed to by U
                    sta       ,u+       ; store A to memory pointed to by U, then advance U
                    decb                ; decrement B
                    bne       difference_loop ; branch if not equal to difference_loop
                    ldd       4,s       ; load D from stack-relative value 4,s
                    puls      u,pc      ; restore registers and return

                    endsect             ; end current section
