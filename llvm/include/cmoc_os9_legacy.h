#ifndef CMOC_OS9_LEGACY_H
#define CMOC_OS9_LEGACY_H
#include "os.h"
#include <errno.h>
#include <math.h>
typedef cmoc_sighandler_t sighandler_t;
extern const unsigned char _chcodes[256];
#define _CONTROL 0x01
#define _UPPER 0x02
#define _LOWER 0x04
#define _DIGIT 0x08
#define _WHITE 0x10
#define _PUNCT 0x20
#define _HEXDIG 0x40
extern char *__os9_heap_cur, *__os9_top, *__os9_param;
extern unsigned __os9_stack_size;
/* Read these bounds; allocation must go through the heap functions. */
#define _mtop ((void *)__os9_heap_cur)
#define _memend ((void *)__os9_top)
#define _sttop ((void *)__os9_param)
#define _stbot ((void *)(__os9_param - __os9_stack_size))
#include <fcntl.h>
#include <sys/stat.h>
#define acos cmoc_acos
#define asin cmoc_asin
#define atan cmoc_atan
#define cos cmoc_cos
#define sin cmoc_sin
#define tan cmoc_tan
#define access cmoc_access
#define brk cmoc_brk
#define chmod cmoc_chmod
#define chown cmoc_chown
#define creat cmoc_creat
#define kill cmoc_kill
#define mknod cmoc_mknod
#define open cmoc_open
#define pause cmoc_pause
#define pclose cmoc_pclose
#define popen cmoc_popen
#define sbrk cmoc_sbrk
#define setuid cmoc_setuid
#define signal cmoc_signal
#define sleep cmoc_sleep
#define swab cmoc_swab
#define unlinkx cmoc_unlinkx
#define wait cmoc_wait
#define getuid cmoc_legacy_getuid
#define getpid cmoc_legacy_getpid
#define itoa cmoc_itoa
#define utoa cmoc_utoa
#define system cmoc_system
#undef SIGKILL
#define SIGKILL 0
#define SIGWAKE 1
#undef SIGQUIT
#define SIGQUIT 2
#undef SIGINT
#define SIGINT 3
#undef SIG_DFL
#define SIG_DFL CMOC_SIG_DFL
#undef SIG_IGN
#define SIG_IGN CMOC_SIG_IGN
#undef SIG_ERR
#define SIG_ERR CMOC_SIG_ERR

#undef S_IFMT
#undef S_IFDIR
#undef S_IREAD
#undef S_IWRITE
#undef S_IEXEC
#define S_IFMT 0xff    /* mask for type of file */
#define S_IFDIR 0x80   /* directory */
#define S_IPRM 0xff    /* mask for permission bits */
#define S_IREAD 0x01   /* owner read */
#define S_IWRITE 0x02  /* owner write */
#define S_IEXEC 0x04   /* owner execute */
#define S_IOREAD 0x08  /* public read */
#define S_IOWRITE 0x10 /* public write */
#define S_IOEXEC 0x20  /* public execute */
#define S_ISHARE 0x40  /* sharable */
#define S_DIR 0x80     /* directory */
#define FAM_READ S_IREAD
#define FAM_WRITE S_IWRITE
#define FAM_UPDATE (S_IREAD | S_IWRITE)
#define FAM_NONSHARE S_ISHARE
#define FAM_DIR S_DIR
#define FAP_READ 0x01
#define FAP_WRITE 0x02
#define FAP_EXEC 0x04
#define FAP_PREAD 0x08
#define FAP_PWRITE 0x10
#define FAP_PEXEC 0x20
#define FAP_SHARE 0x40
#define FAP_DIR 0x80
#endif
