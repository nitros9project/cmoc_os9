#include <cgfx.h>
#include <unistd.h>

static struct {
    const char *name;
    char xsize, ysize;
} items[] = {
    {"gcalc", 30, 12},
    {"gclock", 30, 12},
    {"gcal", 40, 24},
    {"control", 40, 21},
    {"gprint", 40, 21},
    {"gport", 40, 21},
    {"help", 40, 12},
    {"shell", 40, 12}
};

static int run_item(const char *name, int *status)
{
    int pid;
    char params[] = "\n";
    error_code err;

    err = _os_fork(name, 1, params, Objct, Prgrm, 0, &pid);
    if (err != 0)
    {
        errno = err;
        return -1;
    }

    while ((pid = _os_wait(status)) >= 0)
        return 0;

    return -1;
}

int TandyMN(path_id path, int inum, int fg, int bg)
{
    int error;
    int oldpath;

    if (inum < 1 || inum > (int) (sizeof(items) / sizeof(items[0])))
    {
        errno = E$BPNum;
        return -1;
    }

    if (path < 3)
    {
        _cgfx_owset(path, 1, 0, 0, items[inum - 1].xsize, items[inum - 1].ysize, fg, bg);
        if (run_item(items[inum - 1].name, &error) == -1)
        {
            _cgfx_owend(path);
            return -1;
        }
        _cgfx_owend(path);
    }
    else
    {
        oldpath = dup(1);
        close(0);
        close(1);
        close(2);
        dup(path);
        dup(path);
        dup(path);
        if (run_item(items[inum - 1].name, &error) == -1)
        {
            close(0);
            close(1);
            close(2);
            dup(oldpath);
            dup(oldpath);
            dup(oldpath);
            close(oldpath);
            return -1;
        }
        close(0);
        close(1);
        close(2);
        dup(oldpath);
        dup(oldpath);
        dup(oldpath);
        close(oldpath);
    }

    if (error == 0)
        return 0;
    errno = error;
    return -1;
}
