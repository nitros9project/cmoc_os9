                    section   code      ; begin code section

* OS-9 system function equates

_errno              EXTERNAL            ; import external symbol

F$Send              equ       $08       ; define constant as $08
F$ID                equ       $0c       ; define constant as $0c

_rpterr             EXPORT              ; export this symbol
_rpterr:            std       _errno,y  ; store D to indexed value _errno,y
                    pshs      b,y       ; save B,Y on the hardware stack
                    os9       $0C       ; F$ID
                    puls      b,y       ; restore B,Y from the hardware stack
                    os9       $08       ; F$Send
                    rts                 ; return to caller

                    endsect             ; end current section

