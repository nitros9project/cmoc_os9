#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

extern int getsp(void);
extern long gs_size(int path);
extern long gs_pos(int path);
extern int gs_rdy(int path);
extern int gs_eof(int path);
extern int gs_opt(int path, void *opts);
extern int gs_devn(int path, char *name);
extern int gs_gfd(int path, void *buffer, int count);

static const char test_file[] = "gtest.tmp";
static int failed;

static void check_true(const char *name, int condition)
{
    if (condition)
        printf("%s [PASS]\n", name);
    else {
        printf("%s [FAIL]\n", name);
        failed = 1;
    }
}

static void check_int_equal(const char *name, int actual, int expected)
{
    if (actual == expected)
        printf("%s [PASS] actual=%d expected=%d\n", name, actual, expected);
    else {
        printf("%s [FAIL] actual=%d expected=%d\n", name, actual, expected);
        failed = 1;
    }
}

static void check_long_equal(const char *name, long actual, long expected)
{
    if (actual == expected)
        printf("%s [PASS] actual=%ld expected=%ld\n", name, actual, expected);
    else {
        printf("%s [FAIL] actual=%ld expected=%ld\n", name, actual, expected);
        failed = 1;
    }
}

static void check_legacy_getstats(int fd, long expected_size)
{
    long size_value;
    long pos_value;
    int ready_value;
    int eof_value;
    char opts[32];
    char devnm[64];
    char fdbuf[256];

    size_value = gs_size(fd);
    check_long_equal("gtest _gs_size", size_value, expected_size);

    pos_value = gs_pos(fd);
    check_long_equal("gtest _gs_pos", pos_value, expected_size);

    ready_value = gs_rdy(fd);
    check_true("gtest _gs_rdy", ready_value >= 0);

    eof_value = gs_eof(fd);
    check_true("gtest _gs_eof", eof_value == 0 || eof_value == -1);

    memset(opts, 0, sizeof(opts));
    check_int_equal("gtest _gs_opt", gs_opt(fd, opts), 0);

    memset(devnm, 0, sizeof(devnm));
    check_int_equal("gtest _gs_devn", gs_devn(fd, devnm), 0);
    check_true("gtest _gs_devn value", devnm[0] != '\0');

    memset(fdbuf, 0, sizeof(fdbuf));
    check_int_equal("gtest _gs_gfd", gs_gfd(fd, fdbuf, sizeof(fdbuf)), 0);
}

static void test_getpid_getsp(void)
{
    int pid;
    int sp;

    pid = getpid();
    check_true("gtest getpid", pid > 0);

    sp = getsp();
    check_true("gtest getsp", sp != 0);
}

static void test_getw(void)
{
    FILE *fp;
    unsigned char bytes[2];
    int word;

    unlink(test_file);
    fp = fopen(test_file, "w");
    if (fp == 0) {
        printf("%s [FAIL] fopen(write)\n", __func__);
        failed = 1;
        return;
    }

    bytes[0] = 0x12;
    bytes[1] = 0x34;
    check_true("gtest fwrite word bytes", fwrite(bytes, 1, sizeof(bytes), fp) == sizeof(bytes));
    fclose(fp);

    fp = fopen(test_file, "r");
    if (fp == 0) {
        printf("%s [FAIL] fopen(read)\n", __func__);
        unlink(test_file);
        failed = 1;
        return;
    }

    word = getw(fp);
    check_int_equal("gtest getw", word, 0x1234);
    check_legacy_getstats(fileno(fp), sizeof(bytes));

    fclose(fp);
    unlink(test_file);
}

int main(void)
{
    test_getpid_getsp();
    test_getw();
    return failed;
}
