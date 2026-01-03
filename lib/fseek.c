#include <stdio.h>

__norts__ asm long
fseek(FILE *, long pos, int whence)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = FILE *
*	4,s = position to seek
*	6,s = from whence
		pshs    u
		ldu     2+2,s               get FILE *
		leas    -6,s                setup workspace
		lbeq    L0114               branch if FILE * is NULL
		ldd     6,u
		bitb    #_READ|_WRITE
		lbeq    L0114               branch if not R/W
		bita    #$80                _INIT set?
		bne     L0020               branch if so
		pshs    u                   else save off FILE *
_setbase	EXTERNAL
		lbsr    _setbase            and init it
		leas    2,s                 recover
		lbra    L00e5               had out
L0020 	bita     #$01               _WRITTEN
		beq     L003a               branch if not written yet
		pshs    u
_fflush	EXTERNAL
		lbsr    _fflush             flush it
		leas    2,s
		lda     6,u                 get _flag
		anda    #^$01               ^_WRITTEN
		sta     6,u                 mark _flag as clean
		ldd     2,u                 get _base
		addd    11,u                add _bufsiz
		std     4,u                 save in _end
		lbra    L00e3               ptr to end

L003a 	ldd     ,u                  get _ptr
		cmpd    4,u                 compare with _end
		lbhs    L00e5               branch if buffer is full
		leax    2,s                 else get scratch + 2
		pshs    x                   save address
		leax    14,s                from addr (requested offset)
		lbsr    _lmove              move to scratch
		ldx     16,s                type?
		beq     L0059               from beginning of file
		cmpx    #1                  from current location?
		beq     L0072               branch if so
		lbra    L00c8               else from end

L0059 	leax    2,s                 use scratch for next
		pshs    x                   to address
		ldd     2,x                 LSW
		pshs    d
		ldd     ,x                  MSW
		pshs    d
		pshs    u                   push FILE *
		lbsr    ftell               get current position into _flacc
		leas    2,s
_lsub	EXTERNAL
		lbsr    _lsub               (0,s)-(_flacc)->_flacc; x->_flacc, stack cleaned
_lmove	EXTERNAL
		lbsr    _lmove              (_flacc) to *0,s (our scratch), stack cleaned
L0072 	ldd     11,u                get _bufsiz
		lbsr    _litol              convert to long in _flacc
		ldd     2,x                 long bufsize from flacc
		pshs    d
		ldd     ,x
		pshs    d
		leax    6,s                 point to our scratch
		ldd     2,x                 stack it
		pshs    d
		ldd     ,x
		pshs    d
		leax    L011f,pcr
_lcmpr	EXTERNAL
		lbsr    _lcmpr
		bge     L0099
		leax    6,s                 point to our buffer
_lneg	EXTERNAL
		lbsr    _lneg               turn it over
		bra     L009b

L0099 	leax    6,s                 point to ur buffer
L009b 	lbsr    _lcmpr
		blt     L00bf
		ldd     4,s                 new offset
		addd    ,u                  add _ptr
		std     ,s                  save
		cmpd    2,u                  with _base
		bcs     L00bf
		ldd     ,s
		cmpd    4,u                 compare with _end
		bcc     L00bf
		ldd     ,s
		std     ,u                  save to _ptr
		ldb     7,u                 get _flag+1
		andb    #^_EOF
		stb     7,u                 save back to _flag+1
		lbra    L0119

L00bf 	ldd     16,s                type of seek...
		cmpd    #1                  from current position?
		bne     L00e1
L00c8 	leax    12,s                offset
		pshs    x
		ldd     2,x                 copy offset down
		pshs    d
		ldd     ,x
		pshs    d
		ldd     4,u
		subd    ,u                  subtract from _ptr to get bytes left in buffer
		lbsr    _litol              make long
		lbsr    _lsub
		lbsr    _lmove
L00e1 	ldd     4,u                 get _end
L00e3 	std     ,u                  save to _ptr
L00e5 	ldb     7,u                 load _flag+1
		andb    #^EOF
		stb     7,u                 save back to _flag+1
		ldd     16,s                get type
		pshs    d                   save off
		leax    14,s                get offset
		ldd     2,x
		pshs    d
		ldd     ,x
		pshs    d
		ldd     8,u                 get _fd
		pshs    d
_lseek	EXTERNAL
		lbsr    _lseek              seek
		leas    8,s
		ldd     2,x                 returned position in _flacc
		pshs    d
		ldd     ,x
		pshs    d
		leax    >L0123,pcr
		lbsr    _lcmpr
		bne     L0119
L0114 	ldd     #-1
 		bra     L011b

L0119 	clra
 		clrb
L011b 	leas    ,s
 		puls    u,pc

L011f  	fdb     $0000,$0000
L0123 	fdb     $FFFF,$FFFF
    }
}

asm void
rewind(FILE *)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = FILE *
        clra
        clrb
		tfr     d,x
		pshs    d,x
		ldd     6,s
		pshs    d,x
		lbsr    fseek
		leas    8,s
		rts
	}
}

asm long
ftell(FILE *)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = FILE *
		pshs    u
		ldu     4,s
		beq     L0143
		ldd     6,u                     get _flag in D
		andb    #_READ|_WRITE
		bne     L0150                   branch if read or write
_flacc	EXTERNAL
L0143	leax    _flacc,y
		ldd     #-1
		std     ,x
		std     2,x
		puls    u,pc

L0150	anda    #$80                    _INIT set?
		bne     L015b                   branch if so (already inited)
		pshs    u
		lbsr    _setbase                call setbase to initialize
		leas    2,s
L015b	ldd     #1                      from current position
		pshs    d
		clrb
		pshs    d
		pshs    d
		ldd     8,u                     get _fd
		pshs    d
		lbsr    _lseek
		leas    8,s
		ldd     2,x                     copy _flacc to stack
		pshs    d                       get LSW
		ldd     ,x                      get MSW
		pshs    d
		lda     6,u                     get _flag
		anda    #$01                    _WRITTEN
		beq     L0180
		ldd     2,u                     get unflushed part
		bra     L0182
L0180	ldd     4,u                     get _end
L0182	pshs    d
		ldd     ,u                      get _ptr in D
		subd    ,s++                    subract flushed part
_litol	EXTERNAL
		lbsr    _litol                  make long in flacc
_ladd	EXTERNAL
		lbsr    _ladd                   flacc += 0,s
		puls    u,pc                    x -> flacc
	}
}
