_putw               EXPORT    ;         export 16-bit word output helper

_putc               EXTERNAL  ;         import character-output helper

                    section   code      ; begin code section

_putw:
stk_putw_ret        equ       0         ; caller return address
stk_putw_word       equ       2         ; 16-bit word argument
stk_putw_file       equ       4         ; FILE pointer argument
                    pshs      u         ; preserve caller's U register
                    ldu       stk_putw_file+2,s ; load FILE pointer after saved U
                    ldb       stk_putw_word+2,s ; load high byte of word argument
                    pshs      d,u       ; stage first character and FILE pointer for putc
                    lbsr      _putc     ; write high byte first
                    ldb       stk_putw_word+7,s ; load low byte after saved U and staged putc args
                    stb       1,s       ; replace staged character with low byte
                    lbsr      _putc     ; write low byte second
                    leas      4,s       ; discard staged arguments
                    cmpd      #-1       ; propagate EOF if either byte write failed
                    beq       L_putw_done ; leave failure code intact
                    clra                ; return zero on success
                    clrb                ; return zero on success
L_putw_done         puls      u,pc      ; restore U and return

                    endsect   ;         end current section
