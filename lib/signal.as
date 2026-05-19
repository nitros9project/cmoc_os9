* Adapted from cmoc_os9/lib/todo/signal.as for the live cmoc_os9 ABI.
*
* 'signal' and 'intercept' are definitely incompatible and use of both in a
* program will have undefined results.  Both modules export _sigint so the
* linker reports an entry-name clash if an attempt is made to use both.

                    section   bss       ; begin bss section

MAXENTS             equ       20        ; maximum simultaneous traps
Zero                equ       %00000100 ; condition-code Z bit mask
sig                 equ       0         ; signal byte offset in a table entry
func                equ       1         ; handler pointer offset in a table entry
entsiz              equ       3         ; bytes per signal table entry

_table              rmb       entsiz*MAXENTS ; signal-to-handler table
_etable             rmb       0         ; sentinel address just past signal table
_flag               rmb       1         ; nonzero once F_Icpt has been installed

                    endsect   ;         end current section

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_sigint             EXPORT    ;         export signal-compatible intercept installer
_signal             EXPORT    ;         export C signal() entry point

* signal(sig, func)
_sigint:
_signal:
stk_signal_ret      equ       0         ; caller return address
stk_signal_signo    equ       2         ; signal number argument
stk_signal_handler  equ       4         ; new signal handler pointer
                    ldd       stk_signal_signo,s ; get the signal number
                    tstb                ; signal zero cannot be caught or ignored
                    beq       sigerr    ; reject signal zero
                    tsta                ; high byte must be zero for OS-9 signal byte
                    bne       sigerr    ; reject signal numbers above 255
                    bsr       lookup    ; find existing or free table entry
                    bne       signal10  ; continue when a table slot is available

sigerr
                    ldd       #-1       ; return SIG_ERR on failure
                    rts                 ; return to caller

signal10
                    ldd       func,x    ; get previous handler from the table entry
                    pshs      d         ; save previous handler as signal() return value
                    ldd       stk_signal_handler+2,s ; get new handler after saved return value
                    std       func,x    ; store new handler in the table entry
                    bne       signal20  ; install or keep table entry for non-default handlers

* the new 'function' is reset (0)
                    clr       sig,x     ; clear the signal byte for SIG_DFL
sigexit
                    puls      d,pc      ; return previous handler

* value for 'func' is 1 or a real address - set it
signal20
                    ldb       stk_signal_signo+3,s ; get signal low byte after saved return value
                    stb       sig,x     ; store signal number in table entry
                    tst       _flag,y   ; test whether F_Icpt was already installed
                    bne       sigexit   ; no kernel call needed after first install

                    exg       y,u       ; pass data area in U as required by F_Icpt
                    leax      intrupt,pcr ; point X at intercept routine
                    os9       F_Icpt    ; install signal intercept routine
                    exg       y,u       ; restore CMOC data pointer
                    puls      d         ; recover previous handler return value
                    bcs       sigerr    ; return SIG_ERR if F_Icpt failed
                    inc       _flag,y   ; remember intercept routine is installed
                    rts                 ; return previous handler

* Table lookup function:
*
* find an entry in the table whose 'sig' matches the b reg.
* failing that, the first empty entry
* failing that, zero
* return result in x reg. and set the z bit accordingly
lookup
stk_lookup_endp     equ       0         ; table end pointer scratch after setup
stk_lookup_emptyp   equ       2         ; first empty entry pointer scratch after setup
                    clr       ,-s       ; clear low byte of first-empty pointer
                    clr       ,-s       ; clear high byte of first-empty pointer
                    leax      _etable,y ; point X just past the table
                    pshs      x         ; save table end pointer
                    leax      _table,y  ; start scan at first table entry

loop
                    cmpx      stk_lookup_endp,s ; test whether scan reached table end
                    beq       eloop     ; stop after all entries have been examined
                    cmpb      sig,x     ; compare requested signal against entry signal
                    bne       signal30  ; keep scanning if this entry is for another signal
                    leas      4,s       ; discard lookup scratch
                    andcc     #^Zero    ; clear Z to indicate success
                    rts                 ; return matching entry in X

signal30
                    lda       sig,x     ; inspect whether entry is empty
                    ora       stk_lookup_emptyp,s ; combine with saved empty pointer high byte
                    ora       stk_lookup_emptyp+1,s ; combine with saved empty pointer low byte
                    bne       signal40  ; keep first empty pointer already found
                    stx       stk_lookup_emptyp,s ; remember this empty entry

signal40
                    leax      entsiz,x  ; advance to next table entry
                    bra       loop      ; continue table scan

eloop
* traversed table without finding a match
                    ldx       stk_lookup_emptyp,s ; return first empty entry, or zero if none
                    leas      4,s       ; discard lookup scratch
                    rts                 ; Z reflects whether X is zero

* Entry point for all received signals.
* If an entry is found matching the signal then
*   if the function address is not 1 then execute it
*   then rti
* else
*   exit with the signal as status
intrupt
                    leay      ,u        ; restore CMOC data pointer from OS-9 U
                    bsr       lookup    ; find handler entry for signal in B
                    beq       intr10    ; exit process when no entry exists
                    pshs      x         ; save handler table entry pointer
                    ldx       func,x    ; get handler address or SIG_IGN marker
                    bne       intr20    ; continue when entry has a handler value

* no matching entry - simulate condition of no 'intercept'
intr10
                    os9       F_Exit    ; status still in B reg.

intr20
                    cmpx      #1        ; signal handler value 1 means ignore
                    bne       intr30    ; execute real handler pointers
                    leas      2,s       ; discard saved table entry pointer
                    rti                 ; resume interrupted code

intr30
                    clra                ; pass signal as positive int
                    pshs      d         ; stage signal argument for handler
                    jsr       ,x        ; call installed C handler
                    puls      d,x       ; discard handler argument and recover table entry pointer
                    clra                ; clear signal byte value
                    clrb                ; clear handler pointer value
                    sta       sig,x     ; reset signal entry after delivery
                    std       func,x    ; clear handler pointer
                    rti                 ; resume interrupted code

                    endsect   ;         end current section
