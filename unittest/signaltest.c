#include <os.h>
#include <signal.h>
#include <stdio.h>

static int got_signal;
static int failed;

static void
check_true(const char *name, int condition)
{
    if (condition)
        printf("%s [PASS]\n", name);
    else {
        printf("%s [FAIL]\n", name);
        failed = 1;
    }
}

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
    check_true("signaltest signal(set handler)", prev == SIG_DFL);

    err = _os_getpid(&pid);
    if (err != 0) {
        printf("%s [FAIL] _os_getpid() = %d\n", __func__, err);
        return 1;
    }
    printf("%s [INFO] pid=%d\n", __func__, pid);

    err = _os_send(pid, SIGQUIT);
    if (err == 0 && got_signal == SIGQUIT)
        printf("%s [PASS]\n", "signaltest signal(delivery)");
    else {
        printf("%s [FAIL] err=%d got=%d\n", "signaltest signal(delivery)", err, got_signal);
        failed = 1;
    }

    got_signal = 0;
    prev = signal(SIGQUIT, handler);
    check_true("signaltest signal(reset handler)", prev == SIG_DFL);

    err = kill(pid, SIGQUIT);
    if (err == 0 && got_signal == SIGQUIT)
        printf("%s [PASS]\n", "signaltest kill(delivery)");
    else {
        printf("%s [FAIL] err=%d got=%d\n", "signaltest kill(delivery)", err, got_signal);
        failed = 1;
    }

    got_signal = 0;
    prev = signal(SIGINT, SIG_IGN);
    check_true("signaltest signal(ignore install)", prev == SIG_DFL);

    err = _os_send(pid, SIGINT);
    if (err == 0 && got_signal == 0)
        printf("%s [PASS]\n", "signaltest signal(ignore delivery)");
    else {
        printf("%s [FAIL] err=%d got=%d\n", "signaltest signal(ignore delivery)", err, got_signal);
        failed = 1;
    }

    signal(SIGQUIT, SIG_DFL);
    signal(SIGINT, SIG_DFL);
    return failed;
}
