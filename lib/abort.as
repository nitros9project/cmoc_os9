* Adapted from cmoc_os9/lib/todo/abort.as for the live cmoc_os9 ABI.
*
* The original Kreider abort path tried to dump process memory through
* startup-module symbols. The live CMOC runtime does not use that startup
* model, so the practical libc contract here is simply: do not return.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_abort              EXPORT              ; export this symbol

_abort
                    ldd       #255      ; conventional abnormal exit status
                    os9       F_Exit    ; invoke OS-9 system call F_Exit

                    endsect             ; end current section
