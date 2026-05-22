* Compact assembly implementation of reverse().

                    section   code      ; begin code section

_reverse            EXPORT    ;         export in-place string reverse helper

_strlen             EXTERNAL  ;         import string length helper

_reverse:
stk_reverse_ret     equ       0         ; caller return address
stk_reverse_string  equ       2         ; string pointer argument
                    pshs      u         ; preserve caller's U register
                    ldu       stk_reverse_string+2,s ; load string pointer after saved U
                    pshs      u         ; save original string pointer for return address math
                    pshs      u         ; pass string pointer to strlen()
                    lbsr      _strlen   ; compute string length
                    leas      2,s       ; discard strlen argument
                    addd      ,s++      ; add string base and discard saved base pointer
                    tfr       d,x       ; point X one byte past the string terminator
                    bra       L_reverse_check ; enter loop test before swapping

L_reverse_loop
                    ldb       ,u        ; fetch character from the front half
                    lda       ,-x       ; step back and fetch character from the back half
                    sta       ,u+       ; write back-half character to front and advance U
                    stb       ,x        ; write front-half character to back

L_reverse_check
                    pshs      x         ; stage back pointer for compare because CMPU lacks direct X form
                    cmpu      ,s++      ; compare front pointer against back pointer and discard staged X
                    blo       L_reverse_loop ; continue while pointers have not crossed
                    ldd       stk_reverse_string+2,s ; return original string pointer after saved U
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
