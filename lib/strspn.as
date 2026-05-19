* Adapted from Deek's KLibc strspn.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strspn             EXPORT    ;         export strspn helper
_strcspn            EXPORT    ;         export strcspn helper

_strchr             EXTERN    ;         import character search helper

_strspn:
stk_strspn_ret      equ       0         ; caller return address
stk_strspn_string   equ       2         ; string to scan
stk_strspn_accept   equ       4         ; accepted-character set
stk_strspn_strchr_char_low equ       3         ; staged _strchr character low byte
                    pshs      x,u       ; preserve caller's X and U registers
                    ldx       stk_strspn_accept+4,s ; load accepted-character set after saved X/U
                    ldu       stk_strspn_string+4,s ; load string scan pointer after saved X/U
                    pshs      x         ; stage accepted set for _strchr calls
Loop_01             ldb       ,u+       ; fetch next string byte and advance
                    beq       BranchTarget_01 ; stop at NUL terminator
                    stb       stk_strspn_strchr_char_low,s ; store character low byte in staged _strchr argument
                    lbsr      _strchr   ; test whether byte belongs to accepted set
                    bne       Loop_01   ; continue while byte is accepted
                    bra       BranchTarget_01 ; compute accepted prefix length

_strcspn:
stk_strcspn_ret     equ       0         ; caller return address
stk_strcspn_string  equ       2         ; string to scan
stk_strcspn_reject  equ       4         ; rejected-character set
stk_strcspn_strchr_char_low equ       3         ; staged _strchr character low byte
                    pshs      x,u       ; preserve caller's X and U registers
                    ldx       stk_strcspn_reject+4,s ; load rejected-character set after saved X/U
                    ldu       stk_strcspn_string+4,s ; load string scan pointer after saved X/U
                    pshs      x         ; stage rejected set for _strchr calls
Loop_02             ldb       ,u+       ; fetch next string byte and advance
                    beq       BranchTarget_01 ; stop at NUL terminator
                    stb       stk_strcspn_strchr_char_low,s ; store character low byte in staged _strchr argument
                    lbsr      _strchr   ; test whether byte belongs to rejected set
                    beq       Loop_02   ; continue while byte is not rejected
BranchTarget_01     leau      -1,u      ; back up to stopping byte
                    tfr       u,d       ; copy stopping pointer into D
                    subd      stk_strspn_string+6,s ; subtract original string pointer from staged frame
                    leas      4,s       ; discard staged _strchr arguments and saved X
                    puls      u,pc      ; restore U and return prefix length

                    endsect   ;         end current section
