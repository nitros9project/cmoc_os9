* Adapted from cmoc_os9/lib/todo/brk.a for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_brk                EXPORT    ;         export memory-bound adjustment entry point
_unbrk              EXPORT    ;         export memory-bound shrink alias

_os9err             EXTERNAL  ;         common OS-9 error return helper
__memend            EXTERNAL  ;         current top of process memory
_spare              EXTERNAL  ;         bytes between requested break and actual top

*   brk(pnt)  set memory size to pnt, allocating or deallocating
_brk:
stk_brk_ret         equ       0         ; caller return address
stk_brk_target      equ       2         ; requested absolute memory end
                    ldd       stk_brk_target,s ; get requested absolute memory end
                    bra       BranchTarget_02 ; enter the common F$Mem adjustment path

_unbrk:
stk_unbrk_ret       equ       0         ; caller return address
stk_unbrk_decrease  equ       2         ; byte count to release from current memory end
                    ldd       __memend,y ; start from current process memory end
                    subd      _spare,y  ; convert actual memory top to the logical break
                    subd      stk_unbrk_decrease,s ; compute the new lower logical break
                    std       stk_unbrk_decrease,s ; keep absolute target for common spare calculation
BranchTarget_02
                    pshs      y         ; preserve direct-page base while F$Mem returns new top in Y
                    os9       F_Mem     ; ask OS-9 to adjust the process memory size
                    bcc       BranchTarget_01 ; continue when memory adjustment succeeded
                    puls      y         ; restore direct-page base before error return
                    lbra      _os9err   ; long branch unconditionally to _os9err

BranchTarget_01     tfr       y,d       ; copy the actual new memory top into D
                    puls      y         ; recover direct-page base
                    std       __memend,y ; store D to indexed value __memend,y
                    subd      stk_brk_target,s ; compute spare bytes above requested break
                    std       _spare,y  ; save the difference for allocator bookkeeping
                    rts                 ; return to caller

                    endsect   ;         end current section
