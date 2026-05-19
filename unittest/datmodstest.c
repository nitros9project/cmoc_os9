#include <module.h>
#include <stdio.h>

static int failed;

static void
check_int(const char *name, int actual, int expected)
{
    if (actual == expected)
        printf("%s [PASS] actual=%d expected=%d\n", name, actual, expected);
    else {
        printf("%s [FAIL] actual=%d expected=%d\n", name, actual, expected);
        failed = 1;
    }
}

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

static void
test_lockdata(void)
{
    char lock_byte = 0;

    check_int("lockdata zero", lockdata(&lock_byte), 1);
    check_int("lockdata leaves zero unchanged", lock_byte, 0);
    check_int("unlkdata zero", unlkdata(&lock_byte), 0);
    check_int("unlkdata marks unlocked", (unsigned char) lock_byte, 255);

    lock_byte = 5;
    check_int("lockdata nonzero", lockdata(&lock_byte), 6);
    check_int("lockdata leaves nonzero unchanged", lock_byte, 5);
    check_int("unlkdata nonzero", unlkdata(&lock_byte), 5);
    check_int("unlkdata leaves nonzero unchanged", lock_byte, 5);
}

static void
test_datlink_missing(void)
{
    char *datptr = (char *) 0x1234;
    int space = 0x5678;
    int result;

    result = datlink("no_such_data_module", &datptr, &space);
    check_true("datlink nonexistent fails", result != 0);
    check_true("datlink nonexistent keeps datptr", datptr == (char *) 0x1234);
    check_int("datlink nonexistent keeps space", space, 0x5678);
}

int
main(void)
{
    test_lockdata();
    test_datlink_missing();

    return failed;
}
