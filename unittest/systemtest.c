#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    int result;

    printf("systemtest: before system\n");
    result = system("hello");
    printf("systemtest: after system result=%d\n", result);

    if (result == 0)
        printf("PASS\n");
    else
        printf("FAIL %d\n", result);

    return 0;
}
