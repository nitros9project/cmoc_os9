#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    int result;

    result = system("hello");

    if (result == 0)
        printf("PASS\n");
    else
        printf("FAIL %d\n", result);

    return result != 0;
}
