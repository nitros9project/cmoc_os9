* Assembly directory seek helpers matching the CMOC long-return ABI.

                    section   code

_seekdir            EXPORT    ;         export this symbol
_telldir            EXPORT    ;         export this symbol

_lseek              EXTERNAL  ;         import C lseek wrapper
copyDWordFromXToD   EXTERNAL  ;         import hidden-long return copier
push4ByteStruct     EXTERNAL  ;         import long-by-value stack helper

SEEK_SET            equ       0         ; lseek origin: absolute file position
SEEK_CUR            equ       1         ; lseek origin: current file position

_seekdir:
stk_seekdir_saved_u equ       0         ; saved U after entry prologue
stk_seekdir_ret     equ       2         ; caller return address after entry prologue
stk_seekdir_dirp    equ       4         ; DIR * argument after entry prologue
stk_seekdir_loc     equ       6         ; long location argument after entry prologue
stk_seekdir_result  equ       -4        ; scratch hidden long return slot below U frame
                    pshs      u         ; preserve frame register
                    leau      ,s        ; anchor a simple U-based frame
                    leas      stk_seekdir_result,s ; reserve scratch long return slot for _lseek
                    clra                ; high byte of SEEK_SET selector
                    clrb                ; low byte of SEEK_SET selector
                    pshs      d         ; argument 3 of _lseek(): whence
                    leax      stk_seekdir_loc,u ; address of loc argument
                    leas      -4,s      ; reserve by-value long argument
                    lbsr      push4ByteStruct ; copy loc argument into reserved stack slot
                    ldd       [stk_seekdir_dirp,u] ; load dirp->dd_fd
                    pshs      d         ; argument 1 of _lseek(): path
                    leax      stk_seekdir_result,u ; hidden long return slot for _lseek()
                    pshs      x         ; pass hidden return pointer
                    lbsr      _lseek    ; reposition directory path
                    leas      10,s      ; discard hidden arg + path + long + whence
                    leas      ,u        ; release local scratch
                    puls      u,pc

_telldir:
stk_telldir_saved_u equ       0         ; saved U after entry prologue
stk_telldir_ret     equ       2         ; caller return address after entry prologue
stk_telldir_resultp equ       4         ; hidden long return pointer
stk_telldir_dirp    equ       6         ; DIR * argument after hidden return pointer
stk_telldir_result  equ       -4        ; scratch hidden long return slot below U frame
                    pshs      u         ; preserve frame register
                    leau      ,s        ; anchor a simple U-based frame
                    leas      stk_telldir_result,s ; reserve scratch long return slot for _lseek
                    clra                ; high byte of SEEK_CUR selector
                    ldb       #SEEK_CUR ; low byte of SEEK_CUR selector
                    pshs      d         ; argument 3 of _lseek(): whence
                    leax      seek_zero_offset,pcr ; address of 32-bit zero offset
                    leas      -4,s      ; reserve by-value long zero argument
                    lbsr      push4ByteStruct ; copy zero offset into reserved stack slot
                    ldd       [stk_telldir_dirp,u] ; load dirp->dd_fd
                    pshs      d         ; argument 1 of _lseek(): path
                    leax      stk_telldir_result,u ; hidden long return slot for _lseek()
                    pshs      x         ; pass hidden return pointer
                    lbsr      _lseek    ; query current directory path position
                    leas      10,s      ; discard hidden arg + path + long + whence
                    leax      stk_telldir_result,u ; address of scratch long result
                    ldd       stk_telldir_resultp,u ; hidden return pointer for telldir()
                    lbsr      copyDWordFromXToD ; copy _lseek result to caller's return slot
                    leas      ,u        ; release local scratch
                    puls      u,pc

seek_zero_offset    fdb       $0000,$0000 ; constant 32-bit zero seek offset

                    endsect
