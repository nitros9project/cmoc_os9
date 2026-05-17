#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>
#include <unistd.h>
//#include <os.h>

void test_memcpy()
{
    char *src = "test";
    char dst[5];
    int count = 4;
    void *result = memcpy(dst, src, count);
    
    if (dst[0] == 't' && dst[1] == 'e' && dst[2] == 's' && dst[3] == 't')
    {
		printf("%s [PASS] memcpy(%X, %X, %d) = %X\n", __func__, dst, src, count, result);
    }
    else
    {
		printf("%s [FAIL] memcpy(%X, %X, %d) = %X\n", __func__, dst, src, count, result);
    }
}

void test_memset()
{
    char src = 'X';
    char dst[5];
    int count = 5;
    void *result = memset(dst, src, count);
    
    if (dst[0] == 'X' && dst[1] == 'X' && dst[2] == 'X' && dst[3] == 'X' && dst[4] == 'X')
    {
		printf("%s [PASS] memset(%X, %X, %d) = %X\n", __func__, dst, src, count, result);
    }
    else
    {
		printf("%s [FAIL] memset(%X, %X, %d) = %X\n", __func__, dst, src, count, result);
    }
}

void test_memchr()
{
    char *src = "ABCDEFGHIJKLMNOP";
    char locate = 'H';
    int count = strlen(src);
    void *result = memchr(src, locate, count);
    
    if (result == src + 7)
    {
		printf("%s [PASS] memchr(%X, %X, %d) = %X\n", __func__, src, locate, count, result);
    }
    else
    {
		printf("%s [FAIL] memchr(%X, %X, %d) = %X\n", __func__, src, locate, count, result);
    }

    // locate a character that is NOT in the source string
    locate = 'Z';
    result = memchr(src, locate, count);
    
    if (result == 0x0000)
    {
		printf("%s [PASS] memchr(%X, %X, %d) = %X\n", __func__, src, locate, count, result);
    }
    else
    {
		printf("%s [FAIL] memchr(%X, %X, %d) = %X\n", __func__, src, locate, count, result);
	}
}

void test_memcmp()
{
    int result = memcmp("abcd", "abcd", 4);
    if (result == 0)
        printf("%s [PASS] memcmp(equal)\n", __func__);
    else
        printf("%s [FAIL] memcmp(equal)=%d\n", __func__, result);

    result = memcmp("abce", "abcd", 4);
    if (result > 0)
        printf("%s [PASS] memcmp(greater)\n", __func__);
    else
        printf("%s [FAIL] memcmp(greater)=%d\n", __func__, result);
}

void test_memccpy()
{
    char dst[8];
    void *result = memccpy(dst, "abcd", 'c', 4);

    if (result != 0 && dst[0] == 'a' && dst[1] == 'b' && dst[2] == 'c')
        printf("%s [PASS] memccpy(stop)\n", __func__);
    else
        printf("%s [FAIL] memccpy(stop)=%X\n", __func__, result);

    result = memccpy(dst, "abcd", 'z', 4);
    if (result == 0)
        printf("%s [PASS] memccpy(nomatch)\n", __func__);
    else
        printf("%s [FAIL] memccpy(nomatch)=%X\n", __func__, result);
}

void test_sbrk()
{
	int request = 0;
	void *result = sbrk(request);
	printf("sbrk(%d) = $%X\n", request, result);
	request = 128;
	result = sbrk(request);
	printf("sbrk(%d) = $%X\n", request, result);
}

void test_ibrk()
{
	// ibrk() affects _mtop
	int request = 0;
	void *result = ibrk(request);
	printf("ibrk(%d) = $%X\n", request, result);
	request = 128;
	result = ibrk(request); // the old _mtop is returned
	printf("ibrk(%d) = $%X\n", request, result);
	request = 0;
	result = ibrk(request);
	printf("ibrk(%d) = $%X\n", request, result);
}

void test_memglobs()
{
	char *lines[] = {
		"OS-9 Process Structure:",
		"",
		"                       high address",
		"                 |                      | <- sbrk() adds more",
		"                 |                      |    memory here",
		"                 |                      |",
		"                 |----------------------| <- _memend",
		"                 |      parameters      |",
		"                 |----------------------| <- _sttop",
		"                 |                      |",
		"                 |        stack         | <- SP register",
		"Current stack    |                      |",
		"  reservation -> |......................| <- _stbot",
		"                 |          v           |",
		"                 |                      | <- standard I/O buffers",
		"                 |      free memory     |    allocated here",
		"Current top      |                      |",
		"    of data ->   |..........^...........| <- ibrk() changes this",
		"                 |                      |    memory bound upward",
		"                 |   requested memory   |",
		"                 |----------------------| <- _mtop",
		"                 |    uninitialized     |",
		"                 |        data          |",
		"                 |----------------------| <- edata",
		"                 |     initialized      |",
		"                 |        data          |",
		"                 |----------------------|",
		"                 |     direct page      |",
		"    dpsiz        |      variables       |",
		"      v          +----------------------+ <- Y, DP registers",
		"                       low address",
		"",
		NULL
	};

	char **lineptr = lines;
	while (*lineptr != NULL)
	{
		printf("%s\n", *lineptr);
		lineptr++;
	}
	printf("_memend = $%X\n", _memend);
	printf("_sttop  = $%X\n", _sttop);
	printf("_stbot  = $%X\n", _stbot);
	printf("_mtop   = $%X\n", _mtop);
}

void test_malloc()
{
	char *p = (char *)malloc(16);
	printf("p = $%X\n", p);
	free(p);
}

void test_calloc()
{
	char *p = (char *) calloc(8, 1);

	if (p != 0 && p[0] == 0 && p[1] == 0 && p[7] == 0)
		printf("%s [PASS] calloc(8, 1) = $%X\n", __func__, p);
	else
		printf("%s [FAIL] calloc(8, 1) = $%X\n", __func__, p);

	free(p);
}

void test_realloc()
{
	char *p = (char *) malloc(4);
	char *q;

	p[0] = 'A';
	p[1] = 'B';
	p[2] = 'C';
	p[3] = 'D';

	q = (char *) realloc(p, 8);
	if (q != 0 && q[0] == 'A' && q[1] == 'B' && q[2] == 'C' && q[3] == 'D')
		printf("%s [PASS] realloc($%X, 8) = $%X\n", __func__, p, q);
	else
		printf("%s [FAIL] realloc($%X, 8) = $%X\n", __func__, p, q);

	free(q);
}

int main(int argc, char **argv)
{
	test_memglobs();
	test_sbrk();
	test_ibrk();

	test_memcpy();
	test_memset();
	test_memchr();
	test_memcmp();
	test_memccpy();
	test_malloc();
	test_calloc();
	test_realloc();

	return 0;
}
