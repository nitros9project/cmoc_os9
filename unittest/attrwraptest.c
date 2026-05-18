#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

int
main(void)
{
    char *file = "attrwrap.tmp";
    int fd;
    int result;
    int failed = 0;

    unlink(file);
    fd = creat(file, FAP_READ | FAP_WRITE);
    if (fd < 0) {
        printf("%s [FAIL] creat(%s)\n", __func__, file);
        return 1;
    }
    close(fd);

    result = chmod(file, FAP_READ | FAP_PREAD | FAP_WRITE | FAP_PWRITE);
    if (result == 0)
        printf("%s [PASS] chmod()\n", __func__);
    else {
        printf("%s [FAIL] chmod()=%d\n", __func__, result);
        failed = 1;
    }

    errno = 0;
    result = chown(file, 0);
    if (result == 0)
        printf("%s [PASS] chown()\n", __func__);
    else if (errno != 0)
        printf("%s [PASS] chown() denied errno=%d\n", __func__, errno);
    else {
        printf("%s [FAIL] chown() unexpected=%d\n", __func__, result);
        failed = 1;
    }

    result = unlink(file);
    if (result == 0)
        printf("%s [PASS] cleanup unlink()\n", __func__);
    else {
        printf("%s [FAIL] cleanup unlink()=%d errno=%d\n", __func__, result, errno);
        failed = 1;
    }

    return failed;
}
