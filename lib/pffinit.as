* Disassembly by Os9disasm of _pffinit.r

                    section   bss       ; begin bss section

* Uninitialized data (class D)
pff_high_digit_idx  rmb       1         ; scratch byte used by packed-decimal helpers
* Initialized Data (class H)

                    endsect   ;         end current section


                    section   bss       ; begin bss section

* Uninitialized data (class B)
pff_buffer          rmb       1         ; first byte of formatted float output buffer
pff_buffer_tail     rmb       29        ; remaining formatted float output buffer bytes
pff_buffer_end      rmb       0         ; end marker for formatted float output buffer

                    endsect   ;         end current section

                    section   rodata    ; begin rodata section

* Initialized Data (class G)
pff_power_table     fcb       $00       ; packed double constant table used while scaling output
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $00       ; define byte data $00
                    fcb       $81       ; define byte data $81
                    fcb       $4c       ; define byte data $4c
                    fcb       $cc       ; define byte data $cc
                    fcb       $cc       ; define byte data $cc
                    fcb       $cc       ; define byte data $cc
                    fcb       $cc       ; define byte data $cc
                    fcb       $cc       ; define byte data $cc
                    fcb       $cd       ; define byte data $cd
                    fcb       $7d       ; define byte data $7d
                    fcb       $23       ; define byte data $23
                    fcb       $d7       ; define byte data $d7
                    fcb       $0a       ; define byte data $0a
                    fcb       $3d       ; define byte data $3d
                    fcb       $70       ; define byte data $70
                    fcb       $a3       ; define byte data $a3
                    fcb       $d7       ; define byte data $d7
                    fcb       $7a       ; define byte data $7a
                    fcb       $03       ; define byte data $03
                    fcb       $12       ; define byte data $12
                    fcb       $6e       ; define byte data $6e
                    fcb       $97       ; define byte data $97
                    fcb       $8d       ; define byte data $8d
                    fcb       $4f       ; define byte data $4f
                    fcb       $df       ; define byte data $df
                    fcb       $77       ; define byte data $77
                    fcb       $51       ; define byte data $51
                    fcb       $b7       ; define byte data $b7
                    fcb       $17       ; define byte data $17
                    fcb       $58       ; define byte data $58
                    fcb       $e2       ; define byte data $e2
                    fcb       $19       ; define byte data $19
                    fcb       $65       ; define byte data $65
                    fcb       $73       ; define byte data $73
                    fcb       $27       ; define byte data $27
                    fcb       $c5       ; define byte data $c5
                    fcb       $ac       ; define byte data $ac
                    fcb       $47       ; define byte data $47
                    fcb       $1b       ; define byte data $1b
                    fcb       $47       ; define byte data $47
                    fcb       $84       ; define byte data $84
                    fcb       $70       ; define byte data $70
                    fcb       $06       ; define byte data $06
                    fcb       $37       ; define byte data $37
                    fcb       $bd       ; define byte data $bd
                    fcb       $05       ; define byte data $05
                    fcb       $af       ; define byte data $af
                    fcb       $6c       ; define byte data $6c
                    fcb       $6a       ; define byte data $6a
                    fcb       $6d       ; define byte data $6d
                    fcb       $56       ; define byte data $56
                    fcb       $bf       ; define byte data $bf
                    fcb       $94       ; define byte data $94
                    fcb       $d5       ; define byte data $d5
                    fcb       $e5       ; define byte data $e5
                    fcb       $7a       ; define byte data $7a
                    fcb       $43       ; define byte data $43
                    fcb       $69       ; define byte data $69
                    fcb       $2b       ; define byte data $2b
                    fcb       $cc       ; define byte data $cc
                    fcb       $77       ; define byte data $77
                    fcb       $11       ; define byte data $11
                    fcb       $84       ; define byte data $84
                    fcb       $61       ; define byte data $61
                    fcb       $cf       ; define byte data $cf
                    fcb       $66       ; define byte data $66
                    fcb       $09       ; define byte data $09
                    fcb       $70       ; define byte data $70
                    fcb       $5f       ; define byte data $5f
                    fcb       $41       ; define byte data $41
                    fcb       $36       ; define byte data $36
                    fcb       $b4       ; define byte data $b4
                    fcb       $a6       ; define byte data $a6
                    fcb       $63       ; define byte data $63
                    fcb       $5b       ; define byte data $5b
                    fcb       $e6       ; define byte data $e6
                    fcb       $fe       ; define byte data $fe
                    fcb       $ce       ; define byte data $ce
                    fcb       $bd       ; define byte data $bd
                    fcb       $ed       ; define byte data $ed
                    fcb       $d6       ; define byte data $d6
                    fcb       $5f       ; define byte data $5f
                    fcb       $2f       ; define byte data $2f
                    fcb       $eb       ; define byte data $eb
                    fcb       $ff       ; define byte data $ff
                    fcb       $0b       ; define byte data $0b
                    fcb       $cb       ; define byte data $cb
                    fcb       $24       ; define byte data $24
                    fcb       $ab       ; define byte data $ab
                    fcb       $5c       ; define byte data $5c
                    fcb       $0c       ; define byte data $0c
                    fcb       $bc       ; define byte data $bc
                    fcb       $cc       ; define byte data $cc
                    fcb       $09       ; define byte data $09
                    fcb       $6f       ; define byte data $6f
                    fcb       $50       ; define byte data $50
                    fcb       $89       ; define byte data $89
                    fcb       $59       ; define byte data $59
                    fcb       $61       ; define byte data $61
                    fcb       $2e       ; define byte data $2e
                    fcb       $13       ; define byte data $13
                    fcb       $42       ; define byte data $42
                    fcb       $4b       ; define byte data $4b
                    fcb       $b4       ; define byte data $b4
                    fcb       $0e       ; define byte data $0e
                    fcb       $55       ; define byte data $55
                    fcb       $34       ; define byte data $34
                    fcb       $24       ; define byte data $24
                    fcb       $dc       ; define byte data $dc
                    fcb       $35       ; define byte data $35
                    fcb       $09       ; define byte data $09
                    fcb       $5c       ; define byte data $5c
                    fcb       $d8       ; define byte data $d8
                    fcb       $52       ; define byte data $52
                    fcb       $10       ; define byte data $10
                    fcb       $1d       ; define byte data $1d
                    fcb       $7c       ; define byte data $7c
                    fcb       $f7       ; define byte data $f7
                    fcb       $3a       ; define byte data $3a
                    fcb       $b0       ; define byte data $b0
                    fcb       $ad       ; define byte data $ad
                    fcb       $4f       ; define byte data $4f
                    fcb       $66       ; define byte data $66
                    fcb       $95       ; define byte data $95
                    fcb       $94       ; define byte data $94
                    fcb       $be       ; define byte data $be
                    fcb       $c4       ; define byte data $c4
                    fcb       $4d       ; define byte data $4d
                    fcb       $e1       ; define byte data $e1
                    fcb       $4b       ; define byte data $4b
                    fcb       $38       ; define byte data $38
                    fcb       $77       ; define byte data $77
                    fcb       $aa       ; define byte data $aa
                    fcb       $32       ; define byte data $32
                    fcb       $36       ; define byte data $36
                    fcb       $a4       ; define byte data $a4
                    fcb       $b4       ; define byte data $b4
                    fcb       $48       ; define byte data $48
