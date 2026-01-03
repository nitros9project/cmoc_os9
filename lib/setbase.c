#include <stdio.h>
#include <fcntl.h>

__norts__ asm void
setbase(FILE *stream)
{
    asm
    {
_ibrk	    EXTERNAL
_getstat	EXTERNAL

* Sets up FILE structure
            pshs  u
            ldu   2+2,s             get FILE pointer
            ldb   7,u               get low 8 bits of _flag in FILE
            bitb  #_DEVMASK         test devmask
            bne   L0029             branch if result not zero
            leas  -32,s             else reserve space on stack
            leax  ,s                and point X to space
            ldd   8,u               get _fd from FILE
            pshs  d,x               save _fd and pointer to 32 bytes
            clra                    get option section code
            clrb
            pshs  d                 save on stack
            lbsr  _getstat          call getstat to read option section
            ldb   #_SCF             assume SCF
            lda   6,s               type byte in option section
            beq   L0022
            ldb   #_RBF
L0022       leas  38,s              clean stack
            orb   7,u               OR with _flag+1,u
            stb   7,u               save it
L0029       lda   6,u               get _flag
            ora   #$80              OR with INIT_
            sta   6,u               save back
            andb  #_BIGBUF|_UNBUF
            bne   L006c             if big or unbuf
            ldd   11,u              get _bufsiz
            bne   L003c             branch if buf aleady sized
            ldd   #BUFSIZ
            std   11,u              store in _bufsiz
L003c       ldd   2,u               get _base
            bne   L0051             branch if buffer already allocated
            ldd   11,u              get buffer size
            pshs  d
            lbsr  _ibrk
            leas  2,s
            std   2,u               store in _base
            cmpd  #-1
            beq   L0055             branch if error
L0051       ldb   #_BIGBUF
            bra   L0060

L0055       leax  10,u              point X to _save if unbuffered
            stx   2,u               save in _base
            ldd   #1
            std   11,u              save buffer size
            ldb   #_UNBUF
L0060       orb   7,u               OR with _flag
            stb   7,u               save it
            ldd   2,u               get _base ptr
            addd  11,u              add _bufsiz
            std   4,u               save to _end
            std   ,u                save ptr
L006c       puls  u,pc
    }
}
