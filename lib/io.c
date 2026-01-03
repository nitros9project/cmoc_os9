#include "fcntl.h"


__norts__ asm error_code
_os_create(char *pathname, int mode, path_id *path, int perm)
{
	asm
    {
_oserr  EXTERN
_osret  EXTERN
* stack:
*	0,s = return address
*	2,s = pathname pointer
*	4,s = mode
*	6,s = path pointer [out]
*	8,s = permissions
		ldx 	    2,s 		get pointer to pathname
		lda   	    8+1,s 	    get permissions byte
		tfr   	    a,b
		andb	    #$24
		orb 	    #$0b
		os9		    I$Create
		bcc 	    createok
		cmpb	    #$da
		bne		    createerr
		lda		    4+1,s 		get mode
		bita	    #$80
		bne		    createerr
		anda	    #7
		ldx 	    2,s 		get pointer to pathname
		os9		    I$Open
		bcs 	    createerr
		pshs	    d		    save off path number
		tfr		    a,b
		clra
		std		    [6+2,s]
		puls	    d
		pshs	    a,u
		ldx		    #0
		leau	    ,x
		ldb 	    #2
		os9		    I$SetStt
		puls	    a,u
		bcc		    createok
		pshs	    b
		os9		    I$Close
		puls	    b
createerr
		lbra	    _oserr
createok
		tfr		    a,b
		clra
		std		    [6,s]
		lbra	    _osret
    }
}


__norts__ asm error_code
_os_open(char *pathname, int mode, path_id *path)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = pathname pointer
*	4,s = mode
*	6,s = path pointer [out]
		ldx  	    2,s 			; get pathname pointer
		lda		    5,s				; get mode
		os9		    I$Open
		lblo	    _oserr
		pshs	    d
		tfr		    a,b
		clra
		std		    [6+2,s]
		puls	    d
		lbra	    _osret
    }
}


__norts__ asm error_code
_os_close(path_id path)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = path
        lda         2+1,s           ; get path
        os9         I$Close
        lbra	    _osret
    }
}


__norts__ asm error_code
_os_delete(char *pathname, int mode)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = pathname pointer
*	4,s = mode
        ldx         2,s             ; get pathname pointer
        lda         4+1,s           ; get mode
        os9         I$DeletX
        lbra	    _osret
    }
}


__norts__ asm error_code
_os_makdir(char *pathname, int perm)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = pathname pointer
*	4,s = permissions
        ldx         2,s             ; get pathname pointer
        ldb         5,s             ; get permissions
        os9         I$MakDir
        lbra	    _osret
    }
}


__norts__ asm error_code
_os_read(path_id path, void *data, int *count)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = path
*	4,s = data pointer
*	6,s = count pointer [in/out]
		pshs		y
		lda			3+2,s	 		path
		ldx			4+2,s			pointer to data
		ldy			[6+2,s] 		count
		pshs		y
		os9			I$Read
afterread
		bcc			savecount
		cmpb		#$d3 E$EOF?
		bne			readerr
		ldy			#0000
		bra			savecount
readerr	puls		x,y
		lbra		_oserr
savecount sty		[6+4,s]
		puls		x,y
		lbra		_osret
    }
}

__norts__ asm error_code
_os_readln(path_id path, void *data, int *count)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = path
*	4,s = data pointer
*	6,s = count pointer [in/out]
		pshs		y
		lda			3+2,s
		ldx			4+2,s
		ldy			[6+2,s]
		pshs		y
		os9			I$ReadLn
		bra			afterread
	}
}

__norts__ asm error_code
_os_write(path_id path, void *data, int *count)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = path
*	4,s = data pointer
*	6,s = count pointer [in/out]
		pshs		y
		ldy			[6+2,s]		get length
		beq			writeex		if zero, nothing to do
		lda			3+2,s		get path
		ldx			4+2,s		get data pointer
		os9			I$Write
L00xe	bcc			store_writeex
		puls		y
		lbra		_oserr
store_writeex
		sty			[6+2,s]
writeex
		puls		y
		lbra		_osret
	}
}

__norts__ asm error_code
_os_writeln(path_id path, void *data, int *count)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = path
*	4,s = data pointer
*	6,s = count pointer [in/out]
		pshs		y
		ldy			[6+2,s]			get length
		beq			writeex			if zero, nothing to do
		lda 		3+2,s 			get path
		ldx 		4+2,s 			get data pointer
		os9			I$WritLn
		bra			L00xe
	}
}

__norts__ asm error_code
_os_seek(path_id path, long position)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = path
*	4,s = MSW of 32-bit position
*   6,s = LSW of 32-bit position
		pshs 		d,x,u
		ldu         4+4,s
		ldx         4+6,s
		lda         4+2+1,s
        os9         I$Seek
        puls        d,x,u
        lbra        _osret
    }
}

__norts__ asm long
lseek(int path, long position, int whence)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = path
*	4,s = MSW of 32-bit position
*   6,s = LSW of 32-bit position
*	8,s = whence flag
		pshs 		d,u
		ldd         4+8,s               get whence flag
		bne         lseek10
		ldu         #0
		ldx         #0
		bra         doseek

lseek10
        cmpd        #1                  from current location?
        beq         here
        cmpd        #2                  from the end?
        beq         end
* bad type
        ldb         #E$Seek

lserr   clra
        std         _errno,y
        ldd         #-1
_flacc  EXTERNAL
        leax        _flacc,y
        std         0,x
        std         2,x
        puls        d,u,pc

* from the end
end     lda         4+2+1,s             get path number
        ldb         #SS_Size            get file size code
        os9         I$GetStt
        bcs         lserr

        bra         doseek

here    lda         4+2+1,s             get path number
        ldb         #SS_Pos
        os9         I$GetStt
        bcs         lserr

doseek  tfr         u,d                 work on the LSW first
        addd        4+6+1,s             get low byte of LSW
        std         _flacc+2,y          store in LSW of _flacc
        tfr         d,u                 put D in U
        tfr         x,d                 and X in D
        adcb        4+4+1,s             add with carry low byte of MSW in B
        adca        4+4,s               and with carry high byte of MSW in A
        bmi         lserr               if negiative, seek is before beginning of file
        tfr         d,x                 move D to X
        std         _flacc,y            store in MSW of _flacc

        lda         4+2+1,s             get path number
        os9         I$Seek
        bcs         lserr

        leax        _flacc,y
        puls        d,u,pc
	}
}
