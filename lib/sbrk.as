*
* Request memory from OS
* Adapted from cmoc_os9/lib/todo/sbrk.a for the live CMOC ABI.
*

                    use       ../include/os9.d ; shared OS-9 service and error constants

                    section   code      ; begin code section

_sbrk               EXPORT    ;         export C sbrk-style allocator

__memend            EXTERNAL  ;         import current process memory end
_spare              EXTERNAL  ;         import spare-byte count below current memory end
_os9err             EXTERNAL  ;         import errno-style OS-9 error handler

_sbrk:
stk_sbrk_ret        equ       0         ; caller return address
stk_sbrk_size       equ       2         ; requested byte count
                    ldd       __memend,y ; get current high memory bound
                    pshs      d         ; save old memory end while computing allocation
                    ldd       stk_sbrk_size+2,s ; get requested size after saved old bound
                    cmpd      _spare,y  ; check whether existing spare memory is enough
                    blo       sbrk20    ; use spare space when request fits

* have to get some from the system
                    pshs      y         ; preserve data pointer across F_Mem
                    clra                ; request current memory size from F_Mem
                    clrb                ; request current memory size from F_Mem
                    os9       F_Mem     ; get current memory size/end
                    addd      stk_sbrk_size+4,s ; add requested increase after saved old bound/Y
                    os9       F_Mem     ; resize process memory to requested high bound
                    tfr       y,d       ; copy returned high bound into D
                    puls      y         ; restore data pointer
                    bcc       sbrk10    ; continue when OS-9 accepted the resize
                    leas      2,s       ; discard saved old memory end
                    ldb       #E_MemFul ; report process memory full
                    lbra      _os9err   ; convert OS-9 error to C return convention

sbrk10              std       __memend,y ; save new memory end
                    addd      _spare,y  ; include old spare bytes in the new spare total
                    subd      ,s        ; subtract old memory end
                    std       _spare,y  ; save updated spare count

* now spare is big enough
sbrk20              leas      2,s       ; discard saved old memory end
                    ldd       _spare,y  ; get spare byte count
                    pshs      d         ; save original spare count
                    subd      stk_sbrk_size+2,s ; subtract requested byte count after saved spare
                    std       _spare,y  ; save remaining spare byte count
                    ldd       __memend,y ; get current high memory bound
                    subd      ,s++      ; compute base address of the free spare block
                    pshs      d         ; save allocation base for return and zero-fill

                    clra                ; zero byte used to initialize allocated memory
                    ldx       ,s        ; load allocation cursor
sbrk30              sta       ,x+       ; clear next allocated byte
                    cmpx      __memend,y ; stop when cursor reaches current memory end
                    blo       sbrk30    ; keep clearing the allocated block

                    puls      d,pc      ; return allocation base

                    endsect   ;         end current section
