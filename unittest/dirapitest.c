#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

static int failed;

static void check_true(const char *name, int condition)
{
    if (condition)
        printf("%s [PASS]\n", name);
    else {
        printf("%s [FAIL]\n", name);
        failed = 1;
    }
}

static void
test_chdir_open(void)
{
    int fd;
    int missing;

    check_true("test_chdir_open chdir(/dd)", chdir("/dd") == 0);

    fd = open("startup", FAM_READ);
    if (fd >= 0) {
        printf("%s [PASS] open(startup)\n", __func__);
        close(fd);
    } else
        check_true("test_chdir_open open(startup)", 0);

    missing = open("hello", FAM_READ);
    check_true("test_chdir_open open(hello) fails in /dd", missing < 0);
    if (missing >= 0)
        close(missing);

    check_true("test_chdir_open chdir(/dd/cmds)", chdir("/dd/cmds") == 0);

    fd = open("hello", FAM_READ);
    if (fd >= 0) {
        printf("%s [PASS] open(hello)\n", __func__);
        close(fd);
    } else
        check_true("test_chdir_open open(hello)", 0);

    missing = open("startup", FAM_READ);
    check_true("test_chdir_open open(startup) fails in /dd/cmds", missing < 0);
    if (missing >= 0)
        close(missing);
}

static void
test_chxdir(void)
{
    check_true("test_chxdir chxdir(/dd/cmds)", chxdir("/dd/cmds") == 0);
}

int
main(void)
{
    test_chdir_open();
    test_chxdir();
    chdir("/dd");
    chxdir("/dd/cmds");
    return failed;
}
