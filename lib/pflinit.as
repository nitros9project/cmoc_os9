*      stack u, ret, c, long

                    section   bss       ; begin bss section
buf1                rmb       20        ; reserve 20 bytes
                    endsect   ;         end current section


                    section   rodata    ; begin rodata section
ldectbl             fdb       $3b9a,$ca00 ; define word data $3b9a,$ca00
                    fdb       $05f5,$e100 ; define word data $05f5,$e100
                    fdb       $0098,$9680 ; define word data $0098,$9680
                    fdb       $000f,$4240 ; define word data $000f,$4240
                    fdb       $0001,$86a0 ; define word data $0001,$86a0
                    fdb       $0000,10000 ; define word data $0000,10000
                    fdb       $0000,1000 ; define word data $0000,1000
                    fdb       $0000,100 ; define word data $0000,100
                    fdb       $0000,10  ; define word data $0000,10
                    endsect   ;         end current section

                    section   code      ; begin code section

_pflinit            EXPORT    ;         export long-format initialization hook
_pflinit:
stk_pflinit_ret     equ       0         ; caller return address
                    rts                 ; no initialization required for integer long formatting


_pflong             EXPORT    ;         export printf long-format helper
_pflong:
stk_pflong_ret      equ       0         ; caller return address
stk_pflong_spec     equ       2         ; format specifier argument
stk_pflong_spec_byte equ       3         ; low byte used as the conversion character
stk_pflong_value    equ       4         ; 32-bit long value argument
                    pshs      u         ; preserve caller's U register
                    leau      buf1,y    ; point U at the reusable conversion buffer
                    pshs      u         ; stage buffer pointer as the function result
                    ldb       stk_pflong_spec_byte+4,s ; load conversion character after two pushed U values
switch              cmpb      #'d       ; select signed decimal conversion
                    beq       case_d    ; branch if equal/zero to case_d
                    cmpb      #'u       ; select unsigned decimal conversion
                    lbeq      case_u    ; long branch if equal/zero to case_u
                    cmpb      #'o       ; select octal conversion
                    beq       case_o    ; branch if equal/zero to case_o
                    cmpb      #'x       ; select lowercase hexadecimal conversion
                    beq       case_x    ; branch if equal/zero to case_x
                    cmpb      #'X       ; select uppercase hexadecimal conversion
                    beq       case_x    ; branch if equal/zero to case_x
                    lda       #'l       ; unsupported specifier keeps the leading 'l'
                    std       ,u++      ; emit "l<specifier>" into the buffer
pflxit              clr       ,u        ; terminate the generated string
                    puls      d,u,pc    ; return staged buffer pointer in D and restore U
                    pag
case_o              leax      stk_pflong_value+4,s ; point X at mutable long value
case_o1             ldb       3,x       ; take the low octal digit from the value
                    andb      #$07      ; isolate three octal bits
                    addb      #'0       ; convert digit to ASCII
                    stb       ,u+       ; append octal digit and advance output pointer
                    ldb       #3        ; shift the value by one octal digit
                    bsr       fshifts   ; shift the 32-bit value right by B bits
                    bne       case_o1   ; continue until the shifted value becomes zero
                    bra       case_x3   ; branch unconditionally to case_x3


fshifts             lsr       0,x       ; logical shift indexed value 0,x right by one bit
                    ror       1,x       ; rotate indexed value 1,x right through carry
                    ror       2,x       ; rotate indexed value 2,x right through carry
                    ror       3,x       ; rotate indexed value 3,x right through carry
                    decb                ; decrement B
                    bne       fshifts   ; branch if not equal to fshifts
                    lda       0,x       ; load A from indexed value 0,x
                    ora       1,x       ; OR A with indexed value 1,x
                    ora       2,x       ; OR A with indexed value 2,x
                    ora       3,x       ; OR A with indexed value 3,x
                    rts                 ; return with Z reflecting whether the value is now zero


case_x              andb      #$20      ; keep ASCII lowercase bit for x versus X
                    pshs      b         ; save case-adjustment bit
                    leax      stk_pflong_value+5,s ; point X at long value after extra case byte
case_x1             ldb       3,x       ; fetch low hexadecimal nibble
                    andb      #$0f      ; isolate one hex digit
                    pshs      b         ; save raw digit while choosing ASCII base
                    lda       #'0       ; assume a numeric digit
                    cmpb      #9        ; compare B against immediate value 9
                    ble       case_x2   ; branch if less or equal to case_x2
                    lda       #'A-10    ; alphabetic digits start at A/a after adjustment
                    adda      1,s       ; apply lowercase bit when needed
