#include <stdio.h>
#include <string.h>

#include <fcntl.h>

static int failed;

static void check_status(const char *name, error_code result)
{
    if (result == 0) {
        printf("%s [PASS] result=%d\n", name, result);
    } else {
        printf("%s [FAIL] result=%d\n", name, result);
        failed = 1;
    }
}

static void check_error(const char *name, error_code result)
{
    if (result != 0) {
        printf("%s [PASS] result=%d\n", name, result);
    } else {
        printf("%s [FAIL] result=%d\n", name, result);
        failed = 1;
    }
}

static void check_int_equal(const char *name, int actual, int expected)
{
    if (actual == expected) {
        printf("%s [PASS] actual=%d expected=%d\n", name, actual, expected);
    } else {
        printf("%s [FAIL] actual=%d expected=%d\n", name, actual, expected);
        failed = 1;
    }
}

static void check_long_equal(const char *name, long actual, long expected)
{
    if (actual == expected) {
        printf("%s [PASS] actual=%ld expected=%ld\n", name, actual, expected);
    } else {
        printf("%s [FAIL] actual=%ld expected=%ld\n", name, actual, expected);
        failed = 1;
    }
}

static void check_string_equal(const char *name, const char *actual, const char *expected)
{
    if (strcmp(actual, expected) == 0) {
        printf("%s [PASS] actual=\"%s\" expected=\"%s\"\n", name, actual, expected);
    } else {
        printf("%s [FAIL] actual=\"%s\" expected=\"%s\"\n", name, actual, expected);
        failed = 1;
    }
}

static void check_true(const char *name, int condition)
{
    if (condition) {
        printf("%s [PASS]\n", name);
    } else {
        printf("%s [FAIL]\n", name);
        failed = 1;
    }
}

