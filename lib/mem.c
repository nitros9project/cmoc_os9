#include <unistd.h>
#include <os.h>

int spare;

__norts__ asm void *
sbrk(int increase)
{
	asm
	{
__memend EXTERNAL
* stack:
*	0,s = return address
*	2,s = increase amount
        ldd     __memend,y      get top of data area
        pshs    d               save on stack for now
        ldd     2+2,s           get parameter (amount to increase)
        cmpd    #0000           is user requesting anything?
        beq     sbrkex          no... just return
        cmpd    _spare,y        any spare left? (initially set to zero)
        blo     sbrk20          branch if less than

* we have to get some memory from the system
        pshs    y               save off data ptr
        clra
        clrb
        os9     F$Mem           D = 0, get current size and upper boundaries
        addd    2+2+2,s         add requested increase to current size
        os9     F$Mem           ask for new size in D
        tfr     y,d             put address of new memory area upper bound in D
        puls    y               recover data ptr
        bcc     sbrk10          branch if success
        ldd     #-1             else error
        leas    2,s             recover stack
        rts                     return

sbrk10  std     __memend,y      save new memory area upper bound in memend
        addd    _spare,y        add to spare
        subd    ,s              subtract saved memend at start of call
        std     _spare,y        and update spare to that

* now _spare is big enough
sbrk20  leas    2,s             eat D saved on stack earlier
        ldd     _spare,y        get spare count into D
        pshs    d               save on stack
        subd    2+2,s           subtract increase from it to get new spare
        std     _spare,y        store updated value in spare
* clear newly reserved area
        ldd     __memend,y      get memend
        subd    ,s++            subtract old spare saved on stack
        pshs    d               save D on stack
        clra                    clear A
        ldx     ,s              get 2 bytes on stack into X
clr@    sta     ,x+             write 0 to location and increment
        cmpx    __memend,y      end of memory?
        bcs     clr@            branch if not
        stx     ,s              save X to stack to pull for return
sbrkex  puls    d,pc
     }
}

asm void *
ibrk(int increase)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = increase amount
        ldd     2,s             get parameter (amount to increase with data allocation)
__mtop EXTERNAL
        addd    __mtop,y        add to top of current memory
        bcs     ibrkerr         if higher, error out
__stbot EXTERNAL
        cmpd    __stbot,y       compare to bottom of stack -- does it overlap?
        bhs     ibrkerr         yes, it is an error
        pshs    d               otherwise save off D
        ldx     __mtop,y        get mtop in X
        clra
clr@    cmpx    ,s              have we reached the end?
        bcc     ibrk10          branch if so
        sta     ,x+             else clear byte
        bra     clr@            and go to next

ibrk10  ldd     __mtop,y        get current _mtop
        puls    x               get earlier saved value
        stx     __mtop,y        and save as new _mtop
        rts

ibrkerr ldd     #-1             error
    }
}

asm void *
unbrk(int decrease)
{
	asm
	{
* stack:
*	0,s = return address
*	2,s = decrease amount
        ldd     2,s           get parameter in D (memory to return from sbrk)
        pshs    y             save off data ptr
        os9     F$Mem         change data area size
        bcc     L0093
        ldd     #-1
        puls    y,pc

L0093   tfr     y,d           transfer address of new area upper bound into D
        puls    y             recover data pointer
        std     __memend,y    store D in memend
        clra
        clrb
        std     _spare,y      kill any leftover
    }
}
