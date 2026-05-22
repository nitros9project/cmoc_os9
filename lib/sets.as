* Adapted from cmoc_os9/lib/todo/sets.as

                    section   code      ; begin code section

_allocset           EXPORT    ;         export 256-bit set allocator
_addc2set           EXPORT    ;         export single-character add-to-set helper
_adds2set           EXPORT    ;         export string add-to-set helper
_rmfmset            EXPORT    ;         export single-character remove-from-set helper
_smember            EXPORT    ;         export set membership tester
_dupset             EXPORT    ;         export set duplicator
_copyset            EXPORT    ;         export set copy helper
_sunion             EXPORT    ;         export set union helper
_sintersect         EXPORT    ;         export set intersection helper
_sdifference        EXPORT    ;         export set difference helper

_malloc             EXTERNAL  ;         import heap allocator

_allocset:
stk_allocset_ret    equ       0         ; caller return address
                    ldd       #$0020    ; allocate 32 bytes for a 256-bit character set
                    pshs      d         ; pass allocation size to malloc
                    lbsr      _malloc   ; allocate set storage
                    puls      x,pc      ; discard size word and return malloc result

_addc2set:
stk_addc2set_ret    equ       0         ; caller return address
stk_addc2set_set    equ       2         ; destination set pointer
stk_addc2set_char   equ       4         ; character value to add
                    bsr       bitaddr   ; compute set byte index in A and bit mask in B
                    orb       a,x       ; set the selected bit in the target byte
                    stb       a,x       ; write updated target byte
                    tfr       x,d       ; return set pointer
                    rts                 ; return to caller

_adds2set:
stk_adds2set_ret    equ       0         ; caller return address
stk_adds2set_set    equ       2         ; destination set pointer
stk_adds2set_string equ       4         ; NUL-terminated source string
                    pshs      u         ; preserve caller's U register
                    ldu       stk_adds2set_string+2,s ; load string pointer after saved U
                    ldx       stk_adds2set_set+2,s ; load destination set pointer after saved U
                    bra       adds_loop_load ; fetch first source character
adds_loop
                    bsr       bitmask   ; compute set byte index in A and bit mask in B
                    orb       a,x       ; set selected bit in destination set
                    stb       a,x       ; write updated set byte
adds_loop_load
                    lda       ,u+       ; load next source character and advance
                    bne       adds_loop ; stop at NUL terminator
                    ldd       stk_adds2set_set+2,s ; return destination set pointer after saved U
                    puls      u,pc      ; restore U and return

_rmfmset:
stk_rmfmset_ret     equ       0         ; caller return address
stk_rmfmset_set     equ       2         ; destination set pointer
stk_rmfmset_char    equ       4         ; character value to remove
                    bsr       bitaddr   ; compute set byte index in A and bit mask in B
                    comb                ; invert bit mask to clear the selected bit
                    andb      a,x       ; clear selected bit in target byte
                    stb       a,x       ; write updated target byte
                    clrb                ; clear low byte before returning set pointer in D
                    tfr       x,d       ; return set pointer
                    rts                 ; return to caller

_smember:
stk_smember_ret     equ       0         ; caller return address
stk_smember_set     equ       2         ; set pointer
stk_smember_char    equ       4         ; character value to test
                    bsr       bitaddr   ; compute set byte index in A and bit mask in B
                    andb      a,x       ; leave B nonzero when the bit is present
                    clra                ; return membership result as an int in D
                    rts                 ; return to caller

bitaddr
stk_bitaddr_ret     equ       0         ; BSR return address back to set wrapper
stk_bitaddr_caller_ret equ       2         ; wrapper caller return address
stk_bitaddr_set     equ       4         ; set pointer from wrapper argument frame
stk_bitaddr_char    equ       6         ; character argument from wrapper argument frame
                    ldx       stk_bitaddr_set,s ; load set pointer from caller frame through BSR return
                    lda       stk_bitaddr_char+1,s ; load low byte of character argument through BSR return
bitmask
                    pshs      a         ; save original character value for byte-index calculation
                    ldb       #1        ; start mask at bit 0
                    anda      #7        ; keep character bit index within its byte
                    beq       bitmask_done ; no shifts needed for bit 0
