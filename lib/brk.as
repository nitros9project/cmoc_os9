* Adapted from cmoc_os9/lib/todo/brk.a for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_brk                EXPORT              ; export this symbol
_unbrk              EXPORT              ; export this symbol

_os9err             EXTERNAL            ; import external symbol
__memend            EXTERNAL            ; import external symbol
_spare              EXTERNAL            ; import external symbol

*   brk(pnt)  set memory size to pnt, allocating or deallocating
_brk
_unbrk
                    ldd       2,s       ; get new end / decrease amount
                    pshs      y         ; save Y on the hardware stack
                    os9       F_Mem     ; set new end
                    bcc       BranchTarget_01 ; branch if carry is clear to BranchTarget_01
                    puls      y         ; restore Y from the hardware stack
                    lbra      _os9err   ; long branch unconditionally to _os9err

BranchTarget_01     tfr       y,d       ; copy new top
                    puls      y         ; recover base
                    std       __memend,y ; store D to indexed value __memend,y
                    subd      2,s       ; subtract what we asked for
                    std       _spare,y  ; save the difference
                    rts                 ; return to caller

                    endsect             ; end current section
