* Adapted from Deek's KLibc strtok.a for the live cmoc_os9 ABI.

                    section   code      ; begin code section

_strtok             EXPORT    ;         export strtok helper

_strspn             EXTERN    ;         import initial delimiter-span helper
_strpbrk            EXTERN    ;         import delimiter search helper

_strtok:
stk_strtok_ret      equ       0         ; caller return address
stk_strtok_string   equ       2         ; input string pointer or NULL
stk_strtok_delims   equ       4         ; delimiter string pointer
stk_strtok_result   equ       0         ; saved return pointer in local D slot
                    clra                ; initialize default NULL return value
                    clrb                ; initialize default NULL return value
                    pshs      d,u       ; reserve return pointer slot and preserve U
                    ldu       stk_strtok_string+4,s ; load input string after local D/U
                    bne       BranchTarget_01 ; use new input string when supplied
                    ldu       _save,y   ; resume tokenization from saved scan pointer
                    beq       BranchTarget_02 ; return NULL when no saved scan remains
BranchTarget_01     ldx       stk_strtok_delims+4,s ; load delimiter set after local D/U
                    pshs      x         ; pass delimiter set to strspn
                    pshs      u         ; pass current scan pointer to strspn
                    lbsr      _strspn   ; skip leading delimiters
                    leas      4,s       ; discard strspn arguments
                    leau      d,u       ; advance to first non-delimiter byte
                    ldb       ,u        ; test candidate token byte
                    beq       BranchTarget_02 ; return NULL if only delimiters remain
                    stu       stk_strtok_result,s ; save token start as return value
                    ldx       stk_strtok_delims+4,s ; reload delimiter set after local D/U
                    pshs      x         ; pass delimiter set to strpbrk
                    pshs      u         ; pass token start to strpbrk
                    lbsr      _strpbrk  ; find next delimiter in token
                    leas      4,s       ; discard strpbrk arguments
                    std       _save,y   ; save delimiter pointer for continuation
                    beq       BranchTarget_02 ; token reaches end of string
                    tfr       d,x       ; point X at delimiter byte
                    clr       ,x+       ; terminate current token in place
                    stx       _save,y   ; resume after delimiter next time
BranchTarget_02     puls      d,u,pc    ; return token pointer and restore U

                    section   bss       ; begin bss section

_save               rmb       2         ; saved strtok continuation pointer

                    endsect   ;         end current section
