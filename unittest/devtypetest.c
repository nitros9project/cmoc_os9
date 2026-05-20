#include <stdio.h>
#include <unistd.h>

static int failed;

static void
check_true(const char *name, int condition)
{
    if (condition)
        printf("%s [PASS]\n", name);
    else {
        printf("%s [FAIL]\n", name);
        failed = 1;
    }
}

int
main(void)
{
    int type = devtyp(STDIN_FILENO);

    check_true("devtyp stdin succeeds", type >= 0);
    check_true("isatty stdin", isatty(STDIN_FILENO) != 0);

    return failed;
}
