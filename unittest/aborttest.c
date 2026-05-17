#include <os.h>
#include <stdio.h>

int
main(void)
{
    int pid = -1;
    int waited_pid = -1;
    int status = -1;
    error_code err;
    static char params[] = "\n";

    err = _os_fork("abortchild", 1, params, Objct, Prgrm, 0, &pid);
    if (err != 0) {
        printf("%s [FAIL] _os_fork()=%d\n", __func__, err);
        return 1;
    }

    waited_pid = _os_wait(&status);
    if (waited_pid > 0 && status != 0)
        printf("%s [PASS] abort() pid=%d status=%d\n", __func__, waited_pid, status);
    else
        printf("%s [FAIL] abort() pid=%d status=%d\n", __func__, waited_pid, status);

    return 0;
}
