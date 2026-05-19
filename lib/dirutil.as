* Disassembly by Os9disasm of dirutil.r

                    use       ../include/fcntl.d ; shared file access constants

* class D external label equates

DIR_SIZE            equ       34        ; bytes allocated for DIR: fd + 32-byte entry buffer
DIR_FD              equ       0         ; DIR.dd_fd offset
DIR_BUF             equ       2         ; DIR.dd_buf offset
DIR_BUF_SIZE        equ       32        ; OS-9 directory entry size
DIR_NAME_OFF        equ       0         ; raw directory entry name starts at byte 0
DIR_ADDR_MID        equ       $001d     ; raw directory entry middle address byte
DIR_ADDR_LO         equ       $001e     ; raw directory entry low address word
DIRECT_ADDR         equ       0         ; struct direct.d_addr offset
DIRECT_NAME         equ       4         ; struct direct.d_name offset

                    section   bss       ; begin bss section

* Uninitialized data (class B)
dirent_result_addr  rmb       4         ; static struct direct.d_addr result
dirent_result_name  rmb       30        ; static struct direct.d_name result
* Initialized Data (class G)

                    endsect   ;         end current section

                    section   code      ; begin code section

_closedir           EXPORT    ;         export this symbol
_opendir            EXPORT    ;         export this symbol
_readdir            EXPORT    ;         export this symbol

_close              EXTERNAL  ;         import external symbol
_free               EXTERNAL  ;         import external symbol
_malloc             EXTERNAL  ;         import external symbol
_open               EXTERNAL  ;         import external symbol
_read               EXTERNAL  ;         import external symbol
_strhcpy            EXTERNAL  ;         import external symbol

* DIR layout used by this file:
*   DIR_FD       dd_fd   (path number)
*   DIR_BUF      dd_buf  (32-byte directory sector entry buffer)
*
* DIRECT/static result layout:
*   DIRECT_ADDR  d_addr
*   DIRECT_NAME  d_name[30]

_closedir:
stk_closedir_ret    equ       0         ; caller return address
stk_closedir_dirp   equ       2         ; DIR * argument
                    ldx       stk_closedir_dirp,s ; load DIR pointer
                    ldd       DIR_FD,x  ; fetch underlying directory path number
                    pshs      d,x       ; pass path to _close while preserving DIR pointer for _free
                    lbsr      _close    ; close underlying directory path
                    leas      2,s       ; discard _close path argument
                    lbsr      _free     ; free DIR allocation still on stack
                    puls      x,pc      ; discard preserved DIR pointer and return
_opendir:
stk_opendir_ret     equ       0         ; caller return address
stk_opendir_path    equ       2         ; pathname argument
stk_opendir_dirp    equ       0         ; temporary malloc argument/result slot after PSHS D
                    pshs      u         ; preserve caller U
                    ldd       #DIR_SIZE ; allocate one DIR object
                    pshs      d         ; pass allocation size to _malloc
                    lbsr      _malloc   ; allocate DIR structure
                    std       stk_opendir_dirp,s ; keep DIR pointer in temporary stack slot
                    beq       opendir_return ; return NULL when allocation failed
                    ldx       #FAM_DIR|FAM_READ ; open target as a readable directory
                    ldd       stk_opendir_path+4,s ; saved U and DIR slot shift pathname argument
* _open(path, mode): CMOC wrapper expects pathname first, mode second.
* Here D = pathname pointer from caller, X = mode flags for directory open.
* Push X first, then D, so _open sees:
*   2,s = pathname
*   4,s = mode
                    pshs      x         ; pass directory-open mode
                    pshs      d         ; pass pathname pointer
                    lbsr      _open     ; open directory path
                    leas      4,s       ; discard _open arguments
                    std       [stk_opendir_dirp,s] ; store path number into DIR.dd_fd
                    bge       opendir_return ; return DIR pointer when open succeeded
                    ldd       stk_opendir_dirp,s ; reload failed DIR allocation
                    lbsr      _free     ; release allocation after open failure
                    clra                ; return NULL high byte
                    clrb                ; return NULL low byte
                    std       stk_opendir_dirp,s ; replace temporary slot with NULL
opendir_return      puls      d,u,pc    ; return DIR pointer and restore U
_readdir:
stk_readdir_ret     equ       0         ; caller return address
stk_readdir_dirp    equ       2         ; DIR * argument
stk_readdir_result  equ       -2        ; temporary read result below saved U after prologue
                    pshs      u         ; preserve caller U
                    ldu       stk_readdir_dirp+2,s ; saved U shifts DIR pointer by two bytes
                    leau      DIR_BUF,u ; point U at DIR.dd_buf
readdir_next_entry  ldd       #DIR_BUF_SIZE ; read one raw directory entry
* Keep the original KLib call shape for _read(fd, buf, count):
*   push count, then push fd+buf together.
                    pshs      d         ; pass byte count
                    ldd       DIR_FD-DIR_BUF,u ; load DIR.dd_fd
                    pshs      d,u       ; pass fd and buffer pointer
                    lbsr      _read     ; read next raw directory entry
                    leas      6,s       ; discard _read arguments
                    std       stk_readdir_result,s ; preserve read count below saved U and set flags
                    bgt       readdir_copy_entry ; process entry when bytes were read
                    clra                ; return NULL high byte on EOF or read error
                    clrb                ; return NULL low byte on EOF or read error
                    puls      u,pc      ; restore U and return NULL
readdir_copy_entry  ldb       DIR_NAME_OFF,u ; test first raw name byte
                    beq       readdir_next_entry ; skip empty directory slots
                    leax      dirent_result_name,y ; point X at static d_name result
                    pshs      x,u       ; pass destination and raw entry source
                    lbsr      _strhcpy  ; copy high-bit-terminated OS-9 name
                    leas      4,s       ; discard _strhcpy arguments
                    leax      dirent_result_addr,y ; point X at static struct direct result
                    clra                ; high byte of 24-bit directory address is zero
                    ldb       DIR_ADDR_MID,u ; copy middle address byte
                    std       DIRECT_ADDR,x ; store high word of d_addr
                    ldd       DIR_ADDR_LO,u ; copy low address word
                    std       DIRECT_ADDR+2,x ; store low word of d_addr
                    tfr       x,d       ; return pointer to static DIRECT result
                    puls      u,pc      ; restore U and return result pointer
                    endsect   ;         end current section
