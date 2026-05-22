* Adapted from cmoc_os9/lib/ported/setbuf.as for the live cmoc_os9 ABI.

                    use       ../include/stdio.d ; shared FILE layout and flag constants

                    section   code      ; begin code section

_setbuf             EXPORT    ;         export stdio caller-supplied buffer setter

_fflush             EXTERN    ;         import stream flush helper

_setbuf:
stk_setbuf_ret      equ       0         ; caller return address
stk_setbuf_file     equ       2         ; FILE pointer argument
stk_setbuf_buffer   equ       4         ; caller buffer pointer or NULL
                    pshs      u         ; preserve caller's U register
                    ldu       stk_setbuf_file+2,s ; load FILE pointer after saved U
                    beq       BranchTarget_04 ; ignore NULL stream pointers
                    lda       FILE_FLAG,u ; load high byte of FILE flags
                    anda      #_WRITTEN_HIGH ; test for pending write state
                    beq       BranchTarget_01 ; skip flush if no write data is pending
                    pshs      u         ; pass FILE pointer to fflush
                    lbsr      _fflush   ; flush pending output before changing buffer
                    leas      2,s       ; discard fflush argument
BranchTarget_01     ldd       FILE_FLAG,u ; load current FILE flags
                    anda      #^_WRITTEN_HIGH ; clear written-state bit
                    andb      #^(_BIGBUF|_UNBUF) ; clear existing buffer-mode bits
                    std       FILE_FLAG,u ; save reset FILE flags
                    ldx       stk_setbuf_buffer+2,s ; load caller buffer pointer after saved U
                    beq       BranchTarget_03 ; NULL buffer requests unbuffered mode
                    ldd       FILE_BUFSIZ,u ; load current buffer size
                    bne       BranchTarget_02 ; keep current size when already set
                    ldd       #$0100    ; default caller buffer size to BUFSIZ
                    std       FILE_BUFSIZ,u ; save default buffer size
BranchTarget_02     stx       FILE_BASE,u ; install caller buffer as base pointer
                    leax      d,x       ; compute end pointer as buffer + size
                    ldb       #_BIGBUF  ; mark stream as using a full buffer
                    bra       Continue_01 ; merge buffer-mode flag
BranchTarget_03     leax      FILE_BUFSIZ,u ; use FILE buffer-size field as one-byte fallback storage
                    ldb       #_UNBUF   ; mark stream unbuffered
Continue_01         orb       FILE_FLAG+1,u ; merge selected buffer-mode flag
                    stb       FILE_FLAG+1,u ; save low FILE flags
                    stx       FILE_END,u ; set current buffer end
                    stx       FILE_PTR,u ; reset current pointer to buffer end
BranchTarget_04     puls      u,pc      ; restore U and return

                    endsect   ;         end current section
