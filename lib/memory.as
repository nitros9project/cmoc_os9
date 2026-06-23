_malloc             EXPORT    ;         export allocator entry point
_free               EXPORT    ;         export free entry point

_sbrk               EXTERNAL  ;         heap-growth helper

                    section   bss       ; begin uninitialized data section

; MALLOC IMPLEMENTATION NOTES:
; This malloc/free implementation uses a classic linked-list free-list strategy:
; 1. All allocated and free blocks begin with a 4-byte header: next-pointer (2 bytes) + size (2 bytes)
; 2. The free list is a circular linked list of free blocks, maintained in address order
; 3. Sizes are stored in "header units" (4 bytes each) rather than bytes for faster arithmetic
; 4. malloc searches the free list for a suitable block, splitting oversized blocks
; 5. free coalesces adjacent free blocks to reduce fragmentation
; 6. _base is a sentinel block (size 0) that anchors the circular free list
; 7. _allocp tracks where the last search started to improve locality
;
; BLOCK HEADER STRUCTURE:
;   +-------+-------+
;   | byte 0| byte 1|
;   +-------+-------+
;   | next-pointer  |  (16-bit address of next block)
;   +-------+-------+
;   | size (units)  |  (16-bit size in 4-byte header units)
;   +-------+-------+
;   | payload...    |  (user data starts at offset +4)
;   +-------+-------+
;
; FREE LIST EXAMPLE (circular linked list in address order):
;   _allocp points to last-searched position for faster reuse
;
;   _base (sentinel)                malloc() returns payload, not header
;   |                               |
;   v                               v
;   +---+---+        +---+---+      +---+---+      +---+---+
;   | * | 0 |------->| * | 8 |---->| H | 12|--->| * | 20 |--+
;   +---+---+        +---+---+      +---+---+      +---+---+  |
;   size=0           size=8      (allocated)    size=20      |
;   (circular)       units       payload here    units        |
;                    FREE        addr+4                       |
;                                                             |
;   +----------------------------------------------------------+
;                              ^
;                              | (circular link back to _base)

_base               rmb       4         ; sentinel block header: next pointer + block size
_allocp             rmb       2         ; current search position in free list

                    endsect   ;         end uninitialized data section

                    section   code      ; begin code section

