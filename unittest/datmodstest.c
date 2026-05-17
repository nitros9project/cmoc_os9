#include <module.h>
#include <stdio.h>

int
main(void)
{
    char *datptr = 0;
    int space = 0;
    int result;
    int failed = 0;

    result = datlink("no_such_data_module", &datptr, &space);
    if (result != 0)
        printf("%s [PASS] datlink(nonexistent)=%d\n", __func__, result);
    else {
        printf("%s [FAIL] datlink(nonexistent)=0\n", __func__);
        if (datptr != 0)
            dunlink(datptr);
        failed = 1;
    }

    return failed;
}
