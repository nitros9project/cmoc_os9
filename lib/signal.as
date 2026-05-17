* Adapted from cmoc_os9/lib/todo/signal.as for the live cmoc_os9 ABI.
*
* 'signal' and 'intercept' are definitely incompatible and use of both in a
* program will have undefined results.  Both modules export _sigint so the
* linker reports an entry-name clash if an attempt is made to use both.

                    section   bss       ; begin bss section

MAXENTS             equ       20        ; maximum simultaneous traps
Zero                equ       %00000100 ; define constant as %00000100
sig                 equ       0         ; define constant as 0
func                equ       1         ; define constant as 1
entsiz              equ       3         ; define constant as 3

_table              rmb       entsiz*MAXENTS ; reserve entsiz*MAXENTS bytes
_etable             rmb       0         ; reserve 0 bytes
_flag               rmb       1         ; reserve 1 bytes

                    endsect             ; end current section

                    use       ../include/os9.d ; shared OS-9 service constants

                    section   code      ; begin code section

_sigint             EXPORT              ; export this symbol
_signal             EXPORT              ; export this symbol

* signal(sig, func)
_sigint
_signal
                    ldd       2,s       ; get the signal number
                    tstb                ; lsb 0?
                    beq       sigerr    ; signal 0 can't be caught or ignored
                    tsta                ; greater than 255?
                    bne       sigerr    ; branch if not equal to sigerr
                    bsr       lookup    ; find a suitable entry
                    bne       signal10  ; branch if entry found

sigerr
                    ldd       #-1       ; error indication
                    rts                 ; return to caller

signal10
                    ldd       func,x    ; get the old entry function
                    pshs      d         ; save it
                    ldd       6,s       ; get the new function
                    std       func,x    ; store in the structure
                    bne       signal20  ; if not 0 branch

* the new 'function' is reset (0)
                    clr       sig,x     ; reset the signal byte
sigexit
                    puls      d,pc      ; return the old entry

* value for 'func' is 1 or a real address - set it
signal20
                    ldb       5,s       ; get the signal
                    stb       sig,x     ; store it
                    tst       _flag,y   ; have we intercepted before?
                    bne       sigexit   ; yes - no more to do

                    exg       y,u       ; set the local storage into u
                    leax      intrupt,pcr ; get the address of the interrupt routine
                    os9       F_Icpt    ; invoke OS-9 system call F_Icpt
                    exg       y,u       ; reset local storage into y
                    puls      d         ; get the old value into d
                    bcs       sigerr    ; error?
                    inc       _flag,y   ; indicate that we've done it
                    rts                 ; all done

* Table lookup function:
*
* find an entry in the table whose 'sig' matches the b reg.
* failing that, the first empty entry
* failing that, zero
* return result in x reg. and set the z bit accordingly
lookup
                    clr       ,-s       ; set up a null
                    clr       ,-s       ; 'empty' pointer
                    leax      _etable,y ; get table end address
                    pshs      x         ; save it
                    leax      _table,y  ; start at the beginning

loop
                    cmpx      ,s        ; end yet?
                    beq       eloop     ; yes - exit loop
                    cmpb      sig,x     ; match?
                    bne       signal30  ; no - continue
                    leas      4,s       ; clean up stack
                    andcc     #^Zero    ; indicate success
                    rts                 ; and return

signal30
                    lda       sig,x     ; if the entry is not empty
                    ora       2,s       ; or the 'empty' pointer
                    ora       3,s       ; is not null
                    bne       signal40  ; then continue
                    stx       2,s       ; else save address of empty entry

signal40
                    leax      entsiz,x  ; bump to next
                    bra       loop      ; and round again

eloop
* traversed table without finding a match
                    ldx       2,s       ; get the empty entry pointer
                    leas      4,s       ; clean the stack
                    rts                 ; return to caller

* Entry point for all received signals.
* If an entry is found matching the signal then
*   if the function address is not 1 then execute it
*   then rti
* else
*   exit with the signal as status
intrupt
                    leay      ,u        ; point to the data
                    bsr       lookup    ; branch to subroutine to lookup
                    beq       intr10    ; any entry returned?
                    pshs      x         ; save the entry pointer
                    ldx       func,x    ; get the function address
                    bne       intr20    ; empty entry?

* no matching entry - simulate condition of no 'intercept'
intr10
                    os9       F_Exit    ; status still in B reg.

intr20
                    cmpx      #1        ; is it 'ignore'?
                    bne       intr30    ; no - execute
                    leas      2,s       ; reset stack
                    rti                 ; and resume

intr30
                    clra                ; clear the MSB of the signal arg
                    pshs      d         ; put it on stack for the function
                    jsr       ,x        ; go run the function
                    puls      d,x       ; get the entry pointer back
                    clra                ; clear A
                    clrb                ; clear B
                    sta       sig,x     ; clear the entry
                    std       func,x    ; and its func address
                    rti                 ; and that's it

                    endsect             ; end current section