pff_power_table_end fdb       pff_power_table_end ; self-reference terminator for constant table

                    endsect   ;         end current section

                    section   code      ; begin code section

_pffinit            EXPORT    ;         export float-format initialization hook
_pffloat            EXPORT    ;         export printf float-format helper
_chcodes            EXTERNAL  ;         import character-classification table
__iob               EXTERNAL  ;         import stdio stream table
_fprintf            EXTERNAL  ;         import formatted output helper
_exit               EXTERNAL  ;         import process termination helper
_dmove              EXTERNAL  ;         import double move helper
_dstack             EXTERNAL  ;         import double-stack helper
_dmul               EXTERNAL  ;         import double multiply helper
_dcmpr              EXTERNAL  ;         import double compare helper
_ddiv               EXTERNAL  ;         import double divide helper
_scale              EXTERNAL  ;         import double scale helper
ccmult              EXTERNAL  ;         import signed 16-bit multiply helper
ccasr               EXTERNAL  ;         import signed arithmetic-shift helper
ccdiv               EXTERNAL  ;         import signed 16-bit divide helper
ccmod               EXTERNAL  ;         import signed 16-bit modulo helper

_pffinit:
stk_pffinit_ret     equ       0         ; caller return address
                    pshs      u         ; preserve U for ABI consistency
                    puls      u,pc      ; restore U and return
_pffloat:
stk_pffloat_ret     equ       0         ; caller return address
stk_pffloat_spec    equ       2         ; conversion specifier argument
stk_pffloat_argp    equ       4         ; caller argument pointer block
                    pshs      d,u       ; preserve caller D/U and reserve type slot
                    ldx       stk_pffloat_spec+4,s ; load conversion specifier after saved D/U
                    bra       select_format_mode ; branch unconditionally to select_format_mode
fmt_fixed           ldd       #1        ; load D from immediate value 1
                    bra       store_format_mode ; branch unconditionally to store_format_mode
fmt_exponent        ldd       #-1       ; load D from immediate value -1
                    bra       store_format_mode ; branch unconditionally to store_format_mode
fmt_general         clra                ; clear A
                    clrb                ; clear B
store_format_mode   std       ,s        ; store D to memory pointed to by S
                    bra       classify_specifier ; branch unconditionally to classify_specifier
