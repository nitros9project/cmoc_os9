* Shared assembler-side file mode and access constants.

S_IREAD             equ       $01       ; owner-read permission bit
S_IWRITE            equ       $02       ; owner-write permission bit
S_IEXEC             equ       $04       ; owner-execute permission bit
S_IOREAD            equ       $08       ; public-read permission bit
S_IOWRITE           equ       $10       ; public-write permission bit
S_IOEXEC            equ       $20       ; public-execute permission bit
S_SHARED            equ       $40       ; sharable file bit
S_DIR               equ       $80       ; directory attribute bit

FAP_READ            equ       $01       ; owner-read access permission
FAP_WRITE           equ       $02       ; owner-write access permission
FAP_EXEC            equ       $04       ; owner-execute access permission
FAP_PREAD           equ       $08       ; public-read access permission
FAP_PWRITE          equ       $10       ; public-write access permission
FAP_PEXEC           equ       $20       ; public-execute access permission
FAP_SHARE           equ       $40       ; sharable-file permission bit
FAP_DIR             equ       $80       ; directory attribute bit

FAM_READ            equ       S_IREAD   ; open for reading
FAM_WRITE           equ       S_IWRITE  ; open for writing
FAM_UPDATE          equ       S_IREAD|S_IWRITE ; open for read/write
FAM_NONSHARE        equ       S_SHARED  ; open in non-sharable mode
FAM_DIR             equ       S_DIR     ; operate on a directory path
