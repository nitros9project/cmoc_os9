 section code

* OS-9 system function equates

_errno EXTERNAL

F$Send equ $08
F$ID equ $0c

_rpterr EXPORT
_rpterr: std   _errno,y
 pshs  b,y
 os9 $0C F$ID
 puls  b,y
 os9 $08 F$Send
 rts

 endsect

