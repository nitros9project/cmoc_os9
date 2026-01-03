#include <os.h>

__norts__ asm error_code
_os_getpid(int *pid)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = address of process ID [out parameter]
        pshs        y
        os9         F$ID
        puls        y
_oserr  EXTERNAL
        lbcs        _oserr
        tfr         a,b
        clra
        std         [2,s]
_osret  EXTERNAL
        lbra        _osret
    }
}

__norts__ asm error_code
_os_getuid(int *uid)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = address of uid [out parameter]
        pshs        y
        os9         F$ID
        tfr         y,d
        puls        y
        lbcs        _oserr
        std         [2+2,s]
        lbra        _osret
    }
}

__norts__ asm error_code
_os_asetuid(int uid)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = uid
        pshs        y
        bra         L0027
    }
}

/* WARNING: Writes to system globals and process descriptor
 * won't work for Level 2!
 */
__norts__ asm error_code
_os_setuid(int uid)
{
    asm
    {
* stack:
*	0,s = return address
*	2,s = uid
        pshs        y
        os9         F$ID            get user id
        tfr         y,d
        std         -2,s
        beq         L0027           branch if super user
        ldb         #E$FNA          else not allowed
L0022   puls        y
        lbra        _oserr
L0027   ldy         2+2,s           get new user id
        os9         F$SUser         set user id
        bcc         L003b
        cmpb        #E$UnkSvc       illegal code?
        bne         L0022
        tfr         y,d
        ldy         $004B           * D.Proc
        std         9,y             * P$User,y
L003b   puls        y
        lbra        _osret
    }
}
