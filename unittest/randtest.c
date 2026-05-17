#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    int a, b, c;

    srand(1);
    a = rand();
    b = rand();
    c = rand();
    if (a == 16838 && b == 5758 && c == 10113)
        printf("%s [PASS] srand()/rand()\n", __func__);
    else {
        printf("%s [FAIL] srand()/rand()\n", __func__);
        return 1;
    }

    srand(1);
    if (rand() == 16838 && rand() == 5758)
        printf("%s [PASS] srand(reseed)\n", __func__);
    else {
        printf("%s [FAIL] srand(reseed)\n", __func__);
        return 1;
    }

    return 0;
}
