* Simple in-place generic sort for the live cmoc_os9 ABI.
* This intentionally avoids the older recursive quicksort port, which was
* corrupting the machine at runtime.

                    section   bss

_QWIDTH             rmb       2
_QCMP               rmb       2
_QEND               rmb       2
_QI                 rmb       2
_QJ                 rmb       2
_QCOUNT             rmb       2

                    endsect

                    section   code

_qsort              EXPORT

ccmult              EXTERNAL

_qsort
                    pshs      u
                    ldd       8,s
                    std       _QWIDTH,y
                    ldd       10,s
                    std       _QCMP,y
                    ldd       6,s
                    cmpd      #2
                    lblo      Done
                    ldd       _QWIDTH,y
                    lbeq      Done

* Compute the last element address: base + (nel - 1) * width.
                    ldd       6,s
                    addd      #-1
                    pshs      d
                    ldd       _QWIDTH,y
                    lbsr      ccmult
                    addd      4,s
                    std       _QEND,y

                    ldd       4,s
                    std       _QI,y

OuterLoop
                    ldd       _QI,y
                    cmpd      _QEND,y
                    bhs       Done

                    addd      _QWIDTH,y
                    std       _QJ,y

InnerLoop
                    ldd       _QJ,y
                    cmpd      _QEND,y
                    bhi       NextI

* if ((*compar)(i, j) > 0) swap the two elements.
                    pshs      d
                    ldu       _QI,y
                    pshs      u
                    jsr       [_QCMP,y]
                    leas      4,s
                    addd      #0
                    ble       NoSwap

                    ldu       _QI,y
                    ldx       _QJ,y
                    ldd       _QWIDTH,y
                    std       _QCOUNT,y

SwapLoop
                    ldd       _QCOUNT,y
                    beq       NoSwap
                    lda       ,u
                    ldb       ,x
                    stb       ,u+
                    sta       ,x+
                    ldd       _QCOUNT,y
                    subd      #1
                    std       _QCOUNT,y
                    bra       SwapLoop

NoSwap
                    ldd       _QJ,y
                    addd      _QWIDTH,y
                    std       _QJ,y
                    bra       InnerLoop

NextI
                    ldd       _QI,y
                    addd      _QWIDTH,y
                    std       _QI,y
                    bra       OuterLoop

Done
                    puls      u,pc

                    endsect
