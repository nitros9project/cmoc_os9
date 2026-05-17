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
    sighandler_t prev;

    got_signal = 0;
    prev = signal(SIGQUIT, handler);
    if (prev == SIG_DFL)
        printf("%s [PASS] signal(set handler)\n", __func__);
    else
        printf("%s [FAIL] signal(set handler)\n", __func__);

    err = _os_getpid(&pid);
    if (err != 0) {
        printf("%s [FAIL] _os_getpid() = %d\n", __func__, err);
        return 1;
    }
    printf("%s [INFO] pid=%d\n", __func__, pid);

    err = _os_send(pid, SIGQUIT);
    if (err == 0 && got_signal == SIGQUIT)
        printf("%s [PASS] signal(delivery)\n", __func__);
    else
        printf("%s [FAIL] signal(delivery) err=%d got=%d\n", __func__, err, got_signal);

    got_signal = 0;
    prev = signal(SIGINT, SIG_IGN);
    if (prev == SIG_DFL)
        printf("%s [PASS] signal(ignore install)\n", __func__);
    else
        printf("%s [FAIL] signal(ignore install)\n", __func__);

    err = _os_send(pid, SIGINT);
    if (err == 0 && got_signal == 0)
        printf("%s [PASS] signal(ignore delivery)\n", __func__);
    else
        printf("%s [FAIL] signal(ignore delivery) err=%d got=%d\n", __func__, err, got_signal);

    signal(SIGQUIT, SIG_DFL);
    signal(SIGINT, SIG_DFL);
    return 0;
}