case_x2             adda      ,s+       ; add digit value and discard raw digit
                    sta       ,u+       ; append hex digit and advance output pointer
                    ldb       #4        ; shift the value by one hex digit
                    bsr       fshifts   ; shift the 32-bit value right by B bits
                    bne       case_x1   ; continue until the shifted value becomes zero
                    leas      1,s       ; discard case-adjustment byte
case_x3             ldx       ,s        ; load start of the generated digit string
                    clr       ,u        ; terminate the reversed digit string
frevers             EXTERNAL  ;         import external symbol
                    lbsr      frevers   ; reverse emitted digits into display order
                    puls      d,u,pc    ; return buffer pointer and restore U

case_d              ldb       stk_pflong_value+4,s ; inspect high byte for signed decimal
                    bpl       case_d4   ; non-negative values use unsigned decimal path
                    ldd       #0        ; start two's-complement negation of low word
                    subd      stk_pflong_value+6,s ; subtract low word from zero
                    std       stk_pflong_value+6,s ; store negated low word
                    ldd       #0        ; continue negation through high word
                    sbcb      stk_pflong_value+5,s ; subtract high-word low byte with borrow
                    sbca      stk_pflong_value+4,s ; subtract high-word high byte with borrow
                    std       stk_pflong_value+4,s ; store negated high word
                    cmpd      #$8000    ; compare D against immediate value $8000
                    bne       case_d3   ; branch if not equal to case_d3
                    ldd       2,x       ; load D from indexed value 2,x
                    bne       case_d3   ; branch if not equal to case_d3
                    leax      >tminlong,pcr ; compute effective address into X from >tminlong,pcr
case_d2             lda       ,x+       ; load A from memory pointed to by X, then advance X
                    sta       ,u+       ; store A to memory pointed to by U, then advance U
                    bne       case_d2   ; branch if not equal to case_d2
case_d1             lbra      pflxit    ; long branch unconditionally to pflxit

case_d3             ldb       #'-       ; prefix negative decimal output
                    stb       ,u+       ; append sign and advance output pointer
case_u
case_d4             leax      ldectbl,pcr ; compute effective address into X from ldectbl,pcr
                    clra                ; clear A
                    ldb       #10       ; load B from immediate value 10
                    pshs      a         ; save A on the hardware stack
                    pshs      d         ; save D on the hardware stack
                    bra       case_d11  ; branch unconditionally to case_d11

case_d7             inc       ,s        ; increment memory pointed to by S
case_d8             ldd       13,s      ; load D from stack-relative value 13,s
                    subd      2,x       ; subtract indexed value 2,x from D
                    std       13,s      ; store D to stack-relative value 13,s
                    ldd       11,s      ; load D from stack-relative value 11,s
                    sbcb      1,x       ; subtract indexed value 1,x from B
                    sbca      0,x       ; subtract indexed value 0,x from A
                    std       11,s      ; store D to stack-relative value 11,s
                    bcc       case_d7   ; branch if carry is clear to case_d7
                    ldd       13,s      ; load D from stack-relative value 13,s
                    addd      2,x       ; add indexed value 2,x into D
                    std       13,s      ; store D to stack-relative value 13,s
                    ldd       11,s      ; load D from stack-relative value 11,s
                    adcb      1,x       ; add indexed value 1,x into B
                    adca      0,x       ; add indexed value 0,x into A
                    std       11,s      ; store D to stack-relative value 11,s
                    ldb       ,s        ; load B from memory pointed to by S
                    tst       2,s       ; test stack-relative value 2,s and update condition codes
                    bne       case_d9   ; branch if not equal to case_d9
                    tstb                ; test B and update condition codes
                    beq       case_d10  ; branch if equal/zero to case_d10
                    inc       2,s       ; increment stack-relative value 2,s
case_d9             addb      #'0
                    stb       ,u+       ; store B to memory pointed to by U, then advance U
case_d10            leax      4,x       ; compute effective address into X from 4,x
                    clr       ,s        ; clear memory pointed to by S
case_d11            dec       1,s       ; decrement stack-relative value 1,s
                    bne       case_d8   ; branch if not equal to case_d8
                    ldb       14,s      ; load B from stack-relative value 14,s
                    addb      #'0
                    stb       ,u+       ; store B to memory pointed to by U, then advance U
                    leas      3,s       ; adjust S using 3,s
                    bra       case_d1   ; branch unconditionally to case_d1


tminlong            fcc       '-2147483648' ; define string data '-2147483648'
                    fcb       0         ; define byte data 0

                    endsect   ;         end current section