select_format_mode  cmpx      #'f
                    beq       fmt_fixed ; branch if equal/zero to fmt_fixed
                    cmpx      #'e
                    beq       fmt_exponent ; branch if equal/zero to fmt_exponent
                    cmpx      #'E
                    lbeq      fmt_exponent ; long branch if equal/zero to fmt_exponent
                    cmpx      #'g
                    beq       fmt_general ; branch if equal/zero to fmt_general
                    cmpx      #'G
                    lbeq      fmt_general ; long branch if equal/zero to fmt_general
classify_specifier  ldd       stk_pffloat_spec+4,s ; reload conversion specifier
                    leax      _chcodes,y ; point X at character-classification table
                    leax      d,x       ; index table by conversion specifier
                    ldb       ,x        ; read character-class flags
                    clra                ; clear A
                    andb      #2        ; AND B with immediate value 2
                    pshs      d         ; save D on the hardware stack
                    ldd       2,s       ; load D from stack-relative value 2,s
                    pshs      d         ; save D on the hardware stack
                    ldd       12,s      ; load D from stack-relative value 12,s
                    pshs      d         ; save D on the hardware stack
                    ldd       [16,s]    ; load D from indirect address [16,s]
                    addd      #8        ; add immediate value 8 into D
                    std       [16,s]    ; store D to indirect address [16,s]
                    subd      #8        ; subtract immediate value 8 from D
                    pshs      d         ; save D on the hardware stack
                    bsr       pff_convert ; branch to subroutine to pff_convert
                    leas      8,s       ; adjust S using 8,s
                    leas      2,s       ; adjust S using 2,s
                    puls      u,pc      ; restore registers and return
pff_convert
stk_pffconv_ret     equ       0         ; return address from _pffloat
stk_pffconv_floatp  equ       2         ; pointer to source double staged by _pffloat
                    pshs      u         ; preserve U while building local conversion frame
                    leas      -32,s     ; adjust S using -32,s
                    ldd       #1        ; load D from immediate value 1
                    std       8,s       ; store D to stack-relative value 8,s
                    leax      ,s        ; compute effective address into X from ,s
                    pshs      x         ; save X on the hardware stack
                    ldx       38,s      ; load X from stack-relative value 38,s
                    lbsr      _dmove    ; long branch to subroutine to _dmove
                    leau      ,s        ; compute effective address into U from ,s
                    ldb       7,u       ; load B from indexed value 7,u
                    bne       nonzero_input ; branch if not equal to nonzero_input
                    clra                ; clear A
                    clrb                ; clear B
                    std       24,s      ; store D to stack-relative value 24,s
                    std       26,s      ; store D to stack-relative value 26,s
                    std       18,s      ; store D to stack-relative value 18,s
                    leax      32,s      ; compute effective address into X from 32,s
                    lbra      zero_value_frame ; long branch unconditionally to zero_value_frame
nonzero_input       ldb       7,u       ; load B from indexed value 7,u
                    clra                ; clear A
                    addd      #-128     ; add immediate value -128 into D
                    std       22,s      ; store D to stack-relative value 22,s
                    bge       exponent_nonnegative ; branch if greater or equal to exponent_nonnegative
                    ldd       22,s      ; load D from stack-relative value 22,s
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    std       22,s      ; store D to stack-relative value 22,s
                    ldd       #1        ; load D from immediate value 1
                    bra       store_exponent_sign ; branch unconditionally to store_exponent_sign
exponent_nonnegative clra                ; clear A
                    clrb                ; clear B
store_exponent_sign std       24,s      ; store D to stack-relative value 24,s
                    ldd       22,s      ; load D from stack-relative value 22,s
                    pshs      d         ; save D on the hardware stack
                    ldd       #78       ; load D from immediate value 78
                    lbsr      ccmult    ; long branch to subroutine to ccmult
                    pshs      d         ; save D on the hardware stack
                    ldd       #8        ; load D from immediate value 8
                    lbsr      ccasr     ; long branch to subroutine to ccasr
                    std       20,s      ; store D to stack-relative value 20,s
                    ldd       24,s      ; load D from stack-relative value 24,s
                    beq       exponent_positive ; branch if equal/zero to exponent_positive
                    ldd       20,s      ; load D from stack-relative value 20,s
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    bra       store_decimal_exp ; branch unconditionally to store_decimal_exp
exponent_positive   ldd       20,s      ; load D from stack-relative value 20,s
store_decimal_exp   addd      #1        ; add immediate value 1 into D
                    std       18,s      ; store D to stack-relative value 18,s
                    ldb       ,u        ; load B from memory pointed to by U
                    bge       value_positive ; branch if greater or equal to value_positive
                    ldb       ,u        ; load B from memory pointed to by U
                    clra                ; clear A
                    andb      #$7f      ; AND B with immediate value $7f
                    stb       ,u        ; store B to memory pointed to by U
                    ldd       #1        ; load D from immediate value 1
                    bra       store_negative_flag ; branch unconditionally to store_negative_flag
value_positive      clra                ; clear A
                    clrb                ; clear B