static void test_os_gs_ss_wrappers(void)
{
    static const char file[] = "osgstattest.tmp";
    static const char payload[] = "abcdef\n";
    static const path_id invalid_path = 127;
    path_id path = -1;
    int count;
    int read_count;
    error_code result;
    long size_value = -1;
    long pos_value = -1;
    long legacy_long;
    int ready_value = -1;
    int eof_value = -1;
    char opts[32];
    char legacy_opts[32];
    char devnm[64];
    char legacy_devnm[64];
    char fdbuf[256];
    char readbuf[16];
    int fdcount;

    _os_delete(file, FAM_READ);

    result = _os_create(file, FAM_READ | FAM_WRITE, &path, FAP_READ | FAP_WRITE);
    if (result != 0) {
        printf("%s [FAIL] _os_create result=%d\n", __func__, result);
        failed = 1;
        return;
    }
    printf("%s [PASS] _os_create path=%d\n", __func__, path);

    count = sizeof(payload) - 1;
    result = _os_write(path, (void *) payload, &count);
    check_status("_os_write", result);
    check_int_equal("_os_write count", count, sizeof(payload) - 1);

    result = _os_gs_size(path, &size_value);
    check_status("_os_gs_size", result);
    legacy_long = -1;
    result = getstat(SS_Size, path, &legacy_long, 0);
    check_int_equal("getstat SS_Size", result, 0);
    check_long_equal("_os_gs_size value", size_value, sizeof(payload) - 1);
    check_long_equal("_os_gs_size legacy", size_value, legacy_long);

    result = _os_gs_pos(path, &pos_value);
    check_status("_os_gs_pos after write", result);
    legacy_long = -1;
    result = getstat(SS_Pos, path, &legacy_long, 0);
    check_int_equal("getstat SS_Pos", result, 0);
    check_long_equal("_os_gs_pos value", pos_value, sizeof(payload) - 1);
    check_long_equal("_os_gs_pos legacy", pos_value, legacy_long);

    result = _os_gs_ready(path, &ready_value);
    check_status("_os_gs_ready", result);
    check_int_equal("_os_gs_ready value", ready_value, 0);

    result = _os_gs_eof(path, &eof_value);
    check_status("_os_gs_eof before seek", result);
    check_int_equal("_os_gs_eof before seek value", eof_value, -1);

    fdcount = sizeof(fdbuf);
    memset(fdbuf, 0, sizeof(fdbuf));
    result = _os_gs_fd(path, fdbuf, &fdcount);
    check_status("_os_gs_fd", result);
    check_true("_os_gs_fd count positive", fdcount > 0);

    memset(opts, 0, sizeof(opts));
    memset(legacy_opts, 0, sizeof(legacy_opts));
    result = _os_gs_popt(path, opts);
    check_status("_os_gs_popt", result);
    result = getstat(SS_Opt, path, legacy_opts, 0);
    check_int_equal("getstat SS_Opt", result, 0);
    check_int_equal("_os_gs_popt compare", memcmp(opts, legacy_opts, sizeof(opts)), 0);

    memset(devnm, 0, sizeof(devnm));
    memset(legacy_devnm, 0, sizeof(legacy_devnm));
    result = _os_gs_devnm(path, devnm);
    check_status("_os_gs_devnm", result);
    result = getstat(SS_DevNm, path, legacy_devnm, 0);
    check_int_equal("getstat SS_DevNm", result, 0);
    {
        char *end = legacy_devnm;
        while ((*end & 0x80) == 0) {
            ++end;
        }
        *end &= 0x7f;
        end[1] = '\0';
    }
    check_string_equal("_os_gs_devnm compare", devnm, legacy_devnm);

    result = _os_ss_popt(path, opts);
    check_status("_os_ss_popt", result);
    result = setstat(SS_Opt, path, legacy_opts, 0, 0);
    check_int_equal("setstat SS_Opt", result, 0);

    result = _os_seek(path, 0);
    check_status("_os_seek 0", result);

    result = _os_gs_pos(path, &pos_value);
    check_status("_os_gs_pos after seek", result);
    check_long_equal("_os_gs_pos after seek value", pos_value, 0);

    result = _os_gs_eof(path, &eof_value);
    check_status("_os_gs_eof after seek", result);
    check_int_equal("_os_gs_eof after seek value", eof_value, 0);

    memset(readbuf, 0, sizeof(readbuf));
    read_count = sizeof(payload) - 1;
    result = _os_read(path, readbuf, &read_count);
    check_status("_os_read", result);
    check_int_equal("_os_read count", read_count, sizeof(payload) - 1);
    check_string_equal("_os_read payload", readbuf, payload);

    result = _os_gs_pos(path, &pos_value);
    check_status("_os_gs_pos after read", result);
    check_long_equal("_os_gs_pos after read value", pos_value, sizeof(payload) - 1);

    result = _os_gs_eof(path, &eof_value);
    check_status("_os_gs_eof after read", result);
    check_int_equal("_os_gs_eof after read value", eof_value, -1);

    result = _os_getstat(SS_Pos, path, &legacy_long, 0);
    check_status("_os_getstat SS_Pos", result);
    check_long_equal("_os_getstat SS_Pos value", legacy_long, sizeof(payload) - 1);

    ready_value = 0;
    result = _os_getstat(SS_EOF, path, &ready_value, 0);
    check_error("_os_getstat SS_EOF", result);
    check_int_equal("_os_getstat SS_EOF value", ready_value, 0);

    result = _os_ss_reset(path);
    check_status("_os_ss_reset", result);

    result = _os_ss_relea(path);
    check_error("_os_ss_relea", result);

    result = _os_close(path);
    check_status("_os_close", result);

    result = _os_gs_pos(path, &pos_value);
    check_error("_os_gs_pos after close", result);

    result = _os_gs_popt(path, opts);
    check_error("_os_gs_popt after close", result);

    result = _os_getstat(SS_Pos, path, &legacy_long, 0);
    check_error("_os_getstat SS_Pos after close", result);

    path = -1;

    result = _os_delete(file, FAM_READ);
    check_status("_os_delete", result);

    result = _os_gs_size(invalid_path, &size_value);
    check_error("_os_gs_size invalid path", result);

    result = _os_gs_ready(invalid_path, &ready_value);
    check_error("_os_gs_ready invalid path", result);

    result = _os_gs_eof(invalid_path, &eof_value);
    check_error("_os_gs_eof invalid path", result);

    result = _os_gs_devnm(invalid_path, devnm);
    check_error("_os_gs_devnm invalid path", result);

    fdcount = sizeof(fdbuf);
    result = _os_gs_fd(invalid_path, fdbuf, &fdcount);
    check_error("_os_gs_fd invalid path", result);

    result = _os_ss_popt(invalid_path, opts);
    check_error("_os_ss_popt invalid path", result);

    result = _os_ss_pfd(invalid_path, fdbuf);
    check_error("_os_ss_pfd invalid path", result);

    result = _os_ss_sendsig(invalid_path, 0);
    check_error("_os_ss_sendsig invalid path", result);

    result = _os_ss_ticks(invalid_path, opts);
    check_error("_os_ss_ticks invalid path", result);

    result = _os_ss_reset(invalid_path);
    check_error("_os_ss_reset invalid path", result);

    result = _os_ss_relea(invalid_path);
    check_error("_os_ss_relea invalid path", result);

    result = _os_setstat(SS_Reset, invalid_path, 0, 0, 0);
    check_error("_os_setstat SS_Reset invalid path", result);
}

int main(void)
{
    test_os_gs_ss_wrappers();
    return failed;
}
