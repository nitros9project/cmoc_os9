                    section   code      ; begin code section

_READ               equ       1         ; define constant as 1
_WRITE              equ       2         ; define constant as 2
_APPEND             equ       2         ; high-byte FILE append-mode flag

_fdopen             EXPORT              ; export this symbol
_fopen              EXPORT              ; export this symbol
_freopen            EXPORT              ; export this symbol

__iob               EXTERN              ; import external symbol
_errno              EXTERN              ; import external symbol
_fclose             EXTERN              ; import external symbol
_open               EXTERN              ; import external symbol
_creat              EXTERN              ; import external symbol
_create             EXTERN              ; import external symbol
_lseek              EXTERN              ; import external symbol
_flacc              EXTERN              ; import shared long return slot

* stack:
*   0,s = return address
*   2,s = file descriptor
*   4,s = mode
_fdopen
                    pshs      u         ; save U on the hardware stack
                    ldu       #0        ; load U from immediate value 0
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldd       4,s       ; load D from stack-relative value 4,s
                    lbsr      setiob    ; bind the existing file descriptor to a FILE structure
                    puls      u,pc      ; restore registers and return

* stack:
*   0,s = return address
*   2,s = pathname pointer
*   4,s = mode
_fopen
                    pshs      u         ; save U on the hardware stack
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldu       4,s       ; load U from stack-relative value 4,s
                    lbsr      openit    ; open or create the path according to the mode string
                    bmi       open1     ; return NULL when the low-level open helper failed
                    ldu       #0        ; load U from immediate value 0
                    ldx       6,s       ; load X from stack-relative value 6,s
                    lbsr      setiob    ; allocate or find a free FILE entry for the new path
                    puls      u,pc      ; restore registers and return
open1
                    clra                ; clear A
                    clrb                ; clear B
                    puls      u,pc      ; restore registers and return

* stack:
*   0,s = return address
*   2,s = pathname pointer
*   4,s = mode
*   6,s = FILE *stream
_freopen
                    pshs      u         ; save U on the hardware stack
                    ldd       8,s       ; load D from stack-relative value 8,s
                    pshs      d         ; save D on the hardware stack
                    lbsr      _fclose   ; close the existing stream before reopening it on a new path
                    leas      2,s       ; adjust S using 2,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    ldu       4,s       ; load U from stack-relative value 4,s
                    lbsr      openit    ; reopen the path using the supplied mode string
                    bmi       open1     ; return NULL when the low-level open helper failed
                    ldu       8,s       ; load U from stack-relative value 8,s
                    ldx       6,s       ; load X from stack-relative value 6,s
                    lbsr      setiob    ; reinitialize the existing FILE structure for the reopened path
                    puls      u,pc      ; restore registers and return

* input:
*   d = path number
*   x = *mode
*   u = FILE * or 0
* output:
*   d = FILE * or 0
setiob
                    pshs      d         ; save D on the hardware stack
                    cmpu      #0        ; compare U against immediate value 0
                    bne       setiob3   ; skip the FILE-slot search when the caller supplied one explicitly
                    leau      __iob+39,y ; start at the last FILE entry in the static I/O table
                    lda       #13       ; load A from immediate value 13
setiob1
                    ldb       7,u       ; load B from indexed value 7,u
                    andb      #_READ+_WRITE ; AND B with immediate value _READ+_WRITE
                    beq       setiob3   ; stop when a free FILE slot is found
                    leau      13,u      ; move to the previous FILE entry in the table
                    deca                ; decrement A
                    bne       setiob1   ; continue searching until all 13 slots have been checked
                    ldd       #$00C8    ; load D from immediate value $00C8
                    std       _errno,y  ; report EMFILE when no FILE slots remain
                    clra                ; clear A
                    clrb                ; clear B
                    puls      x,pc      ; restore registers and return

setiob3
                    puls      d         ; restore D from the hardware stack
                    std       8,u       ; record the OS-9 path number in the FILE entry
                    ldd       1,x       ; load D from indexed value 1,x
                    tsta                ; test A and update condition codes
                    beq       setiob5   ; branch when the mode string is only one character long
                    cmpa      #'+
                    beq       setiob4   ; handle modes like r+ and w+ as read/write
                    cmpb      #'+
                    bne       setiob5   ; treat one-character modes separately
setiob4
                    ldb       #_READ+_WRITE ; load B from immediate value _READ+_WRITE
                    bra       setiob8   ; branch unconditionally to setiob8

setiob5
                    ldb       ,x        ; load B from memory pointed to by X
                    cmpb      #'r
                    beq       setiob6   ; mark read-only streams as input
                    cmpb      #'d
                    bne       setiob7   ; treat all other recognized modes as write-only here
setiob6
                    ldb       #_READ    ; load B from immediate value _READ
                    bra       setiob8   ; branch unconditionally to setiob8

setiob7
                    ldb       #_WRITE   ; load B from immediate value _WRITE
setiob8
                    orb       7,u       ; merge the new mode bits into the FILE entry flags
                    stb       7,u       ; store the updated mode flags back into the FILE entry
                    ldb       ,x        ; inspect first mode character for append semantics
                    cmpb      #'a
                    bne       setiob8a  ; only append modes need the sticky append flag
                    lda       6,u       ; load high byte of FILE flags
                    ora       #_APPEND  ; remember that writes must always target EOF
                    sta       6,u       ; store updated high-byte flags
