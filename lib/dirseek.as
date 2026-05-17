* Assembly directory seek helpers matching the CMOC long-return ABI.

                    section   code

_seekdir            EXPORT
_telldir            EXPORT

_lseek              EXTERNAL
copyDWordFromXToD   EXTERNAL
push4ByteStruct     EXTERNAL

_seekdir
                    pshs      u         ; preserve frame register
                    leau      ,s        ; anchor a simple U-based frame
                    leas      -4,s      ; reserve scratch long return slot for _lseek
                    clra                ; SEEK_SET
                    clrb
                    pshs      d         ; argument 3 of _lseek(): whence
                    leax      6,u       ; address of loc argument
                    leas      -4,s      ; pass long loc by value
                    lbsr      push4ByteStruct
                    ldd       [4,u]     ; load dirp->dd_fd
                    pshs      d         ; argument 1 of _lseek(): path
                    leax      -4,u      ; hidden long return slot for _lseek()
                    pshs      x
                    lbsr      _lseek
                    leas      10,s      ; discard hidden arg + path + long + whence
                    leas      ,u        ; release local scratch
                    puls      u,pc

_telldir
                    pshs      u         ; preserve frame register
                    leau      ,s        ; anchor a simple U-based frame
                    leas      -4,s      ; reserve scratch long return slot for _lseek
                    clra                ; SEEK_CUR
                    ldb       #1
                    pshs      d         ; argument 3 of _lseek(): whence
                    leax      L_zero,pcr ; address of 32-bit zero offset
                    leas      -4,s      ; pass long zero by value
                    lbsr      push4ByteStruct
                    ldd       [6,u]     ; load dirp->dd_fd
                    pshs      d         ; argument 1 of _lseek(): path
                    leax      -4,u      ; hidden long return slot for _lseek()
                    pshs      x
                    lbsr      _lseek
                    leas      10,s      ; discard hidden arg + path + long + whence
                    leax      -4,u      ; address of scratch long result
                    ldd       4,u       ; hidden return address for telldir()
                    lbsr      copyDWordFromXToD
                    leas      ,u        ; release local scratch
                    puls      u,pc

L_zero              fdb       $0000,$0000

                    endsect
