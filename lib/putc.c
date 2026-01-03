#include <stdio.h>
#include <os.h>

__norts__ asm int
putc(int c, FILE *stream)
{
    asm
    {
* 0,s  = return address
* 2,s  = character
* 4,s  = FILE *
__iob	EXTERNAL
__os_write	EXTERNAL
__os_writeln	EXTERNAL
__os_close	EXTERNAL
_setbase	EXTERNAL
_ftell	EXTERNAL

		pshs  u
		ldu   2+4,s 		get FILE ptr
		ldd   6,u 			get _flag offset in FILE
		anda  #$80          mask out all but _INIT flag
		andb  #_ERR|_WRITE  mask out all but _ERR and _WRITE flags
		cmpb  #_WRITE       error clear and JUST write?
		bne   badexit       nope, exit with error
		cmpa  #$80          initialized?
		beq   inited        branch if so
		pshs  u             put FILE pointer on stack
		lbsr  _setbase      setup FILE pointer
		leas  2,s           clean up stack
inited 	ldd   6,u           get _flag pointer in FILE
		andb  #_UNBUF
		beq   buffered      branch if buffered
* unbuffered I/O
		ldd   #1			write 1 character
		pshs  d 			push count on stack
        leax  ,s			point X to count
        pshs  x				push pointer
		leax  6+2+1,s	    point to character
		ldd   8,u			get _fd path in FILE
		pshs  d,x 			push path and pointer to char
		ldb   7,u           get _flag word in FILE
		andb  #_SCF         SCF?
		beq   L0035         branch if not
		lbsr  __os_writeln
		bra   L0038
L0035 	lbsr  __os_write
L0038 	leas  8,s 			clean up stack
		cmpd  #0 			success?
		beq   L0079 		branch if so
		ldb   7,u           get _flag word in FILE
		orb   #_ERR         mark error
		stb   7,u           save
badexit	ldd   #-1           return -1 as result
 		puls  u,pc          bye!

buffered
     	anda  #$01          _WRITTEN
		bne   L0058         branch if _WRITTEN
		pshs  u
		lbsr  _flush        flush buffer
		std   ,s++
		bne   badexit
L0058 	ldx   ,u            get _ptr of FILE *
		ldb   2+2+1,s       get character
		stb   ,x+
		stx   ,u            save updated pointer to _ptr
		cmpx  4,u           _end ?
		bcc   L0070         branch if not
		ldb   7,u           get _flag+1
		andb  #_SCF
		beq   L0079         exit if RBF
		ldb   2+2+1,s       get character
		cmpb  #$0A          was it CR?
		bne   L0079         no, exit
		ldb   #$0D
L0070 	pshs  u             else
		lbsr  _flush        flush
		std   ,s++
		bne   badexit
L0079 	ldd   4,s               clean up stack
 		puls  u,pc              bye!
 	}
 }

__norts__ asm int
putw(int w, FILE *stream)
{
    asm
    {
		pshs  u
		ldu   2+2+2,s           get FILE pointer
		ldb   2+2,s             get upper 8 bits of word
		pshs  d,u               make room on stack
		lbsr  putc              put it
		ldb   4+2+2+1,s         get lower 8 bits of word
		stb   1,s               save in stack location
		lbsr  putc              put it
		leas  4,s               clean up stack
		cmpd  #-1               error?
		beq                     putwbye
		clra
		clrb
putwbye
		puls  u,pc

_tidyup:
        pshs  u
 		leax  __iob,y           point to base IOB
		ldb   #_NFILE           get number of FILE ptrs
		pshs  b                 save counter
L009d 	pshs  x
		lbsr  fclose            close FILE
		puls  x
		leax  13,x              point to next FILE
		dec   ,s
		bne   L009d
		puls  b,u,pc
	}
}

__norts__ asm int
fclose(FILE *stream)
{
    asm
    {
		pshs  u
		ldu   2+2,s             get FILE ptr
		lbeq  badexit
		ldd   6,u               get _flag word
		lbeq  badexit           branch if zero
		andb  #_WRITE           write mode?
		beq   L00c5             no
		pshs  u                 push FILE ptr
		bsr   fflush            flush
		leas  2,s               clean up stack
		bra   L00c7
L00c5 	clra
 		clrb
L00c7 	pshs  d
		ldd   8,u               get path
		pshs  d
		lbsr  __os_close        close
		leas  2,s               clean up stack
		clra
		clrb
		std   6,u               clear _flag word
		puls  d,u,pc            clear stack and return
	}
}


