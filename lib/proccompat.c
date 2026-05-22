#include <os.h>
#include <unistd.h>

int sleep(int seconds)
{
    clock_t ticks = (clock_t) seconds * 60;
    clock_t remaining = tsleep(ticks);

    return (int) ((remaining + 59) / 60);
}

int wait(int *status)
{
    return _os_wait(status);
}

int setpr(int pid, int priority)
{
    int err = _os_setpr(pid, priority);

    if (err == 0)
        return 0;
    errno = err;
    return -1;
}

int os9fork(const char *modname, int paramsize, void *paramaddr, int lang, int type, int datasize)
{
    int pid;
    int err = _os_fork(modname, paramsize, paramaddr, lang, type, datasize, &pid);

    if (err == 0)
        return pid;
    errno = err;
    return -1;
}

int chain(const char *modname, int paramsize, void *paramaddr, int lang, int type, int datasize)
{
    int err = _os_chain(modname, paramsize, paramaddr, lang, type, datasize);

    if (err == 0)
        return 0;
    errno = err;
    return -1;
}
