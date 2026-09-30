/* Host tests isolate adapter semantics from kernel/LLVM code generation. */
#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include "cmoc_os9_compat.h"
#include "syscalls.h"

static int error_code, uid_value, calls;
static unsigned int requested_uid;
static const char *line;

int cmoc_os9_get_user(int *uid)
{
    *uid = uid_value;
    return error_code;
}
int cmoc_os9_set_user(unsigned int uid)
{
    requested_uid = uid;
    return error_code;
}
int cmoc_os9_read_line(int path, void *buffer, int *count)
{
    unsigned int length = (unsigned int)strlen(line);
    (void)path;
    ++calls;
    if (error_code)
        return error_code;
    if (length > (unsigned int)*count)
        length = (unsigned int)*count;
    memcpy(buffer, line, length);
    *count = (int)length;
    return 0;
}

int main(void)
{
    char buffer[16];
    uid_value = (short)0xf123;
    assert(getuid() == (uid_t)0xf123);
    error_code = 214;
    errno = 0;
    assert(getuid() == (uid_t)-1 && errno == 214);
    assert(asetuid(123) == -1 && requested_uid == 123 && errno == 214);
    error_code = 0;
    assert(asetuid(0) == 0 && requested_uid == 0);
    line = "test\r";
    memset(buffer, 0x55, sizeof buffer);
    assert(readln(0, buffer, 10) == 5);
    assert(memcmp(buffer, "test\n", 5) == 0 && buffer[5] == 0x55);
    line = "raw";
    assert(readln(0, buffer, 2) == 2 && memcmp(buffer, "ra", 2) == 0);
    line = "";
    assert(readln(0, buffer, 10) == 0);
    error_code = 201;
    assert(readln(0, buffer, 10) == -1 && errno == 201);
    calls = 0;
    assert(readln(0, 0, 0) == 0 && calls == 0);
    assert(readln(0, buffer, -1) == -1 && errno == EINVAL && calls == 0);
    assert(readln(0, 0, 1) == -1 && errno == EINVAL && calls == 0);
    assert(readln(256, buffer, 1) == -1 && errno == EBADF && calls == 0);
    assert(readln(-1, buffer, 1) == -1 && errno == EBADF && calls == 0);
    puts("LLVM OS-9 adapter tests passed");
    return 0;
}
