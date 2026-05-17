#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <string.h>
#include <os.h>

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
        }
    }
    else
    {
	    printf("%s [FAIL] _os_modlink(\"%s\", %d, %d, [%X]) = %d\n", __func__, module, lang, type, modaddr, result);
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
        }
    }
    else
    {
        printf("%s [FAIL] _os_fork(\"%s\", %d, $%X, $%X, $%X, %d, [$%X]) = %d\n", __func__, module, paramsize, paramaddr, lang, type, datasize, &pid, result);
    }
}

int main()
{
    test_modlink_modunlink();
	test_fork();

	return 0;
}
