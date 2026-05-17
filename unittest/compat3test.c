#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void
test_single_helpers(void)
{
    char packed[3];
    long value = 0;

    packed[0] = 0x12;
    packed[1] = 0x34;
    packed[2] = 0x56;

    c3tol(&value, packed);
    if (value == 0x123456L)
        printf("%s [PASS] c3tol()\n", __func__);
    else
        printf("%s [FAIL] c3tol() = %ld\n", __func__, value);

    packed[0] = 0;
    packed[1] = 0;
    packed[2] = 0;
    ltoc3(packed, 0x654321L);
    if ((unsigned char) packed[0] == 0x65 &&
        (unsigned char) packed[1] == 0x43 &&
        (unsigned char) packed[2] == 0x21)
        printf("%s [PASS] ltoc3()\n", __func__);
    else
        printf("%s [FAIL] ltoc3() = %02x %02x %02x\n", __func__,
               (unsigned char) packed[0],
               (unsigned char) packed[1],
               (unsigned char) packed[2]);
}

static void
test_bulk_helpers(void)
{
    char packed[6];
    char roundtrip[6];
    long unpacked[2];

    packed[0] = 0x01;
    packed[1] = 0x02;
    packed[2] = 0x03;
    packed[3] = 0x0a;
    packed[4] = 0x0b;
    packed[5] = 0x0c;

    l3tol(unpacked, packed, 2);
    if (unpacked[0] == 0x010203L && unpacked[1] == 0x0a0b0cL)
        printf("%s [PASS] l3tol()\n", __func__);
    else
        printf("%s [FAIL] l3tol() = %ld %ld\n", __func__,
               unpacked[0], unpacked[1]);

    memset(roundtrip, 0, sizeof(roundtrip));
    ltol3(roundtrip, unpacked, 2);
    if (memncmp(roundtrip, packed, sizeof(packed)) == 0)
        printf("%s [PASS] ltol3()\n", __func__);
    else
        printf("%s [FAIL] ltol3()\n", __func__);
}

int
main(void)
{
    test_single_helpers();
    test_bulk_helpers();
    return 0;
}
