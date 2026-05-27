                    use       ../include/fcntl.d ; shared file access constants
                    use       ../include/os9.d ; shared OS-9 error constants
                    use       ../include/stdio.d ; shared FILE layout constants

                    section   code      ; begin code section

_fdopen             EXPORT    ;         export this symbol
_fopen              EXPORT    ;         export this symbol
_freopen            EXPORT    ;         export this symbol

__iob               EXTERN    ;         import static FILE table
_errno              EXTERN    ;         import C errno storage
_fclose             EXTERN    ;         import stream close helper
_open               EXTERN    ;         import low-level open wrapper
_creat              EXTERN    ;         import low-level creat wrapper
_create             EXTERN    ;         import low-level create wrapper
_lseek              EXTERN    ;         import low-level long seek wrapper
_flacc              EXTERN    ;         import shared long return slot

_fdopen:
stk_fdopen_saved_u  equ       0         ; saved U after entry prologue
stk_fdopen_ret      equ       2         ; caller return address after entry prologue
stk_fdopen_fd       equ       4         ; existing OS-9 path number after entry prologue
stk_fdopen_mode     equ       6         ; stdio mode string after entry prologue
                    pshs      u         ; preserve caller U
                    ldu       #0        ; request automatic FILE slot allocation
                    ldx       stk_fdopen_mode,s ; load mode string pointer
                    ldd       stk_fdopen_fd,s ; load existing OS-9 path number
                    lbsr      setiob    ; bind the existing path number to a FILE structure
                    puls      u,pc      ; restore U and return FILE pointer

_fopen:
stk_fopen_saved_u   equ       0         ; saved U after entry prologue
stk_fopen_ret       equ       2         ; caller return address after entry prologue
stk_fopen_path      equ       4         ; pathname pointer after entry prologue
stk_fopen_mode      equ       6         ; stdio mode string after entry prologue
                    pshs      u         ; preserve caller U
                    ldx       stk_fopen_mode,s ; load mode string pointer
                    ldu       stk_fopen_path,s ; load pathname pointer
                    lbsr      openit    ; open or create the path according to the mode string
                    bmi       open1     ; return NULL when the low-level open helper failed
                    ldu       #0        ; request automatic FILE slot allocation
                    ldx       stk_fopen_mode,s ; reload mode string pointer for FILE setup
                    lbsr      setiob    ; allocate or find a free FILE entry for the new path
                    puls      u,pc      ; restore U and return FILE pointer
open1
                    clra                ; return NULL high byte
                    clrb                ; return NULL low byte
                    puls      u,pc      ; restore U and return NULL

_freopen:
stk_freopen_saved_u equ       0         ; saved U after entry prologue
stk_freopen_ret     equ       2         ; caller return address after entry prologue
stk_freopen_path    equ       4         ; pathname pointer after entry prologue
stk_freopen_mode    equ       6         ; stdio mode string after entry prologue
stk_freopen_stream  equ       8         ; FILE * stream to reuse after entry prologue
                    pshs      u         ; preserve caller U
                    ldd       stk_freopen_stream,s ; load stream being reopened
                    pshs      d         ; pass stream pointer to fclose()
                    lbsr      _fclose   ; close the existing stream before reopening it on a new path
                    leas      2,s       ; discard staged stream pointer
                    ldx       stk_freopen_mode,s ; load mode string pointer
                    ldu       stk_freopen_path,s ; load pathname pointer
                    lbsr      openit    ; reopen the path using the supplied mode string
                    bmi       open1     ; return NULL when the low-level open helper failed
                    ldu       stk_freopen_stream,s ; reuse caller's FILE object
                    ldx       stk_freopen_mode,s ; reload mode string pointer for FILE setup
                    lbsr      setiob    ; reinitialize the existing FILE structure for the reopened path
                    puls      u,pc      ; restore U and return FILE pointer

* input:
*   d = path number
*   x = mode string
*   u = FILE * to reuse, or 0 for automatic allocation
* output:
*   d = FILE * or 0
setiob
stk_setiob_path     equ       0         ; saved OS-9 path number after PSHS D
                    pshs      d         ; preserve path number while finding/configuring FILE
                    cmpu      #0        ; did caller supply a FILE pointer?
                    bne       setiob3   ; skip the FILE-slot search when the caller supplied one explicitly
                    leau      __iob+FILE_USER_OFFSET,y ; start at first non-stdio FILE entry
                    lda       #FILE_USER_COUNT ; number of dynamic FILE entries to scan
