#include <os.h>
#include <unistd.h>

int getuid(void)
{
    int uid;

    if (_os_getuid(&uid) != 0)
        return -1;
    return uid;
}

int asetuid(int uid)
{
    int err = _os_asetuid(uid);

    if (err == 0)
        return 0;
    errno = err;
    return -1;
}

int setuid(int uid)
{
    int err = _os_setuid(uid);

    if (err == 0)
        return 0;
    errno = err;
    return -1;
}
