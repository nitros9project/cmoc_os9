 section code

_lmove EXPORT

_lmove: pshs  y
 ldy   4,s
 ldd   ,x
 std   ,y
 ldd   2,x
 std   2,y
 puls  x
 exg   y,x
 puls  d
 std   ,s
 rts

 endsect

