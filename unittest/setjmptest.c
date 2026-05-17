#include <stdio.h>
#include <setjmp.h>

static jmp_buf env;

int main(void)
{
    int value = setjmp(env);

    if (value == 0) {
        longjmp(env, 7);
        printf("FAIL\n");
        return 1;
    }

    if (value == 7) {
        printf("PASS\n");
        return 0;
    }

    printf("FAIL value=%d\n", value);
    return 1;
}
