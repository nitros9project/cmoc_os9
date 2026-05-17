#include <os.h>
#include <signal.h>
#include <stdio.h>

static int got_signal;

static void
handler(int signo)
{
    got_signal = signo;
}

int
main(void)
{
    int pid = -1;
    error_code err;

    got_signal = 0;
    err = intercept(handler);
    if (err == 0)
        printf("%s [PASS] intercept(set handler)\n", __func__);
    else {
        printf("%s [FAIL] intercept(set handler) = %d\n", __func__, err);
        return 1;
    }

    err = _os_getpid(&pid);
    if (err != 0) {
        printf("%s [FAIL] _os_getpid() = %d\n", __func__, err);
        return 1;
    }
    printf("%s [INFO] pid=%d\n", __func__, pid);

    err = _os_send(pid, SIGQUIT);
    if (err == 0 && got_signal == SIGQUIT)
        printf("%s [PASS] intercept(delivery)\n", __func__);
    else
        printf("%s [FAIL] intercept(delivery) err=%d got=%d\n", __func__, err, got_signal);

    return 0;
}
