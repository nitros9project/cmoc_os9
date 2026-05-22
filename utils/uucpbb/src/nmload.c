#ifndef _OSK

/* Our own versions of modlink() and modload() which use
   F$NMLink and F$NMLoad to load a module  --BGP  */

#include <sys/types.h>
#include <os.h>

#if 0
#define F_UNLOAD  0x1d
#endif

extern int errno;


int nmlink (mod, type, lang)
char *mod;
int type, lang;
{
     void *modaddr;
     int result;

     result = _os_modlink (mod, lang, type, &modaddr);
     if (result != 0)
       {
          errno = result;
          return (-1);
       }
     return (0);
}



int nmload (mod, type, lang)
char *mod;
int type, lang;
{
     void *modaddr;
     int result;

     result = _os_modload (mod, lang, type, &modaddr);
     if (result != 0)
       {
          errno = result;
          return (-1);
       }
     return (0);
}


/* our own munload using F$UnLoad to unlink the module --REB */

int munload (mod, typelang)
char *mod;
int typelang;
{
     int result;

     result = _os_modunlink ((void *) mod);
     if (result != 0)
       {
          errno = result;
          return (-1);
       }
     return (0);
}
#endif
