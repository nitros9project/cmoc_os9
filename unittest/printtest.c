#include <stdio.h>
#include <string.h>

extern char *pflong(int c, long value);

static int failed;

static void
expect_string(const char *name, const char *got, const char *expected)
{
    if (strcmp(got, expected) == 0)
        printf("%s [PASS] %s\n", __func__, name);
    else {
        printf("%s [FAIL] %s got=%s expected=%s\n", __func__, name, got, expected);
        failed = 1;
    }
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

    expect_string("pflong(d)", pflong('d', -1234567L), "-1234567");
    expect_string("pflong(u)", pflong('u', 3456789UL), "3456789");
    expect_string("pflong(x)", pflong('x', 0x12ab34UL), "12ab34");
    expect_string("pflong(X)", pflong('X', 0x12ab34UL), "12AB34");
    expect_string("pflong(o)", pflong('o', 8UL), "10");

    printf("printtest [INFO] direct %%ld=%ld\n", 1234567L);
    return failed;
}