store_negative_flag std       26,s      ; store D to stack-relative value 26,s
                    leax      ,s        ; compute effective address into X from ,s
                    pshs      x         ; save X on the hardware stack
                    ldd       26,s      ; load D from stack-relative value 26,s
                    pshs      d         ; save D on the hardware stack
                    ldd       24,s      ; load D from stack-relative value 24,s
                    pshs      d         ; save D on the hardware stack
                    leax      6,s       ; compute effective address into X from 6,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    lbsr      _scale    ; long branch to subroutine to _scale
                    leas      12,s      ; adjust S using 12,s
                    lbsr      _dmove    ; long branch to subroutine to _dmove
                    bra       compare_below_one ; branch unconditionally to compare_below_one
scale_up_by_ten     leax      ,s        ; compute effective address into X from ,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       pff_inline_mul10 ; branch to subroutine to pff_inline_mul10
                    fdb       8192,0,0,132 ; define word data 8192,0,0,132
pff_inline_mul10    puls      x         ; restore X from the hardware stack
                    lbsr      _dmul     ; long branch to subroutine to _dmul
                    lbsr      _dmove    ; long branch to subroutine to _dmove
                    ldd       18,s      ; load D from stack-relative value 18,s
                    addd      #-1       ; add immediate value -1 into D
                    std       18,s      ; store D to stack-relative value 18,s
compare_below_one   leax      ,s        ; compute effective address into X from ,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       pff_inline_cmp1 ; branch to subroutine to pff_inline_cmp1
                    fdb       0,0,0,129 ; define word data 0,0,0,129
pff_inline_cmp1     puls      x         ; restore X from the hardware stack
                    lbsr      _dcmpr    ; long branch to subroutine to _dcmpr
                    blt       scale_up_by_ten ; branch if less than to scale_up_by_ten
                    bra       compare_above_ten ; branch unconditionally to compare_above_ten
scale_down_by_ten   leax      ,s        ; compute effective address into X from ,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       pff_inline_div10 ; branch to subroutine to pff_inline_div10
                    fdb       8192,0,0,132 ; define word data 8192,0,0,132
pff_inline_div10    puls      x         ; restore X from the hardware stack
                    lbsr      _ddiv     ; long branch to subroutine to _ddiv
                    lbsr      _dmove    ; long branch to subroutine to _dmove
                    ldd       18,s      ; load D from stack-relative value 18,s
                    addd      #1        ; add immediate value 1 into D
                    std       18,s      ; store D to stack-relative value 18,s
compare_above_ten   leax      ,s        ; compute effective address into X from ,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       pff_inline_cmp10 ; branch to subroutine to pff_inline_cmp10
                    fdb       8192,0,0,132 ; define word data 8192,0,0,132
pff_inline_cmp10    puls      x         ; restore X from the hardware stack
                    lbsr      _dcmpr    ; long branch to subroutine to _dcmpr
                    bge       scale_down_by_ten ; branch if greater or equal to scale_down_by_ten
                    bra       start_output_buffer ; branch unconditionally to start_output_buffer
zero_value_frame    leas      -32,x     ; adjust S using -32,x
start_output_buffer leax      pff_buffer,y ; compute effective address into X from pff_buffer,y
                    stx       30,s      ; store X to stack-relative value 30,s
                    ldd       #'0
                    ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       26,s      ; load D from stack-relative value 26,s
                    beq       precision_clamp ; branch if equal/zero to precision_clamp
                    ldd       #'-
                    ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
precision_clamp     ldd       38,s      ; load D from stack-relative value 38,s
                    cmpd      #$0010    ; compare D against immediate value $0010
                    ble       precision_nonnegative ; branch if less or equal to precision_nonnegative
                    ldd       #$0010    ; load D from immediate value $0010
                    bra       save_clamped_precision ; branch unconditionally to save_clamped_precision
precision_nonnegative ldd       38,s      ; load D from stack-relative value 38,s
                    bge       precision_ready ; branch if greater or equal to precision_ready
                    clra                ; clear A
                    clrb                ; clear B
save_clamped_precision std       38,s      ; store D to stack-relative value 38,s
precision_ready     clra                ; clear A
                    clrb                ; clear B
                    std       10,s      ; store D to stack-relative value 10,s
                    ldd       40,s      ; load D from stack-relative value 40,s
                    bne       explicit_exponent_mode ; branch if not equal to explicit_exponent_mode
                    ldd       #1        ; load D from immediate value 1
                    std       10,s      ; store D to stack-relative value 10,s
                    ldd       18,s      ; load D from stack-relative value 18,s
                    cmpd      #5        ; compare D against immediate value 5
                    lbgt      use_exponent_notation ; long branch if greater than to use_exponent_notation
                    leax      32,s      ; compute effective address into X from 32,s
                    bra       setup_fixed_notation ; branch unconditionally to setup_fixed_notation
explicit_exponent_mode ldd       40,s      ; load D from stack-relative value 40,s
                    bge       fixed_format_setup ; branch if greater or equal to fixed_format_setup
                    bra       setup_exponent_notation ; branch unconditionally to setup_exponent_notation
