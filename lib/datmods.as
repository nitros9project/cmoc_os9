* Adapted from cmoc_os9/lib/todo/datmods.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_lockdata           EXPORT    ;         export this symbol
_unlkdata           EXPORT    ;         export this symbol
_datlink            EXPORT    ;         export this symbol
_dunlink            EXPORT    ;         export this symbol

_os9err             EXTERNAL  ;         import external symbol
_sysret             EXTERNAL  ;         import external symbol

DATMOD_HEADER_ADJUST equ       5         ; bytes excluded from reported data-module space

_lockdata:
stk_lockdata_ret    equ       0         ; caller return address
stk_lockdata_datptr equ       2         ; pointer to data-module data area
IntMask             equ       $10       ; condition-code interrupt mask bit
                    ldx       stk_lockdata_datptr,s ; load data-module data pointer
                    pshs      cc        ; preserve caller interrupt state
                    orcc      #IntMask  ; protect the module lock byte update
                    inc       ,x        ; attempt to increment the module lock count
                    beq       data_lock_zero ; return zero if the count wrapped through zero
                    ldb       ,x        ; return the new lock count
                    dec       ,x        ; leave the stored lock count unchanged
data_lock_count     sex                 ; sign-extend status byte into int return
                    puls      cc,pc     ; restore interrupt state and return

_unlkdata:
stk_unlkdata_ret    equ       0         ; caller return address
stk_unlkdata_datptr equ       2         ; pointer to data-module data area
                    ldx       stk_unlkdata_datptr,s ; load data-module data pointer
                    pshs      cc        ; preserve caller interrupt state
                    orcc      #IntMask  ; protect the module lock byte update
                    ldb       ,x        ; read current lock count
                    bne       data_lock_count ; return nonzero count without changing it
                    dec       ,x        ; mark the data module unlocked when count is zero
data_lock_zero      clra                ; return zero high byte
                    clrb                ; return zero low byte
                    puls      cc,pc     ; restore interrupt state and return

_datlink:
stk_datlink_ret     equ       0         ; caller return address
stk_datlink_name    equ       2         ; module name pointer
stk_datlink_datptr  equ       4         ; output pointer for module data area
stk_datlink_space   equ       6         ; output pointer for module data size
stk_datlink_loaded  equ       0         ; temporary flag: nonzero when F$Load was used
stk_datlink_saved   equ       2         ; saved Y/U pair above the temporary flag
                    pshs      y,u       ; preserve frame and module header registers
                    clr       ,-s       ; clear high byte of loaded-module flag
                    clr       ,-s       ; clear low byte of loaded-module flag
                    ldx       stk_datlink_name+6,s ; saved registers and flag shift name argument
                    lda       #ModType_Data ; request a data module
                    os9       F_Link    ; invoke OS-9 system call F_Link
                    bcc       datlink_got_module ; use linked module when already resident
                    cmpb      #E_MNF    ; module not found?
                    beq       datlink_load_module ; load from disk only for missing module
                    coma                ; preserve historical nonzero A on hard link failure
datlink_error       puls      x,y,u     ; discard flag and restore saved registers
                    lbra      _os9err   ; convert OS-9 error in B to C return convention
datlink_load_module ldx       stk_datlink_name+6,s ; reload module name pointer
                    lda       #ModType_Data ; request a data module
                    os9       F_Load    ; invoke OS-9 system call F_Load
                    bcs       datlink_error ; report load failure through _os9err
                    inc       stk_datlink_loaded+1,s ; remember that this call loaded the module
datlink_got_module  pshs      y         ; save module header pointer for data-offset calculation
                    tfr       u,d       ; copy module end pointer from U
                    subd      ,s++      ; subtract module header pointer and discard saved copy
                    std       ,y++      ; write data offset into module header
                    sty       [stk_datlink_datptr+6,s] ; return pointer to data area
                    addd      2,u       ; add module size to compute available data span
                    subd      #DATMOD_HEADER_ADJUST ; adjust for data-module header bookkeeping bytes
                    std       [stk_datlink_space+6,s] ; return data-module data size
                    ldd       stk_datlink_loaded,s ; test whether the module was loaded here
                    beq       datlink_return ; skip lock update for already-linked modules
                    pshs      y         ; pass data pointer to _lockdata
                    bsr       _lockdata ; lock newly loaded module data
                    std       ,s++      ; remove pushed data pointer while preserving status in D
                    beq       datlink_return ; keep loaded flag clear when lock returned zero
                    clr       stk_datlink_loaded+1,s ; clear loaded flag after successful lock
datlink_return      puls      d,y,u,pc  ; discard flag, restore registers, and return

_dunlink:
stk_dunlink_ret     equ       0         ; caller return address
stk_dunlink_datptr  equ       2         ; data pointer returned by datlink()
                    pshs      u         ; preserve caller U
                    ldu       stk_dunlink_datptr+2,s ; saved U shifts data pointer by two bytes
                    ldd       ,--u      ; fetch negative offset from data area back to module header
                    leau      d,u       ; recover module header pointer for F$UnLink
                    os9       F_UnLink  ; invoke OS-9 system call F_UnLink
                    puls      u         ; restore caller U
                    lbra      _sysret   ; convert OS-9 status to C return convention

                    endsect   ;         end current section
