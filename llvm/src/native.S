/* LLVM pointer arguments and int results use X. Kernel registers are
 * staged through a checked wire block; preserve the process U and DP.
 * OS-9 permits execution of the four-byte stack syscall thunk, matching
 * the historical generic syscall implementation without modifying code. */
.text
.globl __cmoc_syscall
__cmoc_syscall:
 pshs dp,x,y,u
 lda 1,x
 ldb #0x39
 pshs d
 ldd #0x103f
 pshs d
 ldu 2,x
 ldd 1,u
 ldx 4,u
 ldy 6,u
 ldu 8,u
 jsr ,s
 pshs cc,d,dp,x,y,u
 ldx 15,s
 ldx 2,x
 leay ,s
 ldu #10
.Lcopy_regs:
 ldb ,y+
 stb ,x+
 leau -1,u
 bne .Lcopy_regs
 clra
 clrb
 lda ,s
 bita #1
 beq .Lsys_success
 ldb 2,s
.Lsys_success:
 clra
 std 15,s
 leas 14,s
 puls dp,x,y,u
 rts
.globl getsp
getsp:
 leax 2,s
 rts
.globl __cmoc_signal_receiver
__cmoc_signal_receiver:
 tfr u,x
 ldy #24
.Lsave_vregs:
 lda ,x+
 pshs a
 leay -1,y
 bne .Lsave_vregs
 clra
 tfr d,x
 lbsr __cmoc_dispatch_signal
 leax 24,u
 ldy #24
.Lrestore_vregs:
 puls a
 sta ,-x
 leay -1,y
 bne .Lrestore_vregs
 rti
.globl __cmoc_data_base
__cmoc_data_base:
 tfr u,x
 rts
.globl lockdata
lockdata:
 pshs cc
 orcc #0x10
 inc ,x
 beq .Llock_wrapped
 ldb ,x
 dec ,x
 sex
 tfr d,x
 puls cc
 rts
.Llock_wrapped:
 ldx #0
 puls cc
 rts
.globl unlkdata
unlkdata:
 pshs cc
 orcc #0x10
 ldb ,x
 bne .Lunlock_busy
 dec ,x
 ldx #0
 puls cc
 rts
.Lunlock_busy:
 sex
 tfr d,x
 puls cc
 rts
.globl __cmoc_snapshot
__cmoc_snapshot:
 pshs cc,d,dp,x,y,u
 leay ,s
 ldu #10
.Lsnapshot_copy:
 ldb ,y+
 stb ,x+
 leau -1,u
 bne .Lsnapshot_copy
 ldx 4,s
 leay 12,s
 sty 10,x
 puls cc,d,dp,x,y,u
 rts
