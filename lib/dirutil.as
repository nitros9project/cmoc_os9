* Disassembly by Os9disasm of dirutil.r

* class D external label equates

D001d               equ       $001d     ; define constant as $001d
D001e               equ       $001e     ; define constant as $001e

                    section   bss       ; begin bss section

* Uninitialized data (class B)
_B0000              rmb       4         ; reserve 4 bytes
_B0004              rmb       30        ; reserve 30 bytes
* Initialized Data (class G)

                    endsect             ; end current section

                    section   code      ; begin code section

_closedir           EXPORT              ; export this symbol
_opendir            EXPORT              ; export this symbol
_readdir            EXPORT              ; export this symbol
_seekdir            EXPORT              ; export this symbol
_telldir            EXPORT              ; export this symbol

_close              EXTERNAL            ; import external symbol
_free               EXTERNAL            ; import external symbol
_malloc             EXTERNAL            ; import external symbol
_open               EXTERNAL            ; import external symbol
_read               EXTERNAL            ; import external symbol
_strhcpy            EXTERNAL            ; import external symbol
_lseek              EXTERNAL            ; import external symbol

* DIR layout used by this file:
*   0..1  dd_fd   (path number)
*   2..33 dd_buf  (32-byte directory sector entry buffer)
*
* DIRECT/static result layout:
*   0..3  d_addr
*   4..   d_name[30]

_closedir:          ldx       2,s       ; load X from stack-relative value 2,s
                    ldd       ,x        ; load D from memory pointed to by X
                    pshs      d,x       ; save D,X on the hardware stack
                    lbsr      _close    ; long branch to subroutine to _close
                    leas      2,s       ; adjust S using 2,s
                    lbsr      _free     ; long branch to subroutine to _free
                    puls      x,pc      ; restore registers and return
_opendir:           pshs      u         ; save U on the hardware stack
                    ldd       #$0022    ; load D from immediate value $0022
                    pshs      d         ; save D on the hardware stack
                    lbsr      _malloc   ; long branch to subroutine to _malloc
                    std       ,s        ; store D to memory pointed to by S
                    beq       BranchTarget_01 ; branch if equal/zero to BranchTarget_01
                    ldx       #$0081    ; load X from immediate value $0081
                    ldd       6,s       ; load D from stack-relative value 6,s
* _open(path, mode): CMOC wrapper expects pathname first, mode second.
* Here D = pathname pointer from caller, X = mode flags for directory open.
* Push X first, then D, so _open sees:
*   2,s = pathname
*   4,s = mode
                    pshs      x         ; save X on the hardware stack
                    pshs      d         ; save D on the hardware stack
                    lbsr      _open     ; long branch to subroutine to _open
                    leas      4,s       ; adjust S using 4,s
                    std       [,s]      ; store D to indirect address [,s]
                    bge       BranchTarget_01 ; branch if greater or equal to BranchTarget_01
                    ldd       ,s        ; load D from memory pointed to by S
                    lbsr      _free     ; long branch to subroutine to _free
                    clra                ; clear A
                    clrb                ; clear B
                    std       ,s        ; store D to memory pointed to by S
BranchTarget_01     puls      d,u,pc    ; restore registers and return
_readdir:           pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    leau      2,u       ; compute effective address into U from 2,u
Loop_01             ldd       #$0020    ; load D from immediate value $0020
* _read(fd, buf, count) wants:
*   2,s = fd
*   4,s = buffer
*   6,s = count
* The path number lives at -2,u because U was advanced to dd_buf above.
                    pshs      d         ; save D on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    ldd       -2,u      ; load D from indexed value -2,u
                    pshs      d         ; save D on the hardware stack
                    lbsr      _read     ; long branch to subroutine to _read
                    leas      6,s       ; adjust S using 6,s
                    std       -2,s      ; store D to stack-relative value -2,s
                    bgt       BranchTarget_02 ; branch if greater than to BranchTarget_02
                    clra                ; clear A
                    clrb                ; clear B
                    puls      u,pc      ; restore registers and return
BranchTarget_02     ldb       ,u        ; load B from memory pointed to by U
                    beq       Loop_01   ; branch if equal/zero to Loop_01
                    leax      _B0004,y  ; compute effective address into X from _B0004,y
                    pshs      x,u       ; save X,U on the hardware stack
                    lbsr      _strhcpy  ; long branch to subroutine to _strhcpy
                    leas      4,s       ; adjust S using 4,s
                    leax      _B0000,y  ; compute effective address into X from _B0000,y
                    clra                ; clear A
                    ldb       D001d,u   ; load B from indexed value D001d,u
                    std       ,x        ; store D to memory pointed to by X
                    ldd       D001e,u   ; load D from indexed value D001e,u
                    std       2,x       ; store D to indexed value 2,x
                    tfr       x,d       ; transfer X,D
                    puls      u,pc      ; restore registers and return
_seekdir:           clra                ; clear A
                    clrb                ; clear B
* Build the CMOC long-return call frame for _lseek(fd, loc, SEEK_SET):
*   2,s = hidden return buffer
*   4,s = fd
*   6,s = loc MSW
*   8,s = loc LSW
*   10,s = whence
                    pshs      d         ; save D on the hardware stack
                    ldd       8,s       ; load D from stack-relative value 8,s
                    pshs      d         ; save D on the hardware stack
                    ldd       8,s       ; load D from stack-relative value 8,s
                    pshs      d         ; save D on the hardware stack
                    ldd       [8,s]     ; load D from indirect address [8,s]
                    pshs      d         ; save D on the hardware stack
                    leax      _B0000,y  ; compute effective address into X from _B0000,y
                    pshs      x         ; save X on the hardware stack
                    lbsr      _lseek    ; long branch to subroutine to _lseek
                    leas      10,s      ; adjust S using 10,s
                    rts                 ; return to caller
_telldir:           ldd       #1        ; load D from immediate value 1
                    pshs      d         ; save D on the hardware stack
                    clra                ; clear A
                    clrb                ; clear B
                    pshs      d         ; save D on the hardware stack
                    pshs      d         ; save D on the hardware stack
                    ldd       [10,s]    ; load D from indirect address [10,s]
                    pshs      d         ; save D on the hardware stack
                    ldx       10,s      ; load X from stack-relative value 10,s
                    pshs      x         ; save X on the hardware stack
                    lbsr      _lseek    ; long branch to subroutine to _lseek
                    leas      10,s      ; adjust S using 10,s
                    rts                 ; return to caller

                    endsect             ; end current section
