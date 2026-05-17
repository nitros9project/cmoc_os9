#include <stdio.h>
#include <os.h>

int main(void)
{
    int pid = -1;
    int waited_pid = -1;
    int status = -1;
    error_code err;
    static char params[] = "\n";

    printf("forkhellotest: before fork\n");
    err = _os_fork("hello", 1, params, Objct, Prgrm, 0, &pid);
    if (err != 0)
        return 1;

    printf("forkhellotest: after fork err=%d pid=%d\n", err, pid);

    waited_pid = _os_wait(&status);
    printf("forkhellotest: after wait pid=%d status=%d\n", waited_pid, status);
    if (waited_pid < 0)
        return 1;

    printf("PASS\n");
    return 0;
}