bitmask_shift
                    lslb                ; move mask to the next bit position
                    deca                ; count down requested bit shifts
                    bne       bitmask_shift ; continue until mask is positioned
bitmask_done
                    puls      a         ; restore original character value
                    asra                ; divide by 2 as part of byte index calculation
                    asra                ; divide by 4 as part of byte index calculation
                    asra                ; divide by 8 for final set byte index
                    rts                 ; return with byte index in A and bit mask in B

_dupset:
stk_dupset_ret      equ       0         ; caller return address
stk_dupset_source   equ       2         ; source set pointer
                    bsr       _allocset ; allocate destination set
                    ldx       stk_dupset_source,s ; load source set pointer
                    pshs      d,x       ; stage destination and source for copyset
                    bsr       _copyset  ; copy source set into new storage
                    puls      d,x,pc    ; return allocated destination pointer

_copyset:
stk_copyset_ret     equ       0         ; caller return address
stk_copyset_dest    equ       2         ; destination set pointer
stk_copyset_source  equ       4         ; source set pointer
                    pshs      u         ; preserve caller's U register
                    ldx       stk_copyset_dest+2,s ; load destination pointer after saved U
                    ldu       stk_copyset_source+2,s ; load source pointer after saved U
                    ldb       #$20      ; copy all 32 bytes of the bitset
copy_loop
                    lda       ,u+       ; copy next source byte
                    sta       ,x+       ; store byte and advance destination
                    decb                ; count one set byte copied
                    bne       copy_loop ; continue through the 32-byte set
                    ldd       stk_copyset_dest+2,s ; return destination pointer after saved U
                    puls      u,pc      ; restore U and return

_sunion:
stk_sunion_ret      equ       0         ; caller return address
stk_sunion_dest     equ       2         ; destination set pointer, updated in place
stk_sunion_source   equ       4         ; source set pointer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_sunion_dest+2,s ; load destination pointer after saved U
                    ldx       stk_sunion_source+2,s ; load source pointer after saved U
                    ldb       #$20      ; process all 32 bytes of the bitset
union_loop
                    lda       ,x+       ; load next source set byte
                    ora       ,u        ; merge source bits into destination byte
                    sta       ,u+       ; store updated destination byte
                    decb                ; count one set byte processed
                    bne       union_loop ; continue through the 32-byte set
                    ldd       stk_sunion_dest+2,s ; return destination pointer after saved U
                    puls      u,pc      ; restore U and return

_sintersect:
stk_sintersect_ret  equ       0         ; caller return address
stk_sintersect_dest equ       2         ; destination set pointer, updated in place
stk_sintersect_source equ       4         ; source set pointer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_sintersect_dest+2,s ; load destination pointer after saved U
                    ldx       stk_sintersect_source+2,s ; load source pointer after saved U
                    ldb       #$20      ; process all 32 bytes of the bitset
intersect_loop
                    lda       ,x+       ; load next source set byte
                    anda      ,u        ; keep only bits present in both sets
                    sta       ,u+       ; store updated destination byte
                    decb                ; count one set byte processed
                    bne       intersect_loop ; continue through the 32-byte set
                    ldd       stk_sintersect_dest+2,s ; return destination pointer after saved U
                    puls      u,pc      ; restore U and return

_sdifference:
stk_sdifference_ret equ       0         ; caller return address
stk_sdifference_dest equ       2         ; destination set pointer, updated in place
stk_sdifference_source equ       4         ; source set pointer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_sdifference_dest+2,s ; load destination pointer after saved U
                    ldx       stk_sdifference_source+2,s ; load source pointer after saved U
                    ldb       #$20      ; process all 32 bytes of the bitset
difference_loop
                    lda       ,x+       ; load next source set byte
                    eora      ,u        ; toggle destination bits present in source
                    sta       ,u+       ; store updated destination byte
                    decb                ; count one set byte processed
                    bne       difference_loop ; continue through the 32-byte set
                    ldd       stk_sdifference_dest+2,s ; return destination pointer after saved U
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
