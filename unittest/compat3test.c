#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

static void
check_long(const char *name, long actual, long expected)
{
    if (actual == expected)
        printf("%s [PASS]\n", name);
    else {
        printf("%s [FAIL] actual=%ld expected=%ld\n", name, actual, expected);
        failed = 1;
    }
}

static void
check_packed3(const char *name, const char *actual, const char *expected, int count)
{
    if (memncmp(actual, expected, count * 3) == 0)
        printf("%s [PASS]\n", name);
    else {
        printf("%s [FAIL]\n", name);
        failed = 1;
    }
}

static void
test_single_helpers(void)
{
    char packed[3];
    long value = 0;

    packed[0] = 0x12;
    packed[1] = 0x34;
    packed[2] = 0x56;

    c3tol(&value, packed);
    check_long("compat3 c3tol basic", value, 0x123456L);

    packed[0] = 0xff;
    packed[1] = 0xee;
    packed[2] = 0xcc;
    c3tol(&value, packed);
    check_long("compat3 c3tol high-bit zero-extend", value, 0x00ffeeccL);

    packed[0] = 0;
    packed[1] = 0;
    packed[2] = 0;
    ltoc3(packed, 0x654321L);
    check_true("compat3 ltoc3 basic",
               (unsigned char) packed[0] == 0x65 &&
               (unsigned char) packed[1] == 0x43 &&
               (unsigned char) packed[2] == 0x21);

    ltoc3(packed, 0xff654321L);
    check_true("compat3 ltoc3 drops high byte",
               (unsigned char) packed[0] == 0x65 &&
               (unsigned char) packed[1] == 0x43 &&
               (unsigned char) packed[2] == 0x21);
}

static void
test_bulk_helpers(void)
{
    char packed[6];
    char roundtrip[6];
    char sentinel[6];
    long unpacked[2];

    packed[0] = 0x01;
    packed[1] = 0x02;
    packed[2] = 0x03;
    packed[3] = 0x0a;
    packed[4] = 0x0b;
    packed[5] = 0x0c;

    l3tol(unpacked, packed, 2);
    check_true("compat3 l3tol bulk",
               unpacked[0] == 0x010203L && unpacked[1] == 0x0a0b0cL);

    memset(roundtrip, 0, sizeof(roundtrip));
    ltol3(roundtrip, unpacked, 2);
    check_packed3("compat3 ltol3 bulk", roundtrip, packed, 2);

    memset(sentinel, 0x5a, sizeof(sentinel));
    ltol3(sentinel, unpacked, 0);
    check_true("compat3 ltol3 zero count", (unsigned char) sentinel[0] == 0x5a);

    unpacked[0] = 0x11111111L;
    l3tol(unpacked, packed, 0);
    check_long("compat3 l3tol zero count", unpacked[0], 0x11111111L);
}

int
main(void)
{
    test_single_helpers();
    test_bulk_helpers();
    return failed;
}
