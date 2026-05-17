#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

int
main(void)
{
    char *file = "attrwrap.tmp";
    int fd;
    int result;

    unlink(file);
    fd = creat(file, FAP_READ | FAP_WRITE);
    if (fd < 0) {
        printf("%s [FAIL] creat(%s)\n", __func__, file);
        return 1;
    }
    close(fd);

    result = chmod(file, FAP_READ | FAP_PREAD);
    if (result == 0)
        printf("%s [PASS] chmod()\n", __func__);
    else
        printf("%s [FAIL] chmod()=%d\n", __func__, result);

    errno = 0;
    result = chown(file, 0);
    if (result == 0)
        printf("%s [PASS] chown()\n", __func__);
    else if (errno != 0)
        printf("%s [PASS] chown() denied errno=%d\n", __func__, errno);
    else
        printf("%s [FAIL] chown() unexpected=%d\n", __func__, result);

    unlink(file);
    return 0;
}