force_exponent_notation leas      -32,x     ; adjust S using -32,x
setup_exponent_notation ldd       #1        ; load D from immediate value 1
                    std       16,s      ; store D to stack-relative value 16,s
                    ldd       #1        ; load D from immediate value 1
                    std       12,s      ; store D to stack-relative value 12,s
                    leax      ,s        ; compute effective address into X from ,s
                    lbsr      _dstack   ; long branch to subroutine to _dstack
                    bsr       pff_inline_zero ; branch to subroutine to pff_inline_zero
                    fdb       0,0,0,0   ; define word data 0,0,0,0
pff_inline_zero     puls      x         ; restore X from the hardware stack
                    lbsr      _dcmpr    ; long branch to subroutine to _dcmpr
                    bne       digits_ready ; branch if not equal to digits_ready
                    ldd       #1        ; load D from immediate value 1
                    std       18,s      ; store D to stack-relative value 18,s
                    bra       digits_ready ; branch unconditionally to digits_ready
setup_fixed_notation leas      -32,x     ; adjust S using -32,x
fixed_format_setup  clra                ; clear A
                    clrb                ; clear B
                    std       16,s      ; store D to stack-relative value 16,s
                    ldd       18,s      ; load D from stack-relative value 18,s
                    std       12,s      ; store D to stack-relative value 12,s
                    bge       precision_sum_positive ; branch if greater or equal to precision_sum_positive
                    ldd       12,s      ; load D from stack-relative value 12,s
                    addd      38,s      ; add stack-relative value 38,s into D
                    blt       clamp_left_padding ; branch if less than to clamp_left_padding
                    ldd       38,s      ; load D from stack-relative value 38,s
                    addd      12,s      ; add stack-relative value 12,s into D
                    std       38,s      ; store D to stack-relative value 38,s
                    bra       digits_ready ; branch unconditionally to digits_ready
clamp_left_padding  ldd       38,s      ; load D from stack-relative value 38,s
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    std       12,s      ; store D to stack-relative value 12,s
                    clra                ; clear A
                    clrb                ; clear B
                    std       38,s      ; store D to stack-relative value 38,s
                    clra                ; clear A
                    clrb                ; clear B
                    std       8,s       ; store D to stack-relative value 8,s
                    bra       digits_ready ; branch unconditionally to digits_ready
precision_sum_positive ldd       12,s      ; load D from stack-relative value 12,s
                    addd      38,s      ; add stack-relative value 38,s into D
                    cmpd      #$0019    ; compare D against immediate value $0019
                    ble       digits_ready ; branch if less or equal to digits_ready
use_exponent_notation leax      32,s      ; compute effective address into X from 32,s
                    lbra      force_exponent_notation ; long branch unconditionally to force_exponent_notation
digits_ready        leax      pff_power_table,y ; compute effective address into X from pff_power_table,y
                    stx       14,s      ; store X to stack-relative value 14,s
                    leax      ,s        ; compute effective address into X from ,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      pff_normalize ; long branch to subroutine to pff_normalize
                    leas      2,s       ; adjust S using 2,s
                    ldd       12,s      ; load D from stack-relative value 12,s
                    bge       no_leading_fraction_zeros ; branch if greater or equal to no_leading_fraction_zeros
                    ldd       #'0
                    ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       30,s      ; load D from stack-relative value 30,s
                    std       28,s      ; store D to stack-relative value 28,s
                    ldd       #'.
                    bra       emit_decimal_prefix ; branch unconditionally to emit_decimal_prefix
emit_leading_zero   ldd       #'0
emit_decimal_prefix ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       12,s      ; load D from stack-relative value 12,s
                    addd      #1        ; add immediate value 1 into D
                    std       12,s      ; store D to stack-relative value 12,s
                    subd      #1        ; subtract immediate value 1 from D
                    bne       emit_leading_zero ; branch if not equal to emit_leading_zero
                    bra       finish_requested_digits ; branch unconditionally to finish_requested_digits
no_leading_fraction_zeros ldd       12,s      ; load D from stack-relative value 12,s
                    bne       emit_integral_digits ; branch if not equal to emit_integral_digits
                    ldd       #'0
                    bra       store_integral_digit ; branch unconditionally to store_integral_digit
emit_integral_digit leax      14,s      ; compute effective address into X from 14,s
                    pshs      x         ; save X on the hardware stack
                    leax      2,s       ; compute effective address into X from 2,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      pff_emit_bcd_digit ; long branch to subroutine to pff_emit_bcd_digit
                    leas      4,s       ; adjust S using 4,s
