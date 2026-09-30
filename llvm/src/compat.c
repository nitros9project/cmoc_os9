#include <errno.h>
#include "cmoc_os9_compat.h"
#include "syscalls.h"

uid_t getuid(void)
{
    int uid;
    int error = cmoc_os9_get_user(&uid);
    if (error) {
        errno = error;
        return (uid_t)-1;
    }
    /* F$ID returns a 16-bit unsigned ID; picolibc's uid_t is 32-bit. */
    return (uid_t)(unsigned short)uid;
}

int asetuid(unsigned int uid)
{
    int error = cmoc_os9_set_user(uid);
    if (error) {
        errno = error;
        return -1;
    }
    return 0;
}

int readln(int path, void *buffer, int count)
{
    int error;
    int actual = count;
    if (path < 0 || path > 255) {
        errno = EBADF;
        return -1;
    }
    if (count < 0 || (!buffer && count)) {
        errno = EINVAL;
        return -1;
    }
    if (!count)
        return 0;
    error = cmoc_os9_read_line(path, buffer, &actual);
    /* LLVM's _os_readln maps OS-9 E$EOF to a successful zero-byte read. */
    if (error) {
        errno = error;
        return -1;
    }
    if (actual > 0 && ((unsigned char *)buffer)[actual - 1] == '\r')
        ((unsigned char *)buffer)[actual - 1] = '\n';
    return actual;
}
