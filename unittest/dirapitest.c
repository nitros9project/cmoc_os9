#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

static void
test_chdir_open(void)
{
    int fd;

    if (chdir("/dd") == 0)
        printf("%s [PASS] chdir(/dd)\n", __func__);
    else
        printf("%s [FAIL] chdir(/dd)\n", __func__);

    fd = open("startup", FAM_READ);
    if (fd >= 0) {
        printf("%s [PASS] open(startup)\n", __func__);
        close(fd);
    } else
        printf("%s [FAIL] open(startup)\n", __func__);

    if (chdir("/dd/cmds") == 0)
        printf("%s [PASS] chdir(/dd/cmds)\n", __func__);
    else
        printf("%s [FAIL] chdir(/dd/cmds)\n", __func__);

    fd = open("hello", FAM_READ);
    if (fd >= 0) {
        printf("%s [PASS] open(hello)\n", __func__);
        close(fd);
    } else
        printf("%s [FAIL] open(hello)\n", __func__);
}

static void
test_chxdir(void)
{
    if (chxdir("/dd/cmds") == 0)
        printf("%s [PASS] chxdir(/dd/cmds)\n", __func__);
    else
        printf("%s [FAIL] chxdir(/dd/cmds)\n", __func__);
}

int
main(void)
{
    test_chdir_open();
    test_chxdir();
    chdir("/dd");
    chxdir("/dd/cmds");
    return 0;
}
