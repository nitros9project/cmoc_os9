#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

static const char fdopen_read_tmp[] = "fdopen_read.tmp";
static const char fdopen_write_tmp[] = "fdopen_write.tmp";
static const char freopen_old_tmp[] = "freopen_old.tmp";
static const char freopen_new_tmp[] = "freopen_new.tmp";
static const char freopen_fail_tmp[] = "freopen_fail.tmp";
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

static void test_fdopen_read(void)
{
    int fd;
    FILE *fp;
    char buf[16];
    int n;

    unlink(fdopen_read_tmp);
    fd = creat(fdopen_read_tmp, FAP_READ | FAP_WRITE);
    if (fd < 0) {
        printf("%s [FAIL] creat\n", __func__);
        failed = 1;
        return;
    }
    n = write(fd, "abc\r", 4);
    close(fd);
    check_true("test_fdopen_read write()", n == 4);

    fd = open(fdopen_read_tmp, FAM_READ);
    if (fd < 0) {
        printf("%s [FAIL] open\n", __func__);
        unlink(fdopen_read_tmp);
        failed = 1;
        return;
    }

    fp = fdopen(fd, "r");
    check_true("test_fdopen_read fdopen()", fp != 0);
    if (fp != 0) {
        memset(buf, 0, sizeof(buf));
        check_true("test_fdopen_read fgets()",
                   fgets(buf, sizeof(buf), fp) != 0 && strcmp(buf, "abc\r") == 0);
        check_true("test_fdopen_read eof",
                   fgets(buf, sizeof(buf), fp) == 0 && feof(fp) != 0);
        fclose(fp);
    } else
        close(fd);

    unlink(fdopen_read_tmp);
}

static void test_fdopen_write(void)
{
    int fd;
    FILE *fp;
    char buf[16];

    unlink(fdopen_write_tmp);
    fd = creat(fdopen_write_tmp, FAP_READ | FAP_WRITE);
    if (fd < 0) {
        printf("%s [FAIL] creat\n", __func__);
        failed = 1;
        return;
    }

    fp = fdopen(fd, "w");
    check_true("test_fdopen_write fdopen()", fp != 0);
    if (fp != 0) {
        check_true("test_fdopen_write fputs()", fputs("xyz\r", fp) >= 0);
        check_true("test_fdopen_write fclose()", fclose(fp) == 0);
    } else
        close(fd);

    fp = fopen(fdopen_write_tmp, "r");
    check_true("test_fdopen_write fopen(readback)", fp != 0);
    if (fp != 0) {
        memset(buf, 0, sizeof(buf));
        check_true("test_fdopen_write fgets()",
                   fgets(buf, sizeof(buf), fp) != 0 && strcmp(buf, "xyz\r") == 0);
        fclose(fp);
    }

    unlink(fdopen_write_tmp);
}

static void test_fdopen_badmode(void)
{
    int fd;
    FILE *fp;

    unlink(fdopen_read_tmp);
    fd = open(".", FAM_READ);
    check_true("test_fdopen_badmode open(dir)", fd >= 0);
    if (fd < 0)
        return;

    fp = fdopen(fd, "q");
    check_true("test_fdopen_badmode fdopen(q)", fp == 0);
    close(fd);
}

static void test_fopen_badmode(void)
{
    FILE *fp;

    unlink(fdopen_write_tmp);
    fp = fopen(fdopen_write_tmp, "q");
    check_true("test_fopen_badmode fopen(q)", fp == 0);
    if (fp != 0)
        fclose(fp);
    unlink(fdopen_write_tmp);
}

static void test_freopen(void)
{
    FILE *fp;
    FILE *reopened;
    char buf[16];

    unlink(freopen_old_tmp);
    unlink(freopen_new_tmp);

    fp = fopen(freopen_old_tmp, "w");
    check_true("test_freopen fopen(old)", fp != 0);
    if (fp == 0)
        return;

    check_true("test_freopen old write", fputs("old\r", fp) >= 0);
    check_true("test_freopen old fflush", fflush(fp) == 0);

    reopened = freopen(freopen_new_tmp, "w+", fp);
    check_true("test_freopen freopen()", reopened == fp && reopened != 0);
    if (reopened != 0) {
        check_true("test_freopen new write", fputs("new\r", reopened) >= 0);
        check_true("test_freopen rewind", (rewind(reopened), ftell(reopened) == 0L));
        memset(buf, 0, sizeof(buf));
        check_true("test_freopen readback",
                   fgets(buf, sizeof(buf), reopened) != 0 && strcmp(buf, "new\r") == 0);
        fclose(reopened);
    }

    fp = fopen(freopen_old_tmp, "r");
    check_true("test_freopen old file preserved", fp != 0);
    if (fp != 0) {
        memset(buf, 0, sizeof(buf));
        check_true("test_freopen old content",
                   fgets(buf, sizeof(buf), fp) != 0 && strcmp(buf, "old\r") == 0);
        fclose(fp);
    }

    unlink(freopen_old_tmp);
    unlink(freopen_new_tmp);
}

static void test_freopen_flushes_pending_write(void)
{
    FILE *fp;
    char buf[16];

    unlink(freopen_old_tmp);
    unlink(freopen_new_tmp);

    fp = fopen(freopen_old_tmp, "w");
    check_true("test_freopen_flushes fopen(old)", fp != 0);
    if (fp == 0)
        return;

    check_true("test_freopen_flushes buffered write", fputs("stay\r", fp) >= 0);
    check_true("test_freopen_flushes freopen()",
               freopen(freopen_new_tmp, "w", fp) == fp);
    if (fp != 0)
        fclose(fp);

    fp = fopen(freopen_old_tmp, "r");
    check_true("test_freopen_flushes old read", fp != 0);
    if (fp != 0) {
        memset(buf, 0, sizeof(buf));
        check_true("test_freopen_flushes old content",
                   fgets(buf, sizeof(buf), fp) != 0 && strcmp(buf, "stay\r") == 0);
        fclose(fp);
    }

    unlink(freopen_old_tmp);
    unlink(freopen_new_tmp);
}

static void test_freopen_failure_keeps_stream_usable(void)
{
    FILE *fp;
    FILE *reopened;
    char buf[16];

    unlink(freopen_fail_tmp);
    fp = fopen(freopen_fail_tmp, "w+");
    check_true("test_freopen_failure fopen()", fp != 0);
    if (fp == 0)
        return;

    check_true("test_freopen_failure initial write", fputs("orig\r", fp) >= 0);
    check_true("test_freopen_failure rewind", (rewind(fp), ftell(fp) == 0L));
    reopened = freopen("/D0/NO/SUCH/PATH", "r", fp);
    check_true("test_freopen_failure result", reopened == 0);

    fp = fopen(freopen_fail_tmp, "r");
    check_true("test_freopen_failure reopen old path", fp != 0);
    if (fp != 0) {
        memset(buf, 0, sizeof(buf));
        check_true("test_freopen_failure old content",
                   fgets(buf, sizeof(buf), fp) != 0 && strcmp(buf, "orig\r") == 0);
        fclose(fp);
    }

    unlink(freopen_fail_tmp);
}

int main(void)
{
    test_fdopen_read();
    test_fdopen_write();
    test_fdopen_badmode();
    test_fopen_badmode();
    test_freopen();
    test_freopen_flushes_pending_write();
    test_freopen_failure_keeps_stream_usable();
    return failed;
}
