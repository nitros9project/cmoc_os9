#include <module.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static void
test_sync_and_sleep(void)
{
    clock_t slept;

    sync();
    printf("%s [PASS] sync()\n", __func__);

    slept = tsleep(1);
    if ((long) slept >= 0)
        printf("%s [PASS] tsleep(1)=%ld\n", __func__, (long) slept);
    else
        printf("%s [FAIL] tsleep(1)=%ld\n", __func__, (long) slept);
}

static void
test_prerr(void)
{
    printf("%s [INFO] expect OS-9 error text below\n", __func__);
    prerr(STDERR_FILENO, 216);
    printf("%s [PASS] prerr()\n", __func__);
}

static void
test_crc(void)
{
    char text[] = "cmoc-os9";
    unsigned char accum1[3];
    unsigned char accum2[3];

    accum1[0] = 0xff;
    accum1[1] = 0xff;
    accum1[2] = 0xff;
    accum2[0] = 0xff;
    accum2[1] = 0xff;
    accum2[2] = 0xff;

    crc(text, strlen(text), accum1);
    crc(text, strlen(text), accum2);
    if (memncmp((char *) accum1, (char *) accum2, 3) == 0)
        printf("%s [PASS] crc()=%02x%02x%02x\n", __func__,
               accum1[0], accum1[1], accum1[2]);
    else
        printf("%s [FAIL] crc()\n", __func__);
}

int
main(void)
{
    test_sync_and_sleep();
    test_prerr();
    test_crc();
    return 0;
}
