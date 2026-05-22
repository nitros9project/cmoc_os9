* Adapted from Deek's KLibc strpbrk.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strpbrk            EXPORT    ;         export strpbrk helper

_index              EXTERN    ;         import character search helper

_strpbrk:
stk_strpbrk_ret     equ       0         ; caller return address
stk_strpbrk_string  equ       2         ; string to scan
stk_strpbrk_accept  equ       4         ; accepted-character set
stk_strpbrk_index_char_low equ       3         ; staged _index character low byte
                    pshs      x,u       ; preserve caller's X and U registers
                    ldx       stk_strpbrk_accept+4,s ; load accepted-character set after saved X/U
                    ldu       stk_strpbrk_string+4,s ; load string scan pointer after saved X/U
                    pshs      x         ; stage accepted-character set for _index
Loop_01             clra                ; clear high byte of character argument
                    ldb       ,u+       ; fetch next string byte and advance
Label_01            beq       BranchTarget_01 ; no accepted character was found
                    stb       stk_strpbrk_index_char_low,s ; store character low byte in staged _index argument
                    lbsr      _index    ; search accepted-character set for current byte
                    beq       Loop_01   ; keep scanning while byte is not accepted
                    leau      -1,u      ; back up to matching byte
                    tfr       u,d       ; return pointer to matching byte
BranchTarget_01     leas      4,s       ; discard staged _index arguments and saved X
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
