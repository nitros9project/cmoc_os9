                    use       ../include/os9.d ; shared OS-9 service constants

_getstat            EXPORT              ; export generic GetStat wrapper
_setstat            EXPORT              ; export generic SetStat wrapper
_os_getstat         EXPORT              ; export modern generic GetStat wrapper
_os_setstat         EXPORT              ; export modern generic SetStat wrapper

_os9err             EXTERNAL            ; common OS-9 error return helper
_osret              EXTERNAL            ; modern _os_* status return helper
_sysret             EXTERNAL            ; common system-call return helper

                    section   code      ; begin code section

_getstat
                    lbsr      do_getstat ; perform GetStat and preserve carry result
                    lbra      _sysret   ; return using shared status-to-C helper

_os_getstat
                    lbsr      do_getstat ; perform GetStat and preserve carry result
                    lbra      _osret    ; return using modern _os_* status helper

do_getstat
                    pshs      y,u       ; preserve Y and U across the system call
                    lda       11,s      ; load path number argument
                    ldb       9,s       ; load requested GetStat code
                    beq       L003c     ; SS_Opt uses only X as parameter
                    cmpb      #SS_Ready ; check for simple status query using registers only
                    beq       L003e     ; issue call directly for single-register forms
                    cmpb      #SS_Size  ; query 32-bit file size
                    beq       L0024     ; handle X/U return pair specially
                    cmpb      #SS_Pos   ; query 32-bit file position
                    beq       L0024     ; handle X/U return pair specially
                    cmpb      #SS_EOF   ; check end-of-file status
                    beq       L003e     ; direct GetStat with no pointer setup
                    cmpb      #SS_DevNm ; request device name string
                    beq       L003c     ; load X only before the call
                    cmpb      #SS_FD    ; request file descriptor sector
                    beq       L0039     ; load both X and Y before the call
                    ldb       #E_UnkSvc ; reject unsupported traditional codes
                    bra       gsbye     ; return error through shared exit
L0024               os9       I_GetStt  ; perform size/position GetStat call
                    bcs       gsbye     ; return immediately if OS-9 signaled an error
L002e               stx       [12,s]    ; store high word of 32-bit result through p1
                    ldx       12,s      ; reload destination pointer
                    stu       2,x       ; store low word of 32-bit result through p1
                    clrb                ; clear low byte of success return value
                    clra                ; clear high byte of success return value
                    bra       gsbye     ; finish through shared return path
L0039               ldy       14,s      ; load byte-count/aux pointer argument for SS_FD
L003c               ldx       12,s      ; load primary buffer pointer argument
L003e               os9       I_GetStt  ; issue the requested GetStat call
gsbye               puls      y,u,pc    ; restore preserved registers and return

_setstat
                    lbsr      do_setstat ; perform SetStat and preserve carry result
                    lbra      _sysret   ; return using shared status-to-C helper

_os_setstat
                    lbsr      do_setstat ; perform SetStat and preserve carry result
                    lbra      _osret    ; return using modern _os_* status helper

do_setstat
                    pshs      y,u       ; preserve Y and U across the system call
                    lda       11,s      ; load path number argument
                    ldb       9,s       ; load requested SetStat code
                    beq       L0096     ; SS_Opt uses X only
                    cmpb      #SS_Size  ; file size update uses X and U
                    beq       L0094     ; prepare both registers before calling
                    cmpb      #SS_Reset ; reset uses X only
                    beq       L0096     ; prepare X before calling
                    cmpb      #SS_WTrk  ; commands needing X and Y
                    beq       L0091     ; prepare Y then fall through to X/U setup
                    cmpb      #SS_Frz   ; command uses registers as-is
                    beq       L00a6     ; issue call directly
                    cmpb      #SS_SPT   ; command uses X only
                    beq       L0096     ; prepare X before calling
                    cmpb      #SS_SQD   ; command uses registers as-is
                    beq       L00a6     ; issue call directly
                    cmpb      #SS_DCmd  ; device command uses A/B/X/Y/U packed args
                    beq       L009a     ; unpack extended register set
                    cmpb      #SS_FD    ; descriptor update uses X only
                    beq       L0096     ; prepare X before calling
                    cmpb      #SS_Ticks ; tick update uses X only
                    beq       L0096     ; prepare X before calling
                    cmpb      #SS_Lock  ; lock command uses X and U
                    beq       L0094     ; prepare X and U before calling
                    cmpb      #SS_BlkRd ; block commands use X and Y
                    beq       L0091     ; prepare Y then X/U sequence
                    cmpb      #SS_BlkWr ; block commands use X and Y
                    beq       L0091     ; prepare Y then X/U sequence
                    cmpb      #SS_ELog  ; error log command uses X and Y
                    beq       L0091     ; prepare Y then X/U sequence
                    cmpb      #SS_SSig  ; signal command uses X only
                    beq       L0096     ; prepare X before calling
                    cmpb      #SS_Relea ; release command uses registers as-is
                    beq       L00a6     ; issue call directly
                    ldb       #E_UnkSvc ; reject unsupported traditional codes
                    puls      y,u       ; restore preserved registers before error path
                    lbra      _os9err   ; return unknown-service error
L0091               ldy       16,s      ; load secondary pointer/count argument
L0094               ldu       14,s      ; load auxiliary pointer/value argument
L0096               ldx       12,s      ; load primary pointer/value argument
                    bra       L00a6     ; issue SetStat with prepared registers
L009a               tfr       a,b       ; move path number into B for SS_DCmd convention
                    lda       13,s      ; load command byte into A
                    ldx       14,s      ; load primary pointer/value into X
                    ldy       16,s      ; load secondary pointer/value into Y
                    ldu       18,s      ; load tertiary pointer/value into U
L00a6               os9       I_SetStt  ; issue the requested SetStat call
                    puls      y,u,pc    ; restore preserved registers and return

                    endsect             ; end code section
