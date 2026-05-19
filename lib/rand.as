* Adapted from Deek's KLibc rand.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_rand               EXPORT    ;         export pseudo-random number generator
_srand              EXPORT    ;         export pseudo-random seed initializer

_lmul               EXTERN    ;         import CMOC long multiply helper
_ladd               EXTERN    ;         import CMOC long add helper

                    section   bss       ; begin bss section
L_next              rmb       4         ; current 32-bit linear-congruential generator state
                    endsect   ;         end current section

                    section   code      ; begin code section

_rand:
stk_rand_ret        equ       0         ; caller return address
                    pshs      u         ; preserve caller's U register
                    leax      L_next,y  ; point X at current generator state
                    ldd       ,x        ; load high word of current state
                    ldu       2,x       ; load low word of current state
                    pshs      d,u       ; pass current state to long multiply
                    leax      L_mcon,pcr ; point X at multiplier constant
                    lbsr      _lmul     ; compute state * multiplier
                    ldd       ,x        ; load high word of product
                    ldu       2,x       ; load low word of product
                    pshs      d,u       ; pass product to long add
                    leax      L_acon,pcr ; point X at addend constant
                    lbsr      _ladd     ; compute next linear-congruential state
                    leau      L_next,y  ; point U at stored generator state
                    ldd       ,x        ; fetch high word of next state
                    ldx       2,x       ; fetch low word of next state
                    std       ,u        ; store high word of next state
                    stx       2,u       ; store low word of next state
                    anda      #$7f      ; keep returned value non-negative
                    puls      u,pc      ; restore U and return high word as int

_srand:
stk_srand_ret       equ       0         ; caller return address
stk_srand_seed      equ       2         ; 16-bit seed argument
                    leax      L_next,y  ; point X at stored generator state
                    ldd       stk_srand_seed,s ; load caller-provided seed
                    std       2,x       ; store seed as low word of state
                    clra                ; clear high word of seed state
                    clrb                ; clear high word of seed state
                    std       ,x        ; store zero high word of state
                    rts                 ; return to caller

L_mcon              fdb       16838,20077 ; multiplier constant $41c64e6d
L_acon              fdb       0,12345   ; addend constant $00003039

                    endsect   ;         end current section
