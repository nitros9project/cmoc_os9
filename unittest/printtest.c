#include <stdio.h>
#include <string.h>

static void
expect_string(const char *name, const char *got, const char *expected)
{
    if (strcmp(got, expected) == 0)
        printf("%s [PASS] %s\n", __func__, name);
    else
        printf("%s [FAIL] %s got=%s expected=%s\n", __func__, name, got, expected);
}

int
main(void)
{
    char buf[32];

    sprintf(buf, "%ld", 1234567L);
    expect_string("%ld positive", buf, "1234567");

    sprintf(buf, "%ld", -1234567L);
    expect_string("%ld negative", buf, "-1234567");

    sprintf(buf, "%lu", 3456789UL);
    expect_string("%lu", buf, "3456789");

    sprintf(buf, "%lx", 0x12ab34UL);
    expect_string("%lx", buf, "12ab34");

    printf("printtest [INFO] direct %%ld=%ld\n", 1234567L);
    return 0;
}
