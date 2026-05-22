#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <string.h>
#include <os.h>

static int failed;

void test_modlink_modunlink()
{
    char *module = "mdir";
    void *modaddr;
    int type = Prgrm;
    int lang = Objct;

    error_code result = _os_modlink(module, lang, type, &modaddr);
	if (result == 0)
	{
	    printf("%s [PASS] _os_modlink(\"%s\", %d, %d, [%X]) = %d\n", __func__, module, lang, type, modaddr, result);
        result = _os_modunlink(modaddr);
        if (result == 0)
        {
            printf("%s [PASS] _os_modunlink($%X) = %d\n", __func__, modaddr, result);
        }
        else
        {
            printf("%s [FAIL] _os_modunlink($%X) = %d\n", __func__, modaddr, result);
            failed = 1;
        }
    }
    else
    {
	    printf("%s [FAIL] _os_modlink(\"%s\", %d, %d, [%X]) = %d\n", __func__, module, lang, type, modaddr, result);
        failed = 1;
    }

    modaddr = (void *) 0x1234;
    result = _os_modlink("no_such_module", lang, type, &modaddr);
    if (result != 0 && modaddr == (void *) 0x1234)
        printf("%s [PASS] _os_modlink(nonexistent) = %d\n", __func__, result);
    else {
        printf("%s [FAIL] _os_modlink(nonexistent) = %d addr=$%X\n", __func__, result, modaddr);
        failed = 1;
    }
}

void test_fork()
{
    char *module = "mdir";
    void *modaddr, *paramaddr;
    int paramsize = 1;
    int type = Prgrm;
    int lang = Objct;
    int datasize = 1;
    int pid;

    error_code result = _os_fork(module, paramsize, paramaddr, lang, type, datasize, &pid);
    if (result == 0)
    {
        printf("%s [PASS] _os_fork(\"%s\", %d, $%X, $%X, $%X, %d, [$%X]) = %d\n", __func__, module, paramsize, paramaddr, lang, type, datasize, &pid, result);
        int status;
        int child_pid = _os_wait(&status);
        if (child_pid >= 0)
        {
            printf("%s [PASS] _os_wait([$%X]) -> pid=%d status=%d\n", __func__, &status, child_pid, status);
        }
        else
        {
            printf("%s [FAIL] _os_wait([$%X]) = %d\n", __func__, &status, child_pid);
            failed = 1;
        }
    }
    else
    {
        printf("%s [FAIL] _os_fork(\"%s\", %d, $%X, $%X, $%X, %d, [$%X]) = %d\n", __func__, module, paramsize, paramaddr, lang, type, datasize, &pid, result);
        failed = 1;
    }
}

int main()
{
    test_modlink_modunlink();
	test_fork();

	return failed;
}
