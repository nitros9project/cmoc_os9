_fclose             EXPORT    ;         export stream close helper

__os_close          EXTERNAL  ;         low-level close wrapper
_fflush             EXTERNAL  ;         stream flush helper

_WRITE              equ       $02       ; FILE open-for-write flag

                    section   code      ; begin code section

_fclose:
stk_fclose_ret      equ       0         ; caller return address
stk_fclose_file     equ       2         ; FILE pointer argument
                    pshs      u         ; preserve caller's U register
                    ldu       stk_fclose_file+2,s ; load FILE pointer after saved U
                    beq       L_fclose_bad ; reject null stream pointers
                    ldd       6,u       ; load FILE flags word
                    beq       L_fclose_bad ; reject unopened streams
                    andb      #_WRITE   ; check whether stream is writable
                    beq       L_fclose_read_only ; skip flush for read-only streams
                    pshs      u         ; pass FILE pointer to fflush
                    lbsr      _fflush   ; flush pending buffered output
                    leas      2,s       ; discard staged FILE pointer
                    bra       L_fclose_path ; continue with close regardless of flush result
L_fclose_read_only  clra                ; synthesize zero status for read-only streams
                    clrb                ; synthesize zero status for read-only streams
L_fclose_path       pshs      d         ; preserve flush status across low-level close
                    ldd       8,u       ; load underlying path number
                    pshs      d         ; stage path number for __os_close
                    lbsr      __os_close ; close the underlying OS-9 path
                    leas      2,s       ; discard staged path number
                    clra                ; clear high byte for zero flag word
                    clrb                ; clear low byte for zero flag word
                    std       6,u       ; mark FILE entry as unused
                    puls      d,u,pc    ; restore flush status and caller's U, then return
L_fclose_bad        ldd       #-1       ; return EOF on failure
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
