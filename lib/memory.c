#include <stdlib.h>

/*
* memory allocation ala K&R
*  functionally identical to the C stuff from MicroWare
*   but 75% as much code and faster
*   calloc split out to save size
 */

struct _mallocbase {
    int ptr;
    int size;
};

static struct _mallocbase base = {0x0000, 0x0000};
static int allocp = 0;

__norts__ asm void *
malloc(size_t size)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = count to alloc
        pshs    d,u
        ldd     4+2,s
        addd    #3                          nbytes + sizeof(HEADER) - 1
        lsra                                div by sizeof(HEADER)
        rorb
        lsra
        rorb
        addd    #1                          result + 1
        std     ,s                          nunits = result
        ldx     _allocp,y                   q = allocp
        bne     malloc1                     if not 0
        leax    _base,y                     q = &base
        stx     _allocp,y                   allocp = q = &base
        stx     _base,y                     base.ptr = .... = &base
        clra
        clrb
        std     _base+2,y                   base.size = 0

malloc1 ldu     ,x                          p = q->ptr
        bra     malloc3

malloc2 tfr     u,x                         q = p
        ldu     ,u                          p = p->ptr
malloc3 ldd     2,u
        cmpd    ,s
        blo     malloc6                     if (p->size >= nunits)
        bne     malloc4                     if (p->size == nunits)
        ldd     ,u
        std     ,x                          q->ptr = p->ptr
        bra     malloc5

malloc4 ldd     2,u                         p->size -= nunits
        subd    ,s
        std     2,u
        aslb                                (char) p->size
        rola
        aslb
        rola
        leau    d,u                         p += (char) p->size
        ldd     ,s                          p->size = nunits
        std     2,u
malloc5 stx     _allocp,y                   allocp = q
        leau    4,u                         p += 1 (header)
        tfr     u,d                         set up for return
        bra     malloc7
malloc6 cmpu    _allocp,y                   if (p == allocp)
        bne     malloc2
        lbsr    morecore                    nunits above return addr
        bne     malloc2                     if (p = .... == 0)
        clra
        clrb                                set up zero for return
malloc7 leas    2,s
        puls    u,pc
    }
}

__norts__ asm void
free(void *ptr)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = pointer to free
        pshs    d,u
        ldu     4+2,s                       get address to free in U
        leau    -4,u                        p = ap - 1
        ldx     _allocp,y                   q = allocp
        bra     free3
free1   cmpx    ,x                          if (q >= q->ptr)
        blo     free2
        cmpu    ,s                          && (p > q
        bhi     free4
        cmpu    ,x                          || p < q->ptr)
        blo     free4
free2   ldx     ,x                          q >= q->ptr
free3   stx     ,s                          qNOT = q
        cmpu    ,s                          if (p > q)
        bls     free1
        cmpu    ,x                          && (p < q->ptr)
        bhs     free1

free4   pshs    u                           stack p
        ldd     2,u                         t$1 = p->size
        aslb                                scale it
        rola
        aslb
        rola
        addd    ,s++                        t$1 = p + p->size
        cmpd    ,x                          if (p + p->size == q->ptr)
        bne     free5
        pshs    x                           save q
        ldx     ,x                          q = q->ptr
        ldd     2,x                         t$1 = q->ptr->size
        puls    x                           recover q
        addd    2,u                         t$1 = p->size + p->ptr->size
        std     2,u                         p->size = t$1
        ldd     [,x]                        t$1 = q->ptr->ptr
        bra     free6

free5   ldd     ,x                          t$1 = q->ptr
free6   std     ,u                          p->ptr = t$1
        ldd     2,x                         t$1 = q->size
        aslb                                scale it
        rola
        aslb
        rola
        addd    ,s                          t$1 = q + q->size
        pshs    d
        cmpu    ,s++                        if (q + q->size == p)
        bne     free7
        ldd     2,x                         t$1 = q->size
        addd    2,u                         t$1 += p->size
        std     2,x                         q->size = t$1
        ldd     ,u                          t$1 = p->ptr
        std     ,x                          q->ptr = t$1
        bra     free8

free7   stu     ,x                          q->ptr = p
free8   stx     _allocp,y                   allocp = q
        lbra    malloc7

morecore
        ldd     2,s                         get nu
        addd    #255                        nu + NALLOC - 1
        clrb                                divided by NALLOC
        pshs    d                           rnu = result
        aslb                                * sizeof(HEADER)
        rola
        aslb
        rola
        pshs    d
_sbrk   EXTERNAL
        lbsr    _sbrk
        leas    2,s
        puls    u                           get rnu into U
        cmpd    #-1                         if (cp == -1)
        beq     an_rts                      *NOTE* .eq is returned

        exg     d,u                         swap rnu and up
        std     2,u                         up->size = rnu
        leau    4,u                         up += 1
        pshs    u
        lbsr    _free
        puls    u
        ldu     _allocp,y                   return allocp (never 0)
an_rts  rts
    }
}