; MALLOC(size): Allocate requested number of bytes from heap
; Input:  Stack parameter = size in bytes
; Output: D register = pointer to allocated block, or 0 (NULL) if allocation failed
; This function implements first-fit allocation with block splitting:
; 1. Convert requested size in bytes to header units (size+3)/4 and add 1 for header
; 2. Search free list starting from last allocation point (_allocp)
; 3. First block >= requested size is allocated, with excess split into new free block
; 4. If free list exhausted, call morecore to grow heap, then retry
;
; MALLOC EXAMPLE: Allocate 12 bytes (3 header units) from 32-byte (8 unit) free block
;
;   BEFORE: Free list has one 8-unit block at address 0x1000
;           +-------+-------+-------+-------+-------+-------+-------+-------+
;           | next->| size=8|   payload (24 bytes available)                 |
;           +-------+-------+-------+-------+-------+-------+-------+-------+
;           0x1000  0x1002  0x1004
;
;   malloc(12) requests 3 units, total needed: 1 (header) + 3 (data) = 4 units
;   8 units - 4 units = 4 units remain
;
;   AFTER: Original block becomes allocated, remainder stays free
;           +-------+-------+-------+-------+
;           | next->| size=4|  user payload  |  <-- malloc() returns 0x1004
;           +-------+-------+-------+-------+
;           0x1000  0x1002  0x1004
;
;           +-------+-------+-------+-------+-------+-------+-------+-------+
;           | next->| size=4|  free space (16 bytes available)              |
;           +-------+-------+-------+-------+-------+-------+-------+-------+
;           0x1010  0x1012  0x1014  (linked in free list)
;
_malloc:
stk_malloc_units    equ       0         ; local requested block size in header units
stk_malloc_saved_u  equ       2         ; saved U register after pshs d,u
stk_malloc_ret      equ       4         ; caller return address after pshs d,u
stk_malloc_size     equ       6         ; requested allocation size in bytes
                    pshs      d,u       ; reserve one word of local storage and preserve U
                    ; STEP 1: Convert requested byte size to header units (each unit = 4 bytes)
                    ; Formula: units = (bytes + 3) / 4, then add 1 for the header itself
                    ldd       stk_malloc_size,s ; load requested allocation size in bytes
                    addd      #3        ; round up for header alignment before dividing by 4
                    lsra                ; divide byte count by header size high bit step 1
                    rorb                ; divide byte count by header size low bit step 1
                    lsra                ; divide byte count by header size high bit step 2
                    rorb                ; divide byte count by header size low bit step 2
                    addd      #1        ; add one header unit for the block header itself
                    std       stk_malloc_units,s ; save required unit count on the stack
                    ; STEP 2: Initialize the free list if this is the first allocation
                    ldx       _allocp,y ; load current free-list search pointer
                    bne       malloc1   ; skip initialization once the free list exists
                    ; First-time init: set up sentinel block pointing to itself
                    leax      _base,y   ; point X at the sentinel header
                    stx       _allocp,y ; initialize allocp to the sentinel header
                    stx       _base,y   ; make sentinel next pointer refer to itself (circular)
                    clra                ; clear high byte for zero-sized sentinel block
                    clrb                ; clear low byte for zero-sized sentinel block
                    std       _base+2,y ; set sentinel block size to zero

malloc1             ; STEP 3: Search free list starting at _allocp
                    ; Structure of each free block: [next-ptr: 2 bytes][size: 2 bytes][payload...]
                    ldu       ,x        ; load candidate block pointer from q->ptr
                    bra       malloc3   ; enter common size-check path

malloc2             ; Candidate block was too small, advance to next block
                    tfr       u,x       ; advance q to the previous candidate block
                    ldu       ,u        ; advance p to the next free block
malloc3             ldd       2,u       ; load candidate block size in header units
                    cmpd      stk_malloc_units,s ; compare candidate size against requested units
                    blo       malloc6   ; keep searching when the block is too small
                    bne       malloc4   ; split the block when it is larger than requested
                    ; EXACT FIT: Use entire block without splitting
                    ldd       ,u        ; exact fit: load p->ptr
                    std       ,x        ; unlink p by storing q->ptr = p->ptr
                    bra       malloc5   ; finish exact-fit allocation

malloc4             ; BLOCK TOO LARGE: Split block into allocated piece and new free block
                    ldd       2,u       ; load candidate block size
                    subd      stk_malloc_units,s ; subtract requested units from the free block
                    std       2,u       ; store reduced free-block size back in original block
                    ; Convert reduced unit count to bytes for pointer arithmetic
                    aslb                ; scale remaining units to bytes low step 1
                    rola                ; scale remaining units to bytes high step 1
                    aslb                ; scale remaining units to bytes low step 2
                    rola                ; scale remaining units to bytes high step 2
                    leau      d,u       ; move U to the tail fragment that will be returned
                    ldd       stk_malloc_units,s ; reload requested unit count
                    std       2,u       ; store requested size into the allocated block header
malloc5             ; Return the allocated block to caller
                    stx       _allocp,y ; remember where the next free-list scan should start
                    leau      4,u       ; return pointer to payload just past the header
                    tfr       u,d       ; place payload pointer in D for the caller
                    bra       malloc7   ; share common success return path