setiob8a
                    ldd       2,u       ; load the buffer base address from the FILE entry
                    addd      11,u      ; advance to the logical end of the FILE buffer
                    std       ,u        ; initialize the current pointer to the buffer end
                    std       4,u       ; initialize the alternate current pointer field to the same position
                    tfr       u,d       ; return the FILE structure pointer in D
                    rts                 ; return to caller

* input:
*   x = *mode
*   u = *filename
* output:
*   d = path number or -1
openit
                    clra                ; clear A
                    clrb                ; clear B
                    pshs      d,u       ; save the initial open/create flags and pathname pointer on the stack
                    ldd       1,x       ; load D from indexed value 1,x
                    tsta                ; test A and update condition codes
                    beq       openit4   ; branch when the mode string is only one character long
                    cmpa      #'x
                    bne       openit2   ; handle exclusive-create modifiers separately
                    cmpb      #'+
                    bne       openit1   ; choose create-only flags for plain x mode
                    ldd       #$0007    ; load D from immediate value $0007
                    bra       openit3   ; branch unconditionally to openit3

openit1
                    ldd       #$0004    ; load D from immediate value $0004
                    bra       openit3   ; branch unconditionally to openit3

openit2
                    cmpa      #'+
                    bne       openit9   ; branch if not equal to openit9
                    ldd       #$0003    ; load D from immediate value $0003
openit3
                    std       ,s        ; update the saved open/create flags on the stack

openit4
                    ldb       ,x        ; load B from memory pointed to by X
                    cmpb      #'r
                    bne       openit5   ; branch when the mode is not read-only
                    ldd       ,s        ; load D from memory pointed to by S
                    orb       #1        ; add OS-9 read permission to the open flags
                    bra       openit11  ; branch unconditionally to openit11

openit5
                    cmpb      #'a
                    bne       openit6   ; branch when the mode is not append
                    ldd       ,s        ; load D from memory pointed to by S
                    orb       #$02      ; add OS-9 write permission for append mode
                    pshs      d         ; save D on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    lbsr      _open     ; try opening the file before seeking to the end
                    leas      4,s       ; adjust S using 4,s
                    std       2,s       ; keep the returned path number on the stack across the seek
                    cmpd      #-1       ; compare D against immediate value -1
                    beq       openit7   ; fall back to create when append-open failed
                    ldd       #2        ; load D from immediate value 2
                    pshs      d         ; save D on the hardware stack
                    clra                ; clear A
                    clrb                ; clear B
                    pshs      d         ; save D on the hardware stack
                    pshs      d         ; save D on the hardware stack
                    ldd       8,s       ; load D from stack-relative value 8,s
                    pshs      d         ; save D on the hardware stack
                    leax      _flacc,y  ; provide hidden long return slot for _lseek
                    pshs      x         ; stage hidden return pointer
                    lbsr      _lseek    ; seek to end-of-file so subsequent writes append
                    leas      10,s      ; adjust S using 10,s
                    ldd       2,s       ; recover the path number after the seek
                    bra       openit13  ; branch unconditionally to openit13

openit6
                    cmpb      #'w
                    bne       openit8   ; branch when the mode is neither append nor write
openit7
                    ldd       ,s        ; load D from memory pointed to by S
                    orb       #$02      ; add OS-9 write permission for create/truncate modes
                    cmpb      #$03      ; detect update-mode create such as "w+"
                    bne       openit7a  ; plain write mode can continue to use creat()
                    tfr       d,x       ; preserve the read/write mode word for create()
                    ldd       #$000B    ; use stdio's default PMODE (owner rw, public r)
                    pshs      d         ; stage creation permissions
                    tfr       x,d       ; restore access mode after staging permissions
                    pshs      d         ; stage access mode for create(path, mode, perm)
                    pshs      u         ; stage pathname
                    lbsr      _create   ; create/truncate with an actual read/write path
                    leas      6,s       ; discard staged _create arguments
                    bra       openit13  ; return created path directly
openit7a
                    pshs      d         ; save D on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    lbsr      _creat    ; create or truncate the target file
                    bra       openit12  ; branch unconditionally to openit12

openit8
                    cmpb      #'d
                    beq       openit10  ; handle direct-access mode separately
openit9
                    ldd       #$00CB    ; load D from immediate value $00CB
                    std       _errno,y  ; report EINVAL for an unsupported mode string
                    ldd       #-1       ; load D from immediate value -1
                    bra       openit13  ; branch unconditionally to openit13

openit10
                    ldd       ,s        ; load D from memory pointed to by S
                    orb       #$81      ; request direct-access open flags along with read permission
openit11
                    pshs      d         ; save D on the hardware stack
                    pshs      u         ; save U on the hardware stack
                    lbsr      _open     ; issue the final OS-9 open call with the computed flags
openit12
                    leas      4,s       ; adjust S using 4,s
openit13
                    leas      4,s       ; discard the saved flags and pathname pointer before returning
                    rts                 ; return to caller

                    endsect             ; end current section
