/* Run under OS-9; exercises real kernel calls, not the host mocks. */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include "cmoc_os9_compat.h"

int main(void)
{
    uid_t uid = getuid();
    char filename[] = "ostestXXXXXX";
    char line[8];
    int fd, failed = 0;
    if (uid == (uid_t)-1 || asetuid((unsigned int)uid) != 0 || getuid() != uid) {
        printf("identity [FAIL] errno=%d\n", errno);
        return 1;
    }
    puts("identity [PASS]");
    fd = mkstemp(filename);
    if (fd < 0) {
        printf("temporary file [FAIL] errno=%d\n", errno);
        return 1;
    }
    if (write(fd, "hi\r", 3) != 3 || lseek(fd, 0, SEEK_SET) != 0 ||
        readln(fd, line, sizeof line) != 3 ||
        line[0] != 'h' || line[1] != 'i' || line[2] != '\n' ||
        readln(fd, line, sizeof line) != 0)
        failed = 1;
    close(fd);
    unlink(filename);
    puts(failed ? "readln [FAIL]" : "readln [PASS]");
    return failed;
}
