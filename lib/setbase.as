* Compact assembly implementation of setbase().

                    use       ../include/os9.d ; shared OS-9 service constants
                    use       ../include/stdio.d ; shared FILE layout and flag constants

                    section   code      ; begin code section

_setbase            EXPORT    ;         export stdio buffer initializer

_ibrk               EXTERNAL  ;         import internal heap allocator
_getstat            EXTERNAL  ;         import GetStat wrapper

BUFSIZ_C            equ       256       ; define constant as 256

_setbase:
stk_setbase_ret     equ       0         ; caller return address
stk_setbase_file    equ       2         ; FILE pointer argument
stk_setbase_gs_status equ       0         ; staged GetStat status-code argument
stk_setbase_gs_bufp equ       2         ; staged path-options buffer pointer
stk_setbase_gs_path equ       4         ; staged path number argument
stk_setbase_gs_optbuf equ       6         ; path-options scratch buffer after arguments
stk_setbase_gs_frame_size equ       38        ; staged arguments plus 32-byte scratch buffer
                    pshs      u         ; preserve caller's U register
                    ldu       stk_setbase_file+2,s ; load FILE pointer after saved U
                    ldb       FILE_FLAG+1,u ; load low byte of FILE flags
                    bitb      #_SCF|_RBF ; test whether device class is already known
                    bne       L_setbase_known ; skip path options query when class is cached
                    leas      -32,s     ; reserve path-options scratch buffer
                    leax      ,s        ; point X at path-options scratch buffer
                    ldd       FILE_FD,u ; load underlying path number
                    pshs      d,x       ; stage path and options buffer for getstat
                    clra                ; request SS_Opt
                    clrb                ; request SS_Opt
                    pshs      d         ; stage status code argument
                    lbsr      _getstat  ; query path options to determine file manager type
                    ldb       #_SCF     ; assume an SCF-style device when option byte is zero
                    lda       stk_setbase_gs_optbuf,s ; inspect option byte from scratch buffer
                    beq       L_setbase_merge ; keep SCF flag when option byte is zero
                    ldb       #_RBF     ; otherwise mark as RBF-style buffered file
L_setbase_merge
                    leas      stk_setbase_gs_frame_size,s ; discard getstat arguments and option scratch buffer
                    orb       FILE_FLAG+1,u ; merge device-class bit into low FILE flags
                    stb       FILE_FLAG+1,u ; save low FILE flags
L_setbase_known
                    lda       FILE_FLAG,u ; load high byte of FILE flags
                    ora       #_INIT_HIGH ; mark stream buffer state initialized
                    sta       FILE_FLAG,u ; save high byte of FILE flags
                    ldd       FILE_FD,u ; load underlying path number
                    cmpd      #1        ; compare D against immediate value 1
                    bne       L_setbase_check ; keep normal buffering for non-stdout streams
                    ldb       FILE_FLAG+1,u ; load low byte of FILE flags
                    orb       #_UNBUF   ; keep stdout unbuffered
                    stb       FILE_FLAG+1,u ; save low byte of FILE flags
L_setbase_check
                    andb      #_BIGBUF+_UNBUF ; skip allocation if buffer mode is already selected
                    bne       L_setbase_done ; leave existing buffer state alone
                    ldd       FILE_BUFSIZ,u ; load requested buffer size
                    bne       L_setbase_have_size ; keep caller-provided buffer size
                    ldd       #BUFSIZ_C ; default to the standard C buffer size
                    std       FILE_BUFSIZ,u ; save default buffer size
L_setbase_have_size
                    ldd       FILE_BASE,u ; load existing buffer base pointer
                    bne       L_setbase_big ; use caller-supplied buffer when present
                    ldd       FILE_BUFSIZ,u ; load allocation size
                    pshs      d         ; pass allocation size to ibrk
                    lbsr      _ibrk     ; allocate a buffer from the runtime heap
                    leas      2,s       ; discard allocation argument
                    std       FILE_BASE,u ; save allocated buffer base
                    cmpd      #-1       ; test for allocation failure
                    beq       L_setbase_unbuf ; fall back to one-byte unbuffered save area
L_setbase_big
                    ldb       #_BIGBUF  ; mark stream as owning a real buffer
                    bra       L_setbase_flag ; merge buffer mode flag
L_setbase_unbuf
                    leax      FILE_SAVE,u ; use the single-byte save slot as fallback buffer
                    stx       FILE_BASE,u ; save fallback buffer base
                    ldd       #1        ; load D from immediate value 1
                    std       FILE_BUFSIZ,u ; set fallback buffer size to one byte
                    ldb       #_UNBUF   ; mark stream unbuffered
L_setbase_flag
                    orb       FILE_FLAG+1,u ; merge chosen buffer mode into low FILE flags
                    stb       FILE_FLAG+1,u ; save low FILE flags
                    ldd       FILE_BASE,u ; load buffer base pointer
                    addd      FILE_BUFSIZ,u ; compute buffer end pointer
                    std       FILE_END,u ; save buffer end pointer
                    std       FILE_PTR,u ; initialize current pointer at buffer end
L_setbase_done
                    puls      u,pc      ; restore U and return

                    endsect   ;         end current section
