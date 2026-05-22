* Shared assembler-side stdio FILE layout and mode constants.

FILE_PTR            equ       0         ; FILE._ptr offset
FILE_BASE           equ       2         ; FILE._base offset
FILE_END            equ       4         ; FILE._end offset
FILE_FLAG           equ       6         ; FILE._flag offset
FILE_FD             equ       8         ; FILE._fd offset
FILE_SAVE           equ       10        ; FILE._save offset
FILE_BUFSIZ         equ       11        ; FILE._bufsiz offset
FILE_SIZE           equ       13        ; bytes in one FILE table entry

FILE_STDIO_COUNT    equ       3         ; stdin/stdout/stderr occupy the first FILE entries
FILE_USER_COUNT     equ       13        ; dynamically allocated FILE entries after stdio
FILE_USER_OFFSET    equ       FILE_SIZE*FILE_STDIO_COUNT ; first dynamic FILE entry

_READ               equ       $01       ; FILE open-for-read flag
_WRITE              equ       $02       ; FILE open-for-write flag
_UNBUF              equ       $04       ; FILE unbuffered flag
_BIGBUF             equ       $08       ; FILE owns a large buffer
_EOF                equ       $10       ; FILE end-of-file flag
_ERR                equ       $20       ; FILE error flag
_SCF                equ       $40       ; FILE is an SCF device
_RBF                equ       $80       ; FILE is an RBF device

_WRITTEN_HIGH       equ       $01       ; high-byte bit for _WRITTEN
_APPEND_HIGH        equ       $02       ; high-byte bit for append mode
_INIT_HIGH          equ       $80       ; high-byte bit for _INIT

PMODE               equ       $0B       ; default create permissions: owner rw, public read

SEEK_SET            equ       0         ; seek origin: absolute file position
SEEK_CUR            equ       1         ; seek origin: current file position
SEEK_END            equ       2         ; seek origin: end of file
