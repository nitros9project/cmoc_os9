_malloc             EXPORT              ; export allocator entry point
_free               EXPORT              ; export free entry point

_sbrk               EXTERNAL            ; heap-growth helper

                    section   bss       ; begin uninitialized data section

_base               rmb       4         ; sentinel block header: next pointer + block size
_allocp             rmb       2         ; current search position in free list

                    endsect             ; end uninitialized data section

                    section   code      ; begin code section

_malloc
                    pshs      d,u       ; reserve one word of local storage and preserve U
                    ldd       6,s       ; load requested allocation size in bytes
                    addd      #3        ; round up for header alignment before dividing by 4
                    lsra                ; divide byte count by header size high bit step 1
                    rorb                ; divide byte count by header size low bit step 1
                    lsra                ; divide byte count by header size high bit step 2
                    rorb                ; divide byte count by header size low bit step 2
                    addd      #1        ; add one header unit for the block header itself
                    std       ,s        ; save required unit count on the stack
                    ldx       _allocp,y ; load current free-list search pointer
                    bne       malloc1   ; skip initialization once the free list exists
                    leax      _base,y   ; point X at the sentinel header
                    stx       _allocp,y ; initialize allocp to the sentinel header
                    stx       _base,y   ; make sentinel next pointer refer to itself
                    clra                ; clear high byte for zero-sized sentinel block
                    clrb                ; clear low byte for zero-sized sentinel block
                    std       _base+2,y ; set sentinel block size to zero

malloc1             ldu       ,x        ; load candidate block pointer from q->ptr
                    bra       malloc3   ; enter common size-check path

malloc2             tfr       u,x       ; advance q to the previous candidate block
                    ldu       ,u        ; advance p to the next free block
malloc3             ldd       2,u       ; load candidate block size in header units
                    cmpd      ,s        ; compare candidate size against requested units
                    blo       malloc6   ; keep searching when the block is too small
                    bne       malloc4   ; split the block when it is larger than requested
                    ldd       ,u        ; exact fit: load p->ptr
                    std       ,x        ; unlink p by storing q->ptr = p->ptr
                    bra       malloc5   ; finish exact-fit allocation

malloc4             ldd       2,u       ; load candidate block size
                    subd      ,s        ; subtract requested units from the free block
                    std       2,u       ; store reduced free-block size
                    aslb                ; scale remaining units to bytes low step 1
                    rola                ; scale remaining units to bytes high step 1
                    aslb                ; scale remaining units to bytes low step 2
                    rola                ; scale remaining units to bytes high step 2
                    leau      d,u       ; move U to the tail fragment that will be returned
                    ldd       ,s        ; reload requested unit count
                    std       2,u       ; store requested size into the allocated header
malloc5             stx       _allocp,y ; remember where the next free-list scan should start
                    leau      4,u       ; return pointer to payload just past the header
                    tfr       u,d       ; place payload pointer in D for the caller
                    bra       malloc7   ; share common success return path
malloc6             cmpu      _allocp,y ; test whether the scan wrapped back to allocp
                    bne       malloc2   ; continue scanning free blocks until the list wraps
                    lbsr      morecore  ; ask the system for more heap space
                    bne       malloc2   ; retry allocation if morecore returned a new block
                    clra                ; return NULL when the heap could not grow
                    clrb                ; return NULL when the heap could not grow
malloc7             leas      2,s       ; discard local requested-unit storage
                    puls      u,pc      ; restore U and return pointer or NULL

_free
                    pshs      d,u       ; reserve one word of local storage and preserve U
                    ldu       6,s       ; load payload pointer supplied by the caller
                    leau      -4,u      ; back up to the block header
                    ldx       _allocp,y ; start scanning from the current free-list position
                    bra       free3     ; enter the insertion-search loop