store_integral_digit ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
emit_integral_digits ldd       12,s      ; load D from stack-relative value 12,s
                    addd      #-1       ; add immediate value -1 into D
                    std       12,s      ; store D to stack-relative value 12,s
                    subd      #-1       ; subtract immediate value -1 from D
                    bne       emit_integral_digit ; branch if not equal to emit_integral_digit
                    ldd       30,s      ; load D from stack-relative value 30,s
                    std       28,s      ; store D to stack-relative value 28,s
                    ldd       38,s      ; load D from stack-relative value 38,s
                    beq       finish_requested_digits ; branch if equal/zero to finish_requested_digits
                    ldd       #'.
                    bra       store_fraction_digit ; branch unconditionally to store_fraction_digit
emit_fraction_digit leax      14,s      ; compute effective address into X from 14,s
                    pshs      x         ; save X on the hardware stack
                    leax      2,s       ; compute effective address into X from 2,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      pff_emit_bcd_digit ; long branch to subroutine to pff_emit_bcd_digit
                    leas      4,s       ; adjust S using 4,s
store_fraction_digit ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
finish_requested_digits ldd       38,s      ; load D from stack-relative value 38,s
                    addd      #-1       ; add immediate value -1 into D
                    std       38,s      ; store D to stack-relative value 38,s
                    subd      #-1       ; subtract immediate value -1 from D
                    bgt       emit_fraction_digit ; branch if greater than to emit_fraction_digit
                    ldd       8,s       ; load D from stack-relative value 8,s
                    lbeq      consider_exponent_suffix ; long branch if equal/zero to consider_exponent_suffix
                    leas      -4,s      ; adjust S using -4,s
                    ldd       34,s      ; load D from stack-relative value 34,s
                    std       ,s        ; store D to memory pointed to by S
                    tfr       d,x       ; transfer D,X
                    pshs      x         ; save X on the hardware stack
                    leax      20,s      ; compute effective address into X from 20,s
                    pshs      x         ; save X on the hardware stack
                    leax      8,s       ; compute effective address into X from 8,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      pff_emit_bcd_digit ; long branch to subroutine to pff_emit_bcd_digit
                    leas      4,s       ; adjust S using 4,s
                    stb       [,s++]    ; store B to indirect address [,s++]
                    ldd       #5        ; load D from immediate value 5
                    std       2,s       ; store D to stack-relative value 2,s
round_carry_loop    ldb       [,s]      ; load B from indirect address [,s]
                    sex                 ; sign-extend B into A to form D
                    tfr       d,x       ; transfer D,X
                    bra       test_round_position ; branch unconditionally to test_round_position
back_over_decimal_point ldd       ,s        ; load D from memory pointed to by S
                    addd      #-1       ; add immediate value -1 into D
                    std       ,s        ; store D to memory pointed to by S
                    bra       add_round_carry ; branch unconditionally to add_round_carry
back_over_minus_sign ldd       #'-
                    ldx       ,s        ; load X from memory pointed to by S
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       #'0
                    stb       [,s]      ; store B to indirect address [,s]
                    bra       add_round_carry ; branch unconditionally to add_round_carry
test_round_position cmpx      #'.
                    beq       back_over_decimal_point ; branch if equal/zero to back_over_decimal_point
                    cmpx      #'-
                    beq       back_over_minus_sign ; branch if equal/zero to back_over_minus_sign
add_round_carry     ldb       [,s]      ; load B from indirect address [,s]
                    sex                 ; sign-extend B into A to form D
                    addd      2,s       ; add stack-relative value 2,s into D
                    stb       [,s]      ; store B to indirect address [,s]
                    cmpd      #'9
                    ble       no_round_carry ; branch if less or equal to no_round_carry
                    ldd       #1        ; load D from immediate value 1
                    bra       save_round_carry ; branch unconditionally to save_round_carry
no_round_carry      clra                ; clear A
                    clrb                ; clear B
save_round_carry    std       2,s       ; store D to stack-relative value 2,s
                    beq       rounding_done ; branch if equal/zero to rounding_done
                    ldb       [,s]      ; load B from indirect address [,s]
                    sex                 ; sign-extend B into A to form D
                    subd      #10       ; subtract immediate value 10 from D
                    stb       [,s]      ; store B to indirect address [,s]
                    bra       propagate_round_carry ; branch unconditionally to propagate_round_carry
propagate_round_carry ldd       ,s        ; load D from memory pointed to by S
                    addd      #-1       ; add immediate value -1 into D
                    std       ,s        ; store D to memory pointed to by S
                    lbra      round_carry_loop ; long branch unconditionally to round_carry_loop
rounding_done       leas      4,s       ; adjust S using 4,s
consider_exponent_suffix ldd       16,s      ; load D from stack-relative value 16,s
                    lbeq      maybe_trim_trailing_zeroes ; long branch if equal/zero to maybe_trim_trailing_zeroes
                    ldd       42,s      ; load D from stack-relative value 42,s
                    beq       use_lower_exponent_marker ; branch if equal/zero to use_lower_exponent_marker
                    ldd       #'E
                    bra       store_exponent_marker ; branch unconditionally to store_exponent_marker