malloc6             ; Free list exhausted: either get more memory or declare failure
                    cmpu      _allocp,y ; test whether the scan wrapped back to allocp
                    bne       malloc2   ; continue scanning free blocks until the list wraps
                    ; Scan wrapped without finding suitable block, need more heap memory
                    lbsr      morecore  ; ask the system for more heap space
                    bne       malloc2   ; retry allocation if morecore returned a new block
                    ; Heap growth failed; return NULL to indicate allocation failure
                    clra                ; return NULL when the heap could not grow
                    clrb                ; return NULL when the heap could not grow
malloc7             leas      2,s       ; discard local requested-unit storage
                    puls      u,pc      ; restore U and return pointer or NULL

_free:
stk_free_prev       equ       0         ; local previous free-list block pointer
stk_free_saved_u    equ       2         ; saved U register after pshs d,u
stk_free_ret        equ       4         ; caller return address after pshs d,u
stk_free_payload    equ       6         ; payload pointer supplied by caller
                    pshs      d,u       ; reserve one word of local storage and preserve U
                    ; FREE(pointer): Return allocated block to heap and coalesce with adjacent free blocks
                    ; Input:  Stack parameter = payload pointer returned by malloc
                    ; Process:
                    ; 1. Back up from payload pointer to find block header (4 bytes back)
                    ; 2. Find insertion point in free list (maintaining address order)
                    ; 3. Coalesce with next block if they are adjacent
                    ; 4. Coalesce with previous block if they are adjacent
                    ; This reduces fragmentation and enables larger future allocations
;
; FREE & COALESCING EXAMPLE:
;
;   BEFORE: Free list has blocks at 0x1000(size=4) and 0x1020(size=4), with gap between them
;           Freeing block at 0x1010(size=4)
;
;           FREE BLOCK (q)    GAP         FREE BLOCK (q->ptr)
;           0x1000            0x101C      0x1020
;           +---+---+         +---+---+
;           |*  | 4 |         | * | 4 |
;           +---+---+         +---+---+
;           size=4            size=4
;           at 0x1000         at 0x1020
;
;           Freed payload at 0x1014 (header at 0x1010, size=4)
;
;   STEP 1: Back up 4 bytes from 0x1014 to find header at 0x1010
;   STEP 2: Find insertion point between 0x1000 and 0x1020 (address order)
;   STEP 3: Check forward adjacency: does 0x1010 + size touch 0x1020?
;           0x1010 + 4*4 = 0x1020? YES! Merge with next block
;   STEP 4: Check backward adjacency: does 0x1000 + size touch 0x1010?
;           0x1000 + 4*4 = 0x1020 (not 0x1010) NO! Don't merge with prev
;
;   AFTER FORWARD COALESCE: Freed block and q->ptr are merged
;           +---+---+         +---+---+
;           | *---->|         | * | 8 |  (merged size = 4 + 4)
;           +---+---+         +---+---+
;           0x1000            0x1010
;           size=4
;
;           One 8-unit free block now available instead of separate 4+4 blocks!
;
                    ldu       stk_free_payload,s ; load payload pointer supplied by the caller
                    leau      -4,u      ; back up to the block header
                    ldx       _allocp,y ; start scanning from the current free-list position
                    bra       free3     ; enter the insertion-search loop
free1               cmpx      ,x        ; test whether q >= q->ptr, which marks list wrap
                    blo       free2     ; continue normally when no wrap occurs here
                    cmpu      stk_free_prev,s ; test whether freed block is above q in wrapped list
                    bhi       free4     ; insert here when p lies above the upper segment
                    cmpu      ,x        ; test whether freed block is below q->ptr
                    blo       free4     ; insert here when p lies below the lower segment
free2               ldx       ,x        ; advance q to q->ptr
free3               stx       stk_free_prev,s ; keep q in local storage for wrap comparisons
                    cmpu      stk_free_prev,s ; test whether p is still at or before q
                    bls       free1     ; keep searching until p is greater than q
                    cmpu      ,x        ; test whether p is beyond q->ptr
                    bhs       free1     ; keep searching until p falls before q->ptr

