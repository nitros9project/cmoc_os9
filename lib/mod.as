__os_modlink        EXPORT              ; export module link wrapper
__os_modload        EXPORT              ; export module load wrapper
__os_modunlink      EXPORT              ; export module unlink wrapper

_oserr              EXTERNAL            ; common OS-9 error return helper
_osret              EXTERNAL            ; common successful return helper

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

__os_modlink
                    pshs      y,u       ; preserve registers used by OS-9
                    ldx       6,s       ; load module name pointer
                    lda       9,s       ; load module language nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    ora       11,s      ; merge in requested module type nibble
                    os9       F_Link    ; ask OS-9 to link the named module
L000f               tfr       u,d       ; copy returned module address into D
                    puls      y,u       ; restore preserved registers
                    lblo      _oserr    ; dispatch OS-9 carry-set failure path
                    std       [8,s]     ; store linked module address through output pointer
                    lbra      _osret    ; return success with cleared errno

__os_modload
                    pshs      y,u       ; preserve registers used by OS-9
                    ldx       6,s       ; load module name pointer
                    lda       9,s       ; load module language nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    ora       11,s      ; merge in requested module type nibble
                    os9       F_Load    ; load and link the named module
                    bra       L000f     ; share common post-call handling

__os_modunlink
                    pshs      u         ; preserve caller's U register
                    ldu       4,s       ; load module address to unlink
                    os9       F_UnLink  ; release the linked module
                    puls      u         ; restore caller's U register
                    lbra      _osret    ; return through common success path

                    endsect             ; end code section
