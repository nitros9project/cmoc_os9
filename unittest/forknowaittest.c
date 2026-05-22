#include <stdio.h>
#include <os.h>

int main(void)
{
    int pid = -1;
    error_code err;
    static char params[] = "\n";

    printf("forknowaittest: before fork\n");
    err = _os_fork("hello", 1, params, Objct, Prgrm, 0, &pid);
    printf("forknowaittest: after fork err=%d pid=%d\n", err, pid);
    if (err != 0)
        return 1;

    printf("PASS\n");
    return 0;
}
