* Adapted from cmoc_os9/lib/todo/ss1.as, ss2.as, and ss3.as for the live cmoc_os9 ABI.

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_ss_rel             EXPORT    ;         export release SetStat helper
_ss_rest            EXPORT    ;         export reset SetStat helper
_ss_opt             EXPORT    ;         export path-options SetStat helper
_ss_pfd             EXPORT    ;         export file-descriptor SetStat helper
_ss_ssig            EXPORT    ;         export send-signal SetStat helper
_ss_tiks            EXPORT    ;         export ticks SetStat helper
_ss_lock            EXPORT    ;         export lock SetStat helper
_ss_attr            EXPORT    ;         export attribute SetStat helper
_ss_size            EXPORT    ;         export size SetStat helper
_ss_wtrk            EXPORT    ;         export write-track SetStat helper
__ss_rel            EXPORT    ;         export C ABI alias for _ss_rel()
__ss_rest           EXPORT    ;         export C ABI alias for _ss_rest()
__ss_opt            EXPORT    ;         export C ABI alias for _ss_opt()
__ss_pfd            EXPORT    ;         export C ABI alias for _ss_pfd()
__ss_ssig           EXPORT    ;         export C ABI alias for _ss_ssig()
__ss_tiks           EXPORT    ;         export C ABI alias for _ss_tiks()
__ss_lock           EXPORT    ;         export C ABI alias for _ss_lock()
__ss_attr           EXPORT    ;         export C ABI alias for _ss_attr()
__ss_size           EXPORT    ;         export C ABI alias for _ss_size()
__ss_wtrk           EXPORT    ;         export C ABI alias for _ss_wtrk()

_sysret             EXTERNAL  ;         import common syscall return handler

__ss_rel:
_ss_rel:
stk_ss_rel_ret      equ       0         ; caller return address
stk_ss_rel_path     equ       2         ; path descriptor argument
                    ldb       #SS_Relea ; request release SetStat
                    bra       ss_path_only ; issue SetStat with path in A

__ss_rest:
_ss_rest:
stk_ss_rest_ret     equ       0         ; caller return address
stk_ss_rest_path    equ       2         ; path descriptor argument
                    ldb       #SS_Reset ; request reset SetStat
                    bra       ss_path_only ; issue SetStat with path in A

__ss_opt:
_ss_opt:
stk_ss_opt_ret      equ       0         ; caller return address
stk_ss_opt_path     equ       2         ; path descriptor argument
stk_ss_opt_buffer   equ       4         ; path-options buffer pointer
                    ldb       #SS_Opt   ; request path-options SetStat
                    bra       ss_with_x ; issue SetStat with X argument

__ss_pfd:
_ss_pfd:
stk_ss_pfd_ret      equ       0         ; caller return address
stk_ss_pfd_path     equ       2         ; path descriptor argument
stk_ss_pfd_buffer   equ       4         ; file-descriptor buffer pointer
                    ldb       #SS_FD    ; request file-descriptor SetStat
                    bra       ss_with_x ; issue SetStat with X argument

__ss_ssig:
_ss_ssig:
stk_ss_ssig_ret     equ       0         ; caller return address
stk_ss_ssig_path    equ       2         ; path descriptor argument
stk_ss_ssig_signal  equ       4         ; signal-on-status buffer pointer
                    ldb       #SS_SSig  ; request send-signal SetStat
                    bra       ss_with_x ; issue SetStat with X argument

__ss_tiks:
_ss_tiks:
stk_ss_tiks_ret     equ       0         ; caller return address
stk_ss_tiks_path    equ       2         ; path descriptor argument
stk_ss_tiks_buffer  equ       4         ; tick-count buffer pointer
                    ldb       #SS_Ticks ; request tick-count SetStat
ss_with_x           ldx       stk_ss_opt_buffer,s ; pass second argument in X
ss_path_only        lda       stk_ss_opt_path+1,s ; pass low byte of path descriptor in A
                    os9       I_SetStt  ; invoke OS-9 SetStat
                    lbra      _sysret   ; return through common syscall handler

__ss_lock:
_ss_lock:
stk_ss_lock_ret     equ       0         ; caller return address
stk_ss_lock_path    equ       2         ; path descriptor argument
stk_ss_lock_xarg    equ       4         ; X argument passed to SetStat
stk_ss_lock_uarg    equ       6         ; U argument passed to SetStat
                    pshs      u         ; preserve caller's U register
                    ldb       #SS_Lock  ; request lock SetStat
                    bra       ss_with_xu ; issue SetStat with X and U arguments

__ss_attr:
_ss_attr:
stk_ss_attr_ret     equ       0         ; caller return address
stk_ss_attr_path    equ       2         ; path descriptor argument
stk_ss_attr_xarg    equ       4         ; X argument passed to SetStat
                    pshs      u         ; preserve caller's U register
                    ldb       #SS_Attr  ; request attribute SetStat
                    bra       ss_with_saved_u ; issue SetStat with X argument only

__ss_size:
_ss_size:
stk_ss_size_ret     equ       0         ; caller return address
stk_ss_size_path    equ       2         ; path descriptor argument
stk_ss_size_xarg    equ       4         ; X argument passed to SetStat
stk_ss_size_uarg    equ       6         ; U argument passed to SetStat
                    pshs      u         ; preserve caller's U register
                    ldb       #SS_Size  ; request size SetStat
ss_with_xu          ldu       stk_ss_size_uarg+2,s ; pass third argument in U after saved U
ss_with_saved_u     ldx       stk_ss_size_xarg+2,s ; pass second argument in X after saved U
                    lda       stk_ss_size_path+3,s ; pass low byte of path descriptor after saved U
                    os9       I_SetStt  ; invoke OS-9 SetStat
                    puls      u         ; restore caller's U register
                    lbra      _sysret   ; return through common syscall handler

__ss_wtrk:
_ss_wtrk:
stk_ss_wtrk_ret     equ       0         ; caller return address
stk_ss_wtrk_path    equ       2         ; path descriptor argument
stk_ss_wtrk_uarg    equ       4         ; U argument passed to SetStat
stk_ss_wtrk_yarg    equ       6         ; Y argument passed to SetStat
stk_ss_wtrk_xarg    equ       10        ; X argument passed to SetStat
                    pshs      y,u       ; preserve caller's Y and U registers
                    ldb       #SS_WTrk  ; request write-track SetStat
                    ldy       stk_ss_wtrk_yarg+4,s ; pass Y argument after saved Y/U
                    ldu       stk_ss_wtrk_uarg+4,s ; pass U argument after saved Y/U
                    ldx       stk_ss_wtrk_xarg+4,s ; pass X argument after saved Y/U
                    lda       stk_ss_wtrk_path+5,s ; pass low byte of path descriptor after saved Y/U
                    os9       I_SetStt  ; invoke OS-9 SetStat
                    puls      y,u       ; restore caller's Y and U registers
                    lbra      _sysret   ; return through common syscall handler

                    endsect   ;         end current section