free1               cmpx      ,x        ; test whether q >= q->ptr, which marks list wrap
                    blo       free2     ; continue normally when no wrap occurs here
                    cmpu      ,s        ; test whether freed block is above q in wrapped list
                    bhi       free4     ; insert here when p lies above the upper segment
                    cmpu      ,x        ; test whether freed block is below q->ptr
                    blo       free4     ; insert here when p lies below the lower segment
free2               ldx       ,x        ; advance q to q->ptr
free3               stx       ,s        ; keep q in local storage for wrap comparisons
                    cmpu      ,s        ; test whether p is still at or before q
                    bls       free1     ; keep searching until p is greater than q
                    cmpu      ,x        ; test whether p is beyond q->ptr
                    bhs       free1     ; keep searching until p falls before q->ptr

free4               pshs      u         ; keep p on the stack while computing p + p->size
                    ldd       2,u       ; load size of block being freed
                    aslb                ; scale block size to bytes low step 1
                    rola                ; scale block size to bytes high step 1
                    aslb                ; scale block size to bytes low step 2
                    rola                ; scale block size to bytes high step 2
                    addd      ,s++      ; compute address just past freed block
                    cmpd      ,x        ; test whether freed block touches q->ptr
                    bne       free5     ; skip forward coalescing when blocks are separate
                    pshs      x         ; preserve q while chasing q->ptr
                    ldx       ,x        ; load q->ptr
                    ldd       2,x       ; load size of block after p
                    puls      x         ; restore q
                    addd      2,u       ; grow freed block by successor block size
                    std       2,u       ; store merged size in p
                    ldd       [,x]      ; load successor's next pointer
                    bra       free6     ; share next-pointer store path

free5               ldd       ,x        ; load q->ptr when no forward merge occurs
free6               std       ,u        ; store p->ptr
                    ldd       2,x       ; load size of predecessor block q
                    aslb                ; scale q size to bytes low step 1
                    rola                ; scale q size to bytes high step 1
                    aslb                ; scale q size to bytes low step 2
                    rola                ; scale q size to bytes high step 2
                    addd      ,s        ; compute address just past q
                    pshs      d         ; keep q + q->size for adjacency test
                    cmpu      ,s++      ; test whether q ends exactly where p begins
                    bne       free7     ; skip backward coalescing when blocks are separate
                    ldd       2,x       ; load q block size
                    addd      2,u       ; extend q by size of p
                    std       2,x       ; store merged size back into q
                    ldd       ,u        ; load p->ptr
                    std       ,x        ; link q directly to p->ptr
                    bra       free8     ; finish with merged predecessor block

free7               stu       ,x        ; insert p directly after q
free8               stx       _allocp,y ; restart future searches from q
                    lbra      malloc7   ; reuse common epilogue to restore stack and return

morecore
                    ldd       2,s       ; load requested unit count
                    addd      #255      ; round up to the next 256-unit boundary
                    clrb                ; low byte zero completes the round-up divide
                    pshs      d         ; save rounded unit count
                    aslb                ; scale rounded units to bytes low step 1
                    rola                ; scale rounded units to bytes high step 1
                    aslb                ; scale rounded units to bytes low step 2
                    rola                ; scale rounded units to bytes high step 2
                    pshs      d         ; pass byte count to sbrk
                    lbsr      _sbrk     ; request more heap memory from the system
                    leas      2,s       ; discard byte-count argument
                    puls      u         ; recover rounded unit count into U
                    cmpd      #-1       ; test for sbrk failure
                    beq       an_rts    ; return failure marker unchanged when heap growth failed

                    exg       d,u       ; swap new block address into U and unit count into D
                    std       2,u       ; store rounded unit count in the new block header
                    leau      4,u       ; point U at payload just past the new header
                    pshs      u         ; stage payload pointer as argument to free
                    lbsr      _free     ; insert the new block into the free list
                    puls      u         ; discard staged payload pointer
                    ldu       _allocp,y ; load allocp so caller can see nonzero success
an_rts              rts                 ; return with U/D describing success or failure

                    endsect             ; end code section
