*
* Request memory from OS
* Adapted from cmoc_os9/lib/todo/sbrk.a for the live CMOC ABI.
*

                    section   code      ; begin code section

_sbrk               EXPORT              ; export this symbol

__memend            EXTERNAL            ; import external symbol
_spare              EXTERNAL            ; import external symbol
_os9err             EXTERNAL            ; import external symbol

_sbrk               ldd       __memend,y ; get hi bound
                    pshs      d         ; save it
                    ldd       4,s       ; get requested size
                    cmpd      _spare,y  ; any spare left?
                    blo       sbrk20    ; branch if lower to sbrk20

* have to get some from the system
                    pshs      y         ; save data pointer
                    clra                ; clear A
                    clrb                ; clear B
                    os9       $07       ; get current size/end
                    addd      6,s       ; add requested increase
                    os9       $07       ; re-size memory
                    tfr       y,d       ; save high bound
                    puls      y         ; restore data pointer
                    bcc       sbrk10    ; branch if carry is clear to sbrk10
                    leas      2,s       ; junk scratch
                    ldb       #$CF      ; load B from immediate value $CF
                    lbra      _os9err   ; long branch unconditionally to _os9err

sbrk10              std       __memend,y ; save new memory address
                    addd      _spare,y  ; add in spare bytes
                    subd      ,s        ; less old base
                    std       _spare,y  ; is new spare value

* now spare is big enough
sbrk20              leas      2,s       ; junk scratch
                    ldd       _spare,y  ; get spare count
                    pshs      d         ; save D on the hardware stack
                    subd      4,s       ; less size
                    std       _spare,y  ; updated value
                    ldd       __memend,y ; get hi bound
                    subd      ,s++      ; base of free memory
                    pshs      d         ; save

                    clra                ; clear A
                    ldx       0,s       ; load X from stack-relative value 0,s
sbrk30              sta       ,x+       ; clear new memory
                    cmpx      __memend,y ; compare X against indexed value __memend,y
                    blo       sbrk30    ; branch if lower to sbrk30

                    puls      d,pc      ; restore registers and return

                    endsect             ; end current section
