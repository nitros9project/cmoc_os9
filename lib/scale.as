                    section   rodata    ; begin rodata section

* Initialized Data (class G)
atoftbl:            fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $80       ; define byte data $80
                    fcb       $20       ; define byte data $20
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $84       ; define byte data $84
                    fcb       $48       ; define byte data $48
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $87       ; define byte data $87
                    fcb       $7a       ; define byte data $7a
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $8a       ; define byte data $8a
                    fcb       $1c       ; define byte data $1c
                    fcb       $40       ; define byte data $40
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $8e       ; define byte data $8e
                    fcb       $43       ; define byte data $43
                    fcb       $50       ; define byte data $50
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $91       ; define byte data $91
                    fcb       $74       ; define byte data $74
                    fcb       $24       ; define byte data $24
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $94       ; define byte data $94
                    fcb       $18       ; define byte data $18
                    fcb       $96       ; define byte data $96
                    fcb       $80       ; define byte data $80
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $98       ; define byte data $98
                    fcb       $3e       ; define byte data $3e
                    fcb       $bc       ; define byte data $bc
                    fcb       $20       ; define byte data $20
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $9b       ; define byte data $9b
                    fcb       $6e       ; define byte data $6e
                    fcb       $6b       ; define byte data $6b
                    fcb       $28       ; define byte data $28
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $9e       ; define byte data $9e
                    fcb       $15       ; define byte data $15
                    fcb       $02       ; define byte data $02
                    fcb       $f9       ; define byte data $f9
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $a2       ; define byte data $a2
                    fcb       $2d       ; define byte data $2d
                    fcb       $78       ; define byte data $78
                    fcb       $eb       ; define byte data $eb
                    fcb       $c5       ; define byte data $c5
                    fcb       $ac       ; define byte data $ac
                    fcb       $62       ; define byte data $62
                    fcb       $00       ; define byte data $00
                    fcb       $c3       ; define byte data $c3
                    fcb       $49       ; define byte data $49
                    fcb       $f2       ; define byte data $f2
                    fcb       $c9       ; define byte data $c9
                    fcb       $cd       ; define byte data $cd
                    fcb       $04       ; define byte data $04
                    fcb       $67       ; define byte data $67
                    fcb       $4f       ; define byte data $4f
                    fcb       $e4       ; define byte data $e4

                    endsect   ;         end current section

                    section   code      ; begin code section

_scale              EXPORT    ;         export double decimal scaling helper

_dmul               EXTERNAL  ;         import double multiply helper
_ddiv               EXTERNAL  ;         import double divide helper
_dmove              EXTERNAL  ;         import double move helper
_dstack             EXTERNAL  ;         import double stack helper
ccdiv               EXTERNAL  ;         import signed 16-bit divide helper
ccmod               EXTERNAL  ;         import signed 16-bit modulo helper
_flacc              EXTERNAL  ;         import shared double accumulator

Subroutine_01
stk_scale_step_ret  equ       0         ; caller return address
stk_scale_step_value equ       2         ; double value being scaled
stk_scale_step_digit equ       10        ; decimal power-table index
stk_scale_step_direction equ       12        ; zero divides, nonzero multiplies
stk_scale_step_power equ       18        ; table power index after saved U
                    pshs      u         ; preserve caller's U register
                    ldd       stk_scale_step_digit+2,s ; load decimal power digit after saved U
                    beq       BranchTarget_02 ; skip multiply/divide when digit is zero
                    ldd       stk_scale_step_direction+2,s ; load scale direction after saved U
                    beq       BranchTarget_01 ; zero direction means divide by table entry
                    leax      stk_scale_step_value+2,s ; point X at double value after saved U
                    lbsr      _dstack   ; push current double value to the FP stack
                    ldd       stk_scale_step_power+2,s ; load decimal power-table index after saved U
                    lslb                ; multiply index by 2
                    rola                ; propagate index shift into high byte
                    lslb                ; multiply index by 4
                    rola                ; propagate index shift into high byte
                    lslb                ; multiply index by 8-byte table entry size
                    rola                ; propagate index shift into high byte
                    leax      atoftbl,pcr ; point X at power-of-ten table
                    leax      d,x       ; select requested power-of-ten entry
                    lbsr      _dmul     ; multiply value by selected power of ten
                    bra       Continue_01 ; store result in shared accumulator
BranchTarget_01     leax      stk_scale_step_value+2,s ; point X at double value after saved U
                    lbsr      _dstack   ; push current double value to the FP stack
                    ldd       stk_scale_step_power+2,s ; load decimal power-table index after saved U
                    lslb                ; multiply index by 2
                    rola                ; propagate index shift into high byte
                    lslb                ; multiply index by 4
                    rola                ; propagate index shift into high byte
                    lslb                ; multiply index by 8-byte table entry size
                    rola                ; propagate index shift into high byte
                    leax      atoftbl,y ; point X at power-of-ten table in data space
                    leax      d,x       ; select requested power-of-ten entry
                    lbsr      _ddiv     ; divide value by selected power of ten
                    bra       Continue_01 ; store result in shared accumulator
BranchTarget_02     leax      stk_scale_step_value+2,s ; point X at unchanged double value after saved U
Continue_01         leau      _flacc,y  ; point U at shared FP accumulator
                    pshs      u         ; pass destination accumulator to dmove
                    lbsr      _dmove    ; copy scaled value into accumulator
                    puls      u,pc      ; discard destination pointer, restore U, and return
_scale:
stk_scale_ret       equ       0         ; caller return address
stk_scale_value     equ       2         ; double value to scale
stk_scale_power     equ       10        ; decimal exponent magnitude
stk_scale_direction equ       12        ; zero divides, nonzero multiplies
                    pshs      u         ; preserve caller's U register
                    ldd       stk_scale_power+2,s ; load decimal exponent after saved U
                    cmpd      #9        ; large exponents are handled in chunks of ten
                    ble       BranchTarget_03 ; skip chunk scaling for small exponents
                    leax      stk_scale_value+2,s ; point X at current double value after saved U
                    pshs      x         ; stage value pointer for dmove after recursive chunk
                    ldd       stk_scale_direction+4,s ; load direction after saved U and staged pointer
                    pshs      d         ; stage direction for chunk scale
                    ldd       stk_scale_power+6,s ; load exponent after staged pointer/direction
                    pshs      d         ; pass exponent to division helper
                    ldd       #$000a    ; divide exponent by ten
                    lbsr      ccdiv     ; compute number of ten-power chunks
                    addd      #9        ; bias chunk count for table lookup
                    pshs      d         ; stage chunk-table index
                    leax      10,s      ; point X at staged frame expected by _dstack
                    lbsr      _dstack   ; push staged double value to FP stack
                    lbsr      Subroutine_01 ; scale by the chunked power of ten
                    leas      12,s      ; discard staged pointer/direction/exponent/chunk arguments
                    lbsr      _dmove    ; copy chunk-scaled value back into caller's value slot
BranchTarget_03     ldd       stk_scale_direction+2,s ; load direction after saved U for final digit scaling
                    pshs      d         ; stage direction for final digit scaling
                    ldd       stk_scale_power+4,s ; load exponent after saved U and staged direction
                    pshs      d         ; pass exponent to modulo helper
                    ldd       #$000a    ; compute exponent modulo ten
                    lbsr      ccmod     ; return final table digit
                    pshs      d         ; stage final decimal digit
                    leax      8,s       ; point X at staged frame expected by _dstack
                    lbsr      _dstack   ; push staged double value to FP stack
                    lbsr      Subroutine_01 ; apply final power-of-ten digit
                    leas      12,s      ; discard staged modulo/digit arguments
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