setiob1
                    ldb       FILE_FLAG+1,u ; load low byte of FILE flags
                    andb      #_READ+_WRITE ; keep only active read/write state bits
                    beq       setiob3   ; stop when a free FILE slot is found
                    leau      FILE_SIZE,u ; advance to next FILE entry in the table
                    deca                ; count one scanned FILE slot
                    bne       setiob1   ; continue searching until all dynamic slots have been checked
                    ldd       #E_PthFul ; no FILE/path table entries remain
                    std       _errno,y  ; report EMFILE when no FILE slots remain
                    clra                ; return NULL high byte
                    clrb                ; return NULL low byte
                    puls      x,pc      ; discard saved path and return NULL

setiob3
                    puls      d         ; restore OS-9 path number
                    std       FILE_FD,u ; record the OS-9 path number in the FILE entry
                    ldd       1,x       ; inspect second and third mode characters
                    tsta                ; is there a second mode character?
                    beq       setiob5   ; branch when the mode string is only one character long
                    cmpa      #'+
                    beq       setiob4   ; handle modes like r+ and w+ as read/write
                    cmpb      #'+
                    bne       setiob5   ; treat one-character modes separately
setiob4
                    ldb       #_READ+_WRITE ; mark stream readable and writable
                    bra       setiob8   ; merge computed mode into FILE flags

setiob5
                    ldb       ,x        ; inspect first mode character
                    cmpb      #'r
                    beq       setiob6   ; mark read-only streams as input
                    cmpb      #'d
                    bne       setiob7   ; treat all other recognized modes as write-only here
setiob6
                    ldb       #_READ    ; mark stream readable
                    bra       setiob8   ; merge computed mode into FILE flags

setiob7
                    cmpb      #'w       ; writable modes start with 'w'
                    beq       setiob7a
                    cmpb      #'a       ; ... or 'a' (append)
                    beq       setiob7a
                    ldd       #E_BMode  ; unsupported mode string
                    std       _errno,y  ; report EINVAL for an unsupported mode string
                    clra                ; return NULL high byte
                    clrb                ; return NULL low byte
                    rts                 ; reject the bad mode so fdopen() yields NULL
setiob7a
                    ldb       #_WRITE   ; mark stream writable
setiob8
                    orb       FILE_FLAG+1,u ; preserve existing low-byte FILE flags
                    stb       FILE_FLAG+1,u ; store updated low-byte FILE flags
                    ldb       ,x        ; inspect first mode character for append semantics
                    cmpb      #'a
                    bne       setiob8a  ; only append modes need the sticky append flag
                    lda       FILE_FLAG,u ; load high byte of FILE flags
                    ora       #_APPEND_HIGH ; remember that writes must always target EOF
                    sta       FILE_FLAG,u ; store updated high-byte flags
setiob8a
                    ldd       FILE_BASE,u ; load the buffer base address
                    addd      FILE_BUFSIZ,u ; compute buffer end address
                    std       FILE_PTR,u ; initialize current pointer to buffer end
                    std       FILE_END,u ; initialize end pointer to buffer end
                    tfr       u,d       ; return FILE structure pointer
                    rts                 ; return to caller

* input:
*   x = *mode
*   u = *filename
* output:
*   d = path number or -1
openit
stk_openit_flags    equ       0         ; accumulated low-level access flags after PSHS D,U
stk_openit_path     equ       2         ; pathname pointer after PSHS D,U
                    clra                ; initialize access flags high byte
                    clrb                ; initialize access flags low byte
                    pshs      d,u       ; save access flags and pathname pointer
                    ldd       1,x       ; inspect second and third mode characters
                    tsta                ; is there a second mode character?
                    beq       openit4   ; branch when the mode string is only one character long
                    cmpa      #'x
                    bne       openit2   ; handle exclusive-create modifiers separately
                    cmpb      #'+
                    bne       openit1   ; choose create-only flags for plain x mode
                    ldd       #FAM_UPDATE|S_IEXEC ; mark exclusive create/update mode
                    bra       openit3   ; save computed access flags

