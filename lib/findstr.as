* Live cmoc_os9 ABI assembly implementation of findstr()/findnstr().

                    section   code      ; begin code section

_findstr            EXPORT    ;         export this symbol
_findnstr           EXPORT    ;         export this symbol

* int match_at(const char *hay, const char *needle)
* X = hay, Y = needle
* returns D = 1 on match, 0 on mismatch
match_at
stk_match_ret       equ       0         ; internal return address
                    pshs      x,y,u     ; preserve caller scan registers
                    tfr       x,u       ; scan haystack copy without disturbing caller X
Loop_01             ldb       ,y+       ; fetch next needle byte
                    beq       BranchTarget_01 ; whole needle matched when its terminator is reached
                    cmpb      ,u+       ; compare against corresponding haystack byte
                    beq       Loop_01   ; keep matching while bytes agree
                    clra                ; return false high byte
                    clrb                ; return false low byte
                    puls      x,y,u,pc  ; restore registers and return mismatch
BranchTarget_01     ldd       #1        ; return true for complete needle match
                    puls      x,y,u,pc  ; restore registers and return match

_findstr:
stk_findstr_saved_y equ       0         ; saved Y after entry prologue
stk_findstr_saved_u equ       2         ; saved U after entry prologue
stk_findstr_ret     equ       4         ; caller return address after entry prologue
stk_findstr_hay     equ       6         ; haystack string pointer after entry prologue
stk_findstr_needle  equ       8         ; needle string pointer after entry prologue
                    pshs      y,u       ; preserve registers used for scans
                    ldu       stk_findstr_needle,s ; inspect needle pointer
                    ldb       ,u        ; test first needle byte
                    bne       BranchTarget_02 ; search when needle is not empty
                    ldd       stk_findstr_hay,s ; empty needle matches at haystack start
                    puls      y,u,pc    ; restore registers and return haystack pointer
BranchTarget_02     ldx       stk_findstr_hay,s ; start scanning at haystack beginning
Loop_02             ldb       ,x        ; test current haystack byte
                    beq       ReturnZero_01 ; no match is possible after haystack terminator
                    ldy       stk_findstr_needle,s ; reload needle pointer for this candidate
                    bsr       match_at  ; test whether needle matches at current haystack byte
                    bne       BranchTarget_03 ; return current position when match_at succeeded
                    leax      1,x       ; advance to next haystack byte
                    bra       Loop_02   ; continue scanning for a match
BranchTarget_03     tfr       x,d       ; return matching haystack pointer
                    puls      y,u,pc    ; restore registers and return match pointer
ReturnZero_01       clra                ; return null high byte
                    clrb                ; return null low byte
                    puls      y,u,pc    ; restore registers and return null

_findnstr:
stk_findnstr_saved_y equ       0         ; saved Y after entry prologue
stk_findnstr_saved_u equ       2         ; saved U after entry prologue
stk_findnstr_ret    equ       4         ; caller return address after entry prologue
stk_findnstr_hay    equ       6         ; haystack string pointer after entry prologue
stk_findnstr_needle equ       8         ; needle string pointer after entry prologue
stk_findnstr_count  equ       10        ; maximum haystack bytes to inspect after entry prologue
                    pshs      y,u       ; preserve registers used for scans
                    ldu       stk_findnstr_needle,s ; inspect needle pointer
                    ldb       ,u        ; test first needle byte
                    bne       BranchTarget_04 ; bounded search when needle is not empty
                    ldd       stk_findnstr_hay,s ; empty needle matches at haystack start
                    puls      y,u,pc    ; restore registers and return haystack pointer
BranchTarget_04     ldx       stk_findnstr_hay,s ; start scanning at haystack beginning
                    ldy       stk_findnstr_count,s ; load remaining candidate count
                    beq       ReturnZero_02 ; zero-length search cannot match non-empty needle
Loop_03             ldb       ,x        ; test current haystack byte
                    beq       ReturnZero_02 ; stop at haystack terminator
                    pshs      x,y       ; preserve scan pointer and remaining count around match_at
                    ldy       stk_findnstr_needle+4,s ; pushed X/Y shift needle pointer by four bytes
                    bsr       match_at  ; test whether needle matches at current haystack byte
                    puls      x,y       ; restore scan pointer and remaining count
                    bne       BranchTarget_05 ; return current position when match_at succeeded
                    leax      1,x       ; advance to next haystack byte
                    leay      -1,y      ; consume one byte of the search limit
                    bne       Loop_03   ; continue while count remains
                    bra       ReturnZero_02 ; limit exhausted without a match
BranchTarget_05     tfr       x,d       ; return matching haystack pointer
                    puls      y,u,pc    ; restore registers and return match pointer
ReturnZero_02       clra                ; return null high byte
                    clrb                ; return null low byte
                    puls      y,u,pc    ; restore registers and return null

                    endsect   ;         end current section
