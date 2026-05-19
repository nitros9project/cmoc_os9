* Adapted from Deek's KLibc strlen.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strlen             EXPORT    ;         export strlen helper

_strlen:
stk_strlen_ret      equ       0         ; caller return address
stk_strlen_string   equ       2         ; string pointer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_strlen_string+2,s ; load string pointer after saved U
Loop_01             ldb       ,u+       ; scan next byte and advance
                    bne       Loop_01   ; continue until NUL terminator
                    leau      -1,u      ; back up to the NUL terminator
                    tfr       u,d       ; copy terminator address into D
                    subd      stk_strlen_string+2,s ; subtract original string pointer
                    puls      u,pc      ; restore U and return string length

                    endsect   ;         end current section
