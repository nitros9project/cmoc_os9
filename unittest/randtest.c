#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    srand(1);

    if (rand() == 16838 &&
        rand() == 5758 &&
        rand() == 10113)
        printf("%s [PASS] srand()/rand()\n", __func__);
    else
        printf("%s [FAIL] srand()/rand()\n", __func__);

    return 0;
}
