#include <unistd.h>
#include <fcntl.h>
#include <os.h>

static void say(const char *s)
{
    int n = 0;
    while (s[n] != '\0')
        ++n;
    write(1, (void *) s, n);
}

int main()
{
    path_id path = -1;
    error_code rc = _os_open("nonexistentfile", FAM_READ, &path);

    if (rc == E$PNNF || rc == E$MNF)
        say("osopenerrtest [PASS] rc\n");
    else
        say("osopenerrtest [FAIL] rc\n");

    if (path == -1)
        say("osopenerrtest [PASS] path\n");
    else
        say("osopenerrtest [FAIL] path\n");

    return 0;
}