free4               ; Found insertion point: p falls between q and q->ptr
                    ; Check if freed block (p) is adjacent to next block (q->ptr)
                    pshs      u         ; keep p on the stack while computing p + p->size
                    ldd       2,u       ; load size of block being freed
                    ; Convert size in units to bytes for address arithmetic
                    aslb                ; scale block size to bytes low step 1
                    rola                ; scale block size to bytes high step 1
                    aslb                ; scale block size to bytes low step 2
                    rola                ; scale block size to bytes high step 2
                    addd      ,s++      ; compute address just past freed block (p + p->size)
                    cmpd      ,x        ; test whether freed block touches q->ptr
                    bne       free5     ; skip forward coalescing when blocks are separate
                    ; FORWARD COALESCE: freed block (p) is adjacent to q->ptr, merge them
                    pshs      x         ; preserve q while chasing q->ptr
                    ldx       ,x        ; load q->ptr (the next block)
                    ldd       2,x       ; load size of block after p
                    puls      x         ; restore q
                    addd      2,u       ; grow freed block by successor block size
                    std       2,u       ; store merged size in p
                    ldd       [,x]      ; load successor's next pointer
                    bra       free6     ; share next-pointer store path

free5               ; No forward coalesce: use q->ptr as p's next pointer unchanged
                    ldd       ,x        ; load q->ptr when no forward merge occurs
free6               std       ,u        ; store p->ptr (linking p into free list)
                    ; Check if freed block (p) is adjacent to previous block (q)
                    ldd       2,x       ; load size of predecessor block q
                    ; Convert q's size in units to bytes
                    aslb                ; scale q size to bytes low step 1
                    rola                ; scale q size to bytes high step 1
                    aslb                ; scale q size to bytes low step 2
                    rola                ; scale q size to bytes high step 2
                    addd      stk_free_prev,s ; compute address just past q (q + q->size)
                    pshs      d         ; keep q + q->size for adjacency test
                    cmpu      ,s++      ; test whether q ends exactly where p begins
                    bne       free7     ; skip backward coalescing when blocks are separate
                    ; BACKWARD COALESCE: q is adjacent to freed block (p), merge them
                    ldd       2,x       ; load q block size
                    addd      2,u       ; extend q by size of p
                    std       2,x       ; store merged size back into q
                    ldd       ,u        ; load p->ptr (p's successor)
                    std       ,x        ; link q directly to p->ptr, bypassing p
                    bra       free8     ; finish with merged predecessor block

free7               ; No backward coalesce: insert p directly after q
                    stu       ,x        ; insert p directly after q
free8               stx       _allocp,y ; restart future searches from q
                    lbra      malloc7   ; reuse common epilogue to restore stack and return

morecore
stk_morecore_ret    equ       0         ; return address from malloc's lbsr morecore
stk_morecore_units  equ       2         ; malloc local requested unit count below return address
                    ; MORECORE: Expand heap when malloc runs out of free blocks
                    ; Called by malloc when free list is exhausted
                    ; Requests memory from OS via sbrk, initializes header, and adds to free list
                    ldd       stk_morecore_units,s ; load requested unit count
                    addd      #255      ; round up to the next 256-unit boundary (faster allocation)
                    clrb                ; low byte zero completes the round-up divide
                    pshs      d         ; save rounded unit count
                    ; Convert rounded unit count to bytes for sbrk system call
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

                    ; sbrk succeeded: initialize new block header and add to free list
                    exg       d,u       ; swap new block address into U and unit count into D
                    std       2,u       ; store rounded unit count in the new block header
                    leau      4,u       ; point U at payload just past the new header
                    pshs      u         ; stage payload pointer as argument to free
                    lbsr      _free     ; insert the new block into the free list
                    puls      u         ; discard staged payload pointer
                    ldu       _allocp,y ; load allocp so caller can see nonzero success
an_rts              rts                 ; return with U/D describing success or failure

                    endsect   ;         end code section
