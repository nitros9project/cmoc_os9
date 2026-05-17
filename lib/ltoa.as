*
* Compact standalone assembly implementation for the live cmoc_os9 ABI.
* Writes digits into the caller's buffer in reverse order, then calls
* reverse() once at the end, which keeps the stack footprint small.
*

                    section   code      ; begin code section

_ltoa               EXPORT              ; export this symbol

_lnegx              EXTERNAL            ; import external symbol
_reverse            EXTERNAL            ; import external symbol
divDWordDWord       EXTERNAL            ; import external symbol
isDWordZero         EXTERNAL            ; import external symbol
modDWordDWord       EXTERNAL            ; import external symbol

_ltoa
                    pshs      u         ; save U on the hardware stack
                    leau      ,s        ; compute effective address into U from ,s
                    leas      -11,s     ; adjust S using -11,s

* locals relative to U:
*  -11,u  sign flag
*  -10,u  orig buffer pointer
*   -8,u  current absolute value (dword)
*   -4,u  remainder scratch (dword)

* orig = buffer;
                    ldx       8,u       ; load X from indexed value 8,u
                    stx       -10,u     ; store X to indexed value -10,u

* current = value;
                    ldd       4,u       ; load D from indexed value 4,u
                    std       -8,u      ; store D to indexed value -8,u
                    ldd       6,u       ; load D from indexed value 6,u
                    std       -6,u      ; store D to indexed value -6,u

* sign = 0;
                    clr       -11,u     ; clear indexed value -11,u

* if (value < 0) { sign = 1; current = -current; }
                    tst       4,u       ; test indexed value 4,u and update condition codes
                    bpl       L_pos     ; branch if plus to L_pos
                    inc       -11,u     ; increment indexed value -11,u
                    leax      -8,u      ; compute effective address into X from -8,u
                    lbsr      _lnegx    ; long branch to subroutine to _lnegx

L_pos
* do {
L_loop
*     rem = current % 10;
                    leax      D_ten,pcr ; compute effective address into X from D_ten,pcr
                    pshs      x         ; save X on the hardware stack
                    leax      -8,u      ; compute effective address into X from -8,u
                    pshs      x         ; save X on the hardware stack
                    leax      -4,u      ; compute effective address into X from -4,u
                    lbsr      modDWordDWord ; long branch to subroutine to modDWordDWord
                    leas      4,s       ; adjust S using 4,s

*     *buffer++ = rem + '0';
                    ldx       8,u       ; load X from indexed value 8,u
                    ldb       -1,u      ; load B from indexed value -1,u
                    addb      #$30      ; add immediate value $30 into B
                    stb       ,x+       ; store B to memory pointed to by X, then advance X
                    stx       8,u       ; store X to indexed value 8,u

*     current /= 10;
                    leax      D_ten,pcr ; compute effective address into X from D_ten,pcr
                    pshs      x         ; save X on the hardware stack
                    leax      -8,u      ; compute effective address into X from -8,u
                    pshs      x         ; save X on the hardware stack
                    leax      -8,u      ; compute effective address into X from -8,u
                    lbsr      divDWordDWord ; long branch to subroutine to divDWordDWord
                    leas      4,s       ; adjust S using 4,s

* } while (current != 0);
                    leax      -8,u      ; compute effective address into X from -8,u
                    lbsr      isDWordZero ; long branch to subroutine to isDWordZero
                    bne       L_loop    ; branch if not equal to L_loop

* if (sign) *buffer++ = '-';
                    tst       -11,u     ; test indexed value -11,u and update condition codes
                    beq       L_term    ; branch if equal/zero to L_term
                    ldx       8,u       ; load X from indexed value 8,u
                    ldb       #$2d      ; load B from immediate value $2d
                    stb       ,x+       ; store B to memory pointed to by X, then advance X
                    stx       8,u       ; store X to indexed value 8,u

L_term
* *buffer = '\0';
                    ldx       8,u       ; load X from indexed value 8,u
                    clr       ,x        ; clear memory pointed to by X

* reverse(orig);
                    ldd       -10,u     ; load D from indexed value -10,u
                    pshs      d         ; save D on the hardware stack
                    lbsr      _reverse  ; long branch to subroutine to _reverse
                    leas      2,s       ; adjust S using 2,s

* return orig;
                    ldd       -10,u     ; load D from indexed value -10,u
                    leas      ,u        ; adjust S using ,u
                    puls      u,pc      ; restore registers and return

D_ten               fcb       $00,$00,$00,$0a ; define byte data $00,$00,$00,$0a

                    endsect             ; end current section
