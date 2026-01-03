***********************************
*
* Unbuffered write and flush
* code in the absense of buffering.
*
* by Mike Sweet 5/10/90
*

 section code

_errno EXTERN

_cwrite EXPORT
_cwrite:
 pshs y save y
 tfr u,y byte count to y
 os9 $8A I$WRITE write it
 bcs error
 puls y
_Flush:
 clra
 clrb
 rts

error puls y
 clra
 std _errno,y
 ldd #-1
 rts return -1 on error

 endsect