use_lower_exponent_marker ldd       #'e
store_exponent_marker ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       18,s      ; load D from stack-relative value 18,s
                    addd      #-1       ; add immediate value -1 into D
                    std       18,s      ; store D to stack-relative value 18,s
                    bge       positive_exponent_suffix ; branch if greater or equal to positive_exponent_suffix
                    ldd       18,s      ; load D from stack-relative value 18,s
                    nega                ; negate A
                    negb                ; negate B
                    sbca      #0        ; subtract immediate value 0 from A
                    std       18,s      ; store D to stack-relative value 18,s
                    ldd       #$002d    ; load D from immediate value $002d
                    bra       store_exponent_sign2 ; branch unconditionally to store_exponent_sign
positive_exponent_suffix ldd       #'+
store_exponent_sign2 ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       18,s      ; load D from stack-relative value 18,s
                    pshs      d         ; save D on the hardware stack
                    ldd       #10       ; load D from immediate value 10
                    lbsr      ccdiv     ; long branch to subroutine to ccdiv
                    addd      #'0
                    ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    ldd       18,s      ; load D from stack-relative value 18,s
                    pshs      d         ; save D on the hardware stack
                    ldd       #10       ; load D from immediate value 10
                    lbsr      ccmod     ; long branch to subroutine to ccmod
                    addd      #'0
                    ldx       30,s      ; load X from stack-relative value 30,s
                    leax      1,x       ; compute effective address into X from 1,x
                    stx       30,s      ; store X to stack-relative value 30,s
                    stb       -1,x      ; store B to indexed value -1,x
                    bra       terminate_buffer ; branch unconditionally to terminate_buffer
maybe_trim_trailing_zeroes ldd       10,s      ; load D from stack-relative value 10,s
                    beq       terminate_buffer ; branch if equal/zero to terminate_buffer
                    ldd       30,s      ; load D from stack-relative value 30,s
                    cmpd      28,s      ; compare D against stack-relative value 28,s
                    beq       terminate_buffer ; branch if equal/zero to terminate_buffer
                    bra       step_trim_pointer ; branch unconditionally to step_trim_pointer
trim_zero_scan      ldb       [30,s]    ; load B from indirect address [30,s]
                    cmpb      #'0
                    beq       step_trim_pointer ; branch if equal/zero to step_trim_pointer
                    ldd       30,s      ; load D from stack-relative value 30,s
                    addd      #1        ; add immediate value 1 into D
                    std       30,s      ; store D to stack-relative value 30,s
                    bra       terminate_buffer ; branch unconditionally to terminate_buffer
step_trim_pointer   ldd       30,s      ; load D from stack-relative value 30,s
                    addd      #-1       ; add immediate value -1 into D
                    std       30,s      ; store D to stack-relative value 30,s
                    cmpd      28,s      ; compare D against stack-relative value 28,s
                    bne       trim_zero_scan ; branch if not equal to trim_zero_scan
terminate_buffer    clra                ; clear A
                    clrb                ; clear B
                    stb       [30,s]    ; store B to indirect address [30,s]
                    leax      pff_buffer_end,y ; compute effective address into X from pff_buffer_end,y
                    cmpx      30,s      ; compare X against stack-relative value 30,s
                    bhi       buffer_size_ok ; branch if higher to buffer_size_ok
                    leax      pff_overflow_msg,pcr ; compute effective address into X from pff_overflow_msg,pcr
                    pshs      x         ; save X on the hardware stack
                    leax      __iob+26,y ; compute effective address into X from __iob+26,y
                    pshs      x         ; save X on the hardware stack
                    lbsr      _fprintf  ; long branch to subroutine to _fprintf
                    leas      4,s       ; adjust S using 4,s
                    ldd       #1        ; load D from immediate value 1
                    pshs      d         ; save D on the hardware stack
                    lbsr      _exit     ; long branch to subroutine to _exit
                    leas      2,s       ; adjust S using 2,s
buffer_size_ok      ldb       pff_buffer,y ; load B from indexed value pff_buffer,y
                    cmpb      #'0
                    bne       use_full_buffer ; branch if not equal to use_full_buffer
                    leax      pff_buffer_tail,y ; compute effective address into X from pff_buffer_tail,y
                    bra       return_buffer_pointer ; branch unconditionally to return_buffer_pointer
use_full_buffer     leax      pff_buffer,y ; compute effective address into X from pff_buffer,y
return_buffer_pointer tfr       x,d       ; transfer X,D
                    leas      32,s      ; adjust S using 32,s
                    puls      u,pc      ; restore registers and return
pff_normalize
stk_pffnorm_ret     equ       0         ; caller return address
stk_pffnorm_valuep  equ       2         ; pointer to packed double being normalized
                    pshs      u         ; preserve U while normalizing packed value
                    ldx       stk_pffnorm_valuep+2,s ; load value pointer after saved U
                    lda       7,x       ; load A from indexed value 7,x
                    suba      #$80      ; subtract immediate value $80 from A
                    bcs       save_high_digit ; branch if carry is set to save_high_digit
                    ldb       ,x        ; load B from memory pointed to by X
                    orb       #$80      ; OR B with immediate value $80
                    stb       ,x        ; store B to memory pointed to by X
                    clr       7,x       ; clear indexed value 7,x
                    suba      #4        ; subtract immediate value 4 from A
                    beq       find_high_digit ; branch if equal/zero to find_high_digit
