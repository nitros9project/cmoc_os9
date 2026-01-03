* These are assembly implementations of these functions
* The C versions are macros in ctype.h
* char toupper(char c)

 section code

toupper EXPORT
_chcodes EXTERNAL

toupper: clra
 ldb   3,s
 leax  _chcodes,pcr
 lda   d,x
 anda  #4
 beq returnit * beq   L0022
 andb  #$df
 bra returnit
 * clra
 * rts

* char tolower(char c)

tolower EXPORT
_chcodes EXTERNAL

tolower: clra
 ldb   3,s
 leax  _chcodes,pcr
 lda   d,x
 anda  #2
 beq returnit * beq   L0022
 orb   #$20
returnit
 clra
 rts
* L0022 ldd   2,s
*  rts

 endsect
