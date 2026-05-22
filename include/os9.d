* Shared assembler-side OS-9 service, error, and status constants.

F_Link              equ       $00       ; OS-9 link existing module
F_Load              equ       $01       ; OS-9 load module from disk
F_UnLink            equ       $02       ; OS-9 release linked module
F_Fork              equ       $03       ; OS-9 fork system call
F_Wait              equ       $04       ; OS-9 wait system call
F_Chain             equ       $05       ; OS-9 chain system call
F_Exit              equ       $06       ; OS-9 exit system call
F_Mem               equ       $07       ; OS-9 memory-allocation service
F_Send              equ       $08       ; OS-9 send-signal system call
F_Icpt              equ       $09       ; OS-9 intercept-vector service
F_Sleep             equ       $0A       ; OS-9 sleep system call
F_ID                equ       $0C       ; OS-9 process identity service
F_SPrior            equ       $0D       ; OS-9 set-priority system call
F_PErr              equ       $0F       ; OS-9 print-error service
F_Time              equ       $15       ; OS-9 read system time service
F_STime             equ       $16       ; OS-9 set system time service
F_CRC               equ       $17       ; OS-9 CRC helper service
F_SUser             equ       $1C       ; OS-9 set user ID service

I_Create            equ       $83       ; OS-9 create path call
I_Open              equ       $84       ; OS-9 open path call
I_MakDir            equ       $85       ; OS-9 make-directory call
I_ChgDir            equ       $86       ; OS-9 change-directory call
I_Delete            equ       $87       ; OS-9 delete path call
I_Seek              equ       $88       ; OS-9 direct seek call
I_Read              equ       $89       ; OS-9 read call
I_Write             equ       $8A       ; OS-9 write call
I_ReadLn            equ       $8B       ; OS-9 line-read call
I_WritLn            equ       $8C       ; OS-9 line-write call
I_GetStt            equ       $8D       ; OS-9 GetStat call
I_SetStt            equ       $8E       ; OS-9 SetStat call
I_Close             equ       $8F       ; OS-9 close call
I_DeletX            equ       $90       ; OS-9 extended delete call
I_Dup               equ       $82       ; OS-9 duplicate path descriptor call

E_PthFul            equ       $C8       ; path table full error code
E_BMode             equ       $CB       ; bad access mode error code
E_MemFul            equ       $CF       ; process memory full error code
E_UnkSvc            equ       $D0       ; unknown service error code
E_EOF               equ       $D3       ; end-of-file status code
E_FNA               equ       $D6       ; file not accessible error code
E_CEF               equ       $DA       ; creating existing file error code
E_MNF               equ       $DD       ; module not found error code
E_NoRAM             equ       $ED       ; no RAM available error code
E_Seek              equ       $F7       ; seek error code

ModType_Data        equ       $40       ; OS-9 data-module type nibble

SS_Opt              equ       $00       ; path options query/set
SS_Ready            equ       $01       ; path ready state query
SS_Size             equ       $02       ; file size query/set
SS_Reset            equ       $03       ; reset device/path state
SS_WTrk             equ       $04       ; write-track style command
SS_Pos              equ       $05       ; current file position query
SS_EOF              equ       $06       ; end-of-file query
SS_Frz              equ       $0A       ; freeze device command
SS_SPT              equ       $0B       ; set sectors-per-track style command
SS_SQD              equ       $0C       ; sequence-down command
SS_DCmd             equ       $0D       ; device command with register block
SS_DevNm            equ       $0E       ; device name query
SS_FD               equ       $0F       ; file descriptor sector query/set
SS_Ticks            equ       $10       ; tick count status
SS_Lock             equ       $11       ; lock status command
SS_BlkRd            equ       $14       ; block read command
SS_BlkWr            equ       $15       ; block write command
SS_ELog             equ       $19       ; error log command
SS_SSig             equ       $1A       ; send signal command
SS_Relea            equ       $1B       ; release command
SS_Attr             equ       $1C       ; path attribute command