openit1
                    ldd       #S_IEXEC  ; mark exclusive create/write mode
                    bra       openit3   ; save computed access flags

openit2
                    cmpa      #'+
                    bne       openit9   ; reject unsupported mode modifiers
                    ldd       #FAM_UPDATE ; read/write update mode
openit3
                    std       stk_openit_flags,s ; update accumulated access flags

openit4
                    ldb       ,x        ; inspect first mode character
                    cmpb      #'r
                    bne       openit5   ; branch when the mode is not read-only
                    ldd       stk_openit_flags,s ; load accumulated access flags
                    orb       #FAM_READ ; add OS-9 read access to the open flags
                    bra       openit11  ; open existing file with computed flags

openit5
                    cmpb      #'a
                    bne       openit6   ; branch when the mode is not append
                    ldd       stk_openit_flags,s ; load accumulated access flags
                    orb       #FAM_WRITE ; add OS-9 write access for append mode
                    pshs      d         ; pass access mode to _open
                    pshs      u         ; pass pathname to _open
                    lbsr      _open     ; try opening the file before seeking to the end
                    leas      4,s       ; discard _open arguments
                    std       stk_openit_path,s ; keep returned path number across EOF seek
                    cmpd      #-1       ; compare D against immediate value -1
                    beq       openit7   ; fall back to create when append-open failed
                    ldd       #SEEK_END ; seek relative to end-of-file
                    pshs      d         ; pass whence to _lseek
                    clra                ; zero high byte of 32-bit offset
                    clrb                ; zero low byte of 32-bit offset
                    pshs      d         ; pass low word of zero offset
                    pshs      d         ; pass high word of zero offset
                    ldd       stk_openit_path+6,s ; whence and long offset shift saved path by six bytes
                    pshs      d         ; pass path number to _lseek
                    leax      _flacc,y  ; provide hidden long return slot for _lseek
                    pshs      x         ; stage hidden return pointer
                    lbsr      _lseek    ; seek to end-of-file so subsequent writes append
                    leas      10,s      ; discard _lseek arguments
                    ldd       stk_openit_path,s ; recover the path number after the seek
                    bra       openit13  ; return opened append path

openit6
                    cmpb      #'w
                    bne       openit8   ; branch when the mode is neither append nor write
openit7
                    ldd       stk_openit_flags,s ; load accumulated access flags
                    orb       #FAM_WRITE ; add OS-9 write access for create/truncate modes
                    cmpb      #FAM_UPDATE ; detect update-mode create such as "w+"
                    bne       openit7a  ; plain write mode can continue to use creat()
                    tfr       d,x       ; preserve the read/write mode word for create()
                    ldd       #PMODE    ; use stdio's default create permissions
                    pshs      d         ; stage creation permissions
                    tfr       x,d       ; restore access mode after staging permissions
                    pshs      d         ; stage access mode for create(path, mode, perm)
                    pshs      u         ; stage pathname
                    lbsr      _create   ; create/truncate with an actual read/write path
                    leas      6,s       ; discard _create arguments
                    bra       openit13  ; return created path directly
openit7a
                    pshs      d         ; pass access mode to creat()
                    pshs      u         ; pass pathname to creat()
                    lbsr      _creat    ; create or truncate the target file
                    bra       openit12  ; discard creat() arguments and return

openit8
                    cmpb      #'d
                    beq       openit10  ; handle direct-access mode separately
openit9
                    ldd       #E_BMode  ; unsupported mode string
                    std       _errno,y  ; report EINVAL for an unsupported mode string
                    ldd       #-1       ; return error sentinel
                    bra       openit13  ; release openit frame and return failure

openit10
                    ldd       stk_openit_flags,s ; load accumulated access flags
                    orb       #FAM_DIR|FAM_READ ; request directory/direct read open
openit11
                    pshs      d         ; pass access mode to _open
                    pshs      u         ; pass pathname to _open
                    lbsr      _open     ; issue the final OS-9 open call with the computed flags
openit12
                    leas      4,s       ; discard _open/_creat arguments
openit13
                    leas      4,s       ; discard the saved flags and pathname pointer before returning
                    rts                 ; return to caller

                    endsect   ;         end current section
