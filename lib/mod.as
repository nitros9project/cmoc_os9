__os_modlink        EXPORT    ;         export module link wrapper
__os_modload        EXPORT    ;         export module load wrapper
__os_modunlink      EXPORT    ;         export module unlink wrapper

_oserr              EXTERNAL  ;         common OS-9 error return helper
_osret              EXTERNAL  ;         common successful return helper

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

__os_modlink:
stk_os_modlink_ret  equ       0         ; caller return address
stk_os_modlink_name equ       2         ; module name pointer
stk_os_modlink_lang equ       4         ; language nibble argument
stk_os_modlink_type equ       6         ; type nibble argument
stk_os_modlink_addrp equ       8         ; caller pointer receiving module address
                    pshs      y,u       ; preserve registers used by OS-9
                    ldx       stk_os_modlink_name+4,s ; load module name pointer
                    lda       stk_os_modlink_lang+5,s ; load module language nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    ora       stk_os_modlink_type+5,s ; merge requested module type nibble
                    os9       F_Link    ; ask OS-9 to link the named module
mod_store_result    tfr       u,d       ; copy returned module address into D
                    puls      y,u       ; restore preserved registers
                    lblo      _oserr    ; dispatch OS-9 carry-set failure path
                    std       [stk_os_modlink_addrp,s] ; store module address through caller pointer
                    lbra      _osret    ; return success with cleared errno

__os_modload:
stk_os_modload_ret  equ       0         ; caller return address
stk_os_modload_name equ       2         ; module path/name pointer
stk_os_modload_lang equ       4         ; language nibble argument
stk_os_modload_type equ       6         ; type nibble argument
stk_os_modload_addrp equ       8         ; caller pointer receiving module address
                    pshs      y,u       ; preserve registers used by OS-9
                    ldx       stk_os_modload_name+4,s ; load module name pointer
                    lda       stk_os_modload_lang+5,s ; load module language nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    asla                ; shift language into high nibble
                    ora       stk_os_modload_type+5,s ; merge requested module type nibble
                    os9       F_Load    ; load and link the named module
                    bra       mod_store_result ; share common post-call handling

__os_modunlink:
stk_os_modunlink_ret equ       0         ; caller return address
stk_os_modunlink_addr equ       2         ; module address to unlink
                    pshs      u         ; preserve caller's U register
                    ldu       stk_os_modunlink_addr+2,s ; load module address to unlink
                    os9       F_UnLink  ; release the linked module
                    puls      u         ; restore caller's U register
                    lbra      _osret    ; return through common success path

                    endsect   ;         end code section