normalize_shift_loop lsr       ,x        ; logical shift memory pointed to by X right by one bit
                    ror       1,x       ; rotate indexed value 1,x right through carry
                    ror       2,x       ; rotate indexed value 2,x right through carry
                    ror       3,x       ; rotate indexed value 3,x right through carry
                    ror       4,x       ; rotate indexed value 4,x right through carry
                    ror       5,x       ; rotate indexed value 5,x right through carry
                    ror       6,x       ; rotate indexed value 6,x right through carry
                    ror       7,x       ; rotate indexed value 7,x right through carry
                    inca                ; increment A
                    bne       normalize_shift_loop ; branch if not equal to normalize_shift_loop
find_high_digit     lda       #8        ; load A from immediate value 8
scan_high_digit     deca                ; decrement A
                    bmi       save_high_digit ; branch if minus to save_high_digit
                    ldb       a,x       ; load B from indexed value a,x
                    beq       scan_high_digit ; branch if equal/zero to scan_high_digit
save_high_digit     sta       pff_high_digit_idx ; store A to pff_high_digit_idx
                    clra                ; clear A
                    clrb                ; clear B
                    puls      u,pc      ; restore registers and return
pff_emit_bcd_digit
stk_pffbcd_ret      equ       0         ; caller return address
stk_pffbcd_digitp   equ       2         ; pointer to packed decimal digit buffer
                    ldx       stk_pffbcd_digitp,s ; load packed decimal digit pointer
                    clra                ; clear A
                    ldb       ,x        ; load B from memory pointed to by X
                    lsrb                ; logical shift B right by one bit
                    lsrb                ; logical shift B right by one bit
                    lsrb                ; logical shift B right by one bit
                    lsrb                ; logical shift B right by one bit
                    addb      #'0
                    pshs      d,u       ; save D,U on the hardware stack
                    ldb       ,x        ; load B from memory pointed to by X
                    andb      #$0f      ; AND B with immediate value $0f
                    stb       ,x        ; store B to memory pointed to by X
                    bsr       pff_shift_digits_left ; branch to subroutine to pff_shift_digits_left
                    lda       pff_high_digit_idx ; load A from pff_high_digit_idx
                    bmi       bcd_emit_done ; branch if minus to bcd_emit_done
scan_nonzero_nibble ldb       a,x       ; load B from indexed value a,x
                    bne       high_nibble_found ; branch if not equal to high_nibble_found
                    deca                ; decrement A
                    bpl       scan_nonzero_nibble ; branch if plus to scan_nonzero_nibble
high_nibble_found   sta       pff_high_digit_idx ; store A to pff_high_digit_idx
                    bmi       bcd_emit_done ; branch if minus to bcd_emit_done
                    leas      -8,s      ; adjust S using -8,s
copy_digits_for_double ldb       a,x       ; load B from indexed value a,x
                    stb       a,s       ; store B to stack-relative value a,s
                    deca                ; decrement A
                    bpl       copy_digits_for_double ; branch if plus to copy_digits_for_double
                    bsr       pff_shift_digits_left ; branch to subroutine to pff_shift_digits_left
                    bsr       pff_shift_digits_left ; branch to subroutine to pff_shift_digits_left
                    lda       pff_high_digit_idx ; load A from pff_high_digit_idx
                    clrb                ; clear B
add_shifted_digits  ldb       a,x       ; load B from indexed value a,x
                    adcb      a,s       ; add stack-relative value a,s into B
                    stb       a,x       ; store B to indexed value a,x
                    deca                ; decrement A
                    bpl       add_shifted_digits ; branch if plus to add_shifted_digits
                    leas      8,s       ; adjust S using 8,s
bcd_emit_done       puls      d,u,pc    ; restore registers and return
pff_shift_digits_left
stk_pffshift_ret    equ       0         ; caller return address
                    lda       pff_high_digit_idx ; load active highest digit index
                    bmi       digit_shift_done ; branch if minus to digit_shift_done
                    asl       a,x       ; shift indexed value a,x left by one bit
                    bra       continue_digit_shift ; branch unconditionally to continue_digit_shift
shift_digit_carry   rol       a,x       ; rotate indexed value a,x left through carry
continue_digit_shift deca                ; decrement A
                    bpl       shift_digit_carry ; branch if plus to shift_digit_carry
digit_shift_done    rts                 ; return to caller
pff_overflow_msg    fcc       "_pffinit ; buffer overflow"
                    fcb       $0d,$00   ; define byte data $0d,$00

                    endsect   ;         end current section