__norts__ asm int
fflush(FILE *stream)
{
    asm
    {
		pshs  u
		ldu   2+2,s             get FILE ptr
		lbeq  badexit           exit if null
		ldd   6,u               get _flags word
		andb  #_ERR|_WRITE
		cmpb  #_WRITE
		lbne  badexit
		anda  #$80              initialized?
		bne   finited           branch if so
		pshs  u
		lbsr  _setbase          initialize
		leas  2,s               clean up stack
finited
     	pshs  u
		bsr   _flush
		leas  2,s
		puls  u,pc

* actual flusher
* marks iob with "WRITTEN"
* routes output AR for SCF & RBF
* calls ftell and lseek if first write on partial buffer
* resets ptr to buffer start & marks w/"WRITTEN"
* Entry: 0,s = return address
*        2,s = FILE *
_flush	pshs  u
		ldu   2+2,s         get FILE *
		leas  -4,s
		lda   6,u           get _flag
		anda  #1            _WRITTEN set?
		bne   L012c         branch if so
		ldd   ,u            get _ptr
		cmpd  4,u           compare to _end
		beq   L012c         branch if buffer full
		clra
		clrb
		pshs  d
		pshs  u
		lbsr  ftell         position
		leas  2,s           eat FILE * pushed earlier
		ldd   2,x           LSW
		pshs  d             save on stack
		ldd   ,x            MSW
		pshs  d             save on stack
		ldd   8,u           get _fd path
		pshs  d             do seek
_lseek  EXTERNAL
		lbsr  _lseek
		leas  8,s           clean stack
L012c 	ldd   ,u            get _ptr
		subd  2,u           subtract _base
		std   2,s           save on stack
		lbeq  L0194         if none
		ldd   6,u           get _flag word
		anda  #1            _WRITTEN
		lbeq  L0194         branch if not written
		andb  #_SCF
		beq   _flushrbf     branch if RBF
		ldd   2,u           get _base
		bra   _flush3
* flush SCF device
_flush2
        pshs  x				save off X (do we need to?)
     	pshs  d				put count on stack
     	leax  ,s			point X to count on stack
     	pshs  x 			push pointer
		ldd   ,u 			get address of data to write
		pshs  d 			push on stack
		ldd   8,u 			get _fd
		pshs  d 			push on stack
		lbsr  __os_writeln 	write it
		leas  10,s 			restore stack
		cmpd  #0			success?
		bne   L0185 		branch if not
		ldd   2,s           get _ptr minus _base computed earlier
		subd  -4,s          subtract from amount written
		std   2,s           write back to stack
		ldd   ,u            get _ptr
		addd  -4,s          add amount written
_flush3	std   ,u            udpate _ptr
		ldd   2,s           get _ptr minus _base computed earlier
		bne   _flush2       branch if not zero
		bra   L0194

* flush RBF device
_flushrbf
    	pshs  x                 save X
   	 	leax  2,s 				get address of count
		pshs  x                 save as 3rd parameter
		ldd   2,u               get _base
		pshs  d                 save as 2nd parameter
		leax  8,u               get _fd into X
		pshs  x                 save as 1st parameter
		lbsr  __os_write
		leas  8,s               clean up stack
		ldd   8,u               get _fd into D
		cmpd  2,s               did we write all?
		beq   L0194
L0185 	ldb   7,u               get _flag+1
		orb   #_ERR             set error flag
		stb   7,u               save in _flag+1
		ldd   4,u               get _end
		std   ,u                set _ptr to end of buffer
		ldd   #-1               return EOF
		bra   L01a4

L0194 	lda   6,u               get _flag
		ora   #1                set _WRITTEN flag
		sta   6,u               save it to _flag
		ldd   2,u               get _base to reset pointers
		std   ,u                store _ptr
		addd  11,u              add _bufsiz
		std   4,u               store in _end
		clra
		clrb
L01a4 	leas  4,s
 		puls  u,pc
 	}
}

