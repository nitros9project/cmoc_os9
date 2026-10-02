/* Use LLVM's register constraints, not CMOC's stack argument layout. */
#include <os9.h>
#include "syscalls.h"

int cmoc_os9_get_user(int *uid)
{
    return _os_id(0, uid);
}

int cmoc_os9_set_user(unsigned int uid)
{
    unsigned char failed, code;
    /* F$SUser ($1C), as used by lib/id.as. The kernel decides whether the
     * call is permitted; asetuid adds no userspace root-only restriction. */
    OS9_SYSCALL(0x1c, ("=c"(failed), "=B"(code)), ("y"(uid)));
    return failed ? __os9_fail(code) : 0;
}

int cmoc_os9_read_line(int path, void *buffer, int *count)
{
    return _os_readln(path, buffer, count);
}
