* Simple in-place generic sort for the live cmoc_os9 ABI.
* This intentionally avoids the older recursive quicksort port, which was
* corrupting the machine at runtime.

                    section   bss

_QWIDTH             rmb       2         ; byte width of each array element
_QCMP               rmb       2         ; caller comparison function pointer
_QEND               rmb       2         ; address of the final element in the array
_QI                 rmb       2         ; outer-loop element pointer
_QJ                 rmb       2         ; inner-loop element pointer
_QCOUNT             rmb       2         ; byte counter used while swapping elements

                    endsect   ;         end qsort work storage

                    section   code      ; begin code section

_qsort              EXPORT    ;         export generic in-place sort

ccmult              EXTERNAL  ;         import unsigned 16-bit multiply helper

_qsort:
stk_qsort_ret       equ       0         ; caller return address
stk_qsort_base      equ       2         ; base pointer for the array
stk_qsort_nel       equ       4         ; number of elements in the array
stk_qsort_width     equ       6         ; byte width of each element
stk_qsort_compar    equ       8         ; comparison callback pointer
                    pshs      u         ; preserve caller's U register
                    ldd       stk_qsort_width+2,s ; load element width after saved U
                    std       _QWIDTH,y ; keep element width in static scratch
                    ldd       stk_qsort_compar+2,s ; load comparison callback after saved U
                    std       _QCMP,y   ; keep comparison callback in static scratch
                    ldd       stk_qsort_nel+2,s ; load element count after saved U
                    cmpd      #2        ; arrays with fewer than two elements are already sorted
                    lblo      Done      ; return if no comparisons are needed
                    ldd       _QWIDTH,y ; reload element width
                    lbeq      Done      ; zero-width elements cannot be advanced

* Compute the last element address: base + (nel - 1) * width.
                    ldd       stk_qsort_nel+2,s ; reload element count after saved U
                    addd      #-1       ; convert count to last element index
                    pshs      d         ; pass last index to ccmult; helper consumes this word
                    ldd       _QWIDTH,y ; multiply index by element width
                    lbsr      ccmult    ; return byte offset of final element in D
                    addd      stk_qsort_base+2,s ; add base pointer after saved U
                    std       _QEND,y   ; save final element address

                    ldd       stk_qsort_base+2,s ; initialize outer pointer at array base
                    std       _QI,y     ; save current outer element pointer

OuterLoop
                    ldd       _QI,y     ; load current outer element pointer
                    cmpd      _QEND,y   ; stop when outer pointer reaches the final element
                    bhs       Done      ; no later element remains to compare

                    addd      _QWIDTH,y ; start inner scan at the next element
                    std       _QJ,y     ; save current inner element pointer

InnerLoop
                    ldd       _QJ,y     ; load current inner element pointer
                    cmpd      _QEND,y   ; compare against final element address
                    bhi       NextI     ; advance outer loop after the inner scan passes the end

* if ((*compar)(i, j) > 0) swap the two elements.
                    pshs      d         ; pass second element pointer to comparison callback
                    ldu       _QI,y     ; load first element pointer
                    pshs      u         ; pass first element pointer to comparison callback
                    jsr       [_QCMP,y] ; call caller-supplied comparison function
                    leas      4,s       ; discard comparison arguments
                    addd      #0        ; refresh condition codes from signed comparison result
                    ble       NoSwap    ; leave order unchanged unless first element is greater

                    ldu       _QI,y     ; point U at first element for byte swap
                    ldx       _QJ,y     ; point X at second element for byte swap
                    ldd       _QWIDTH,y ; load element byte count
                    std       _QCOUNT,y ; initialize swap byte counter

SwapLoop
                    ldd       _QCOUNT,y ; read remaining bytes to swap
                    beq       NoSwap    ; finish once the entire element width has moved
                    lda       ,u        ; fetch byte from first element
                    ldb       ,x        ; fetch byte from second element
                    stb       ,u+       ; store second byte into first element and advance
                    sta       ,x+       ; store first byte into second element and advance
                    ldd       _QCOUNT,y ; reload remaining byte count
                    subd      #1        ; account for the byte just swapped
                    std       _QCOUNT,y ; save updated swap byte count
                    bra       SwapLoop  ; continue until the element payloads are exchanged

NoSwap
                    ldd       _QJ,y     ; load current inner pointer
                    addd      _QWIDTH,y ; advance to the next candidate element
                    std       _QJ,y     ; save updated inner pointer
                    bra       InnerLoop ; continue inner scan

NextI
                    ldd       _QI,y     ; load current outer pointer
                    addd      _QWIDTH,y ; advance outer pointer by one element
                    std       _QI,y     ; save updated outer pointer
                    bra       OuterLoop ; restart inner scan for the new outer element

Done
                    puls      u,pc      ; restore U and return

                    endsect   ;         end code section
