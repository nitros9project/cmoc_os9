#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int failed;

static void fail_ptr(const char *name, const char *detail, void *actual, void *expected)
{
	printf("%s [FAIL] %s actual=%X expected=%X\n", name, detail, actual, expected);
	failed = 1;
}

static void fail_int(const char *name, const char *detail, int actual, int expected)
{
	printf("%s [FAIL] %s actual=%d expected=%d\n", name, detail, actual, expected);
	failed = 1;
}

static void test_memcpy(void)
{
	char src[] = "test";
	char dst[8];
	void *result;

	memset(dst, 0x5A, sizeof(dst));
	result = memcpy(dst, src, 4);
	if (result != dst)
		fail_ptr(__func__, "return", result, dst);
	else if (memcmp(dst, "test", 4) != 0)
		fail_int(__func__, "bytes", memcmp(dst, "test", 4), 0);
	else if ((unsigned char) dst[4] != 0x5A)
		fail_int(__func__, "sentinel", (unsigned char) dst[4], 0x5A);
	else
		printf("%s [PASS]\n", __func__);
}

static void test_memset(void)
{
	char dst[5];
	void *result = memset(dst, 'X', sizeof(dst));

	if (result != dst)
		fail_ptr(__func__, "return", result, dst);
	else if (dst[0] != 'X' || dst[1] != 'X' || dst[2] != 'X' || dst[3] != 'X' || dst[4] != 'X')
		fail_int(__func__, "fill", 0, 1);
	else
		printf("%s [PASS]\n", __func__);
}

static void test_memchr(void)
{
	char src[] = "ABCDEFGHIJKLMNOP";
	void *result = memchr(src, 'H', strlen(src));

	if (result != src + 7)
		fail_ptr(__func__, "hit", result, src + 7);
	else if (memchr(src, 'Z', strlen(src)) != NULL)
		fail_ptr(__func__, "miss", memchr(src, 'Z', strlen(src)), NULL);
	else
		printf("%s [PASS]\n", __func__);
}

static void test_memcmp(void)
{
	int result = memcmp("abcd", "abcd", 4);
	if (result != 0)
		fail_int(__func__, "equal", result, 0);
	else if (memcmp("abce", "abcd", 4) <= 0)
		fail_int(__func__, "greater", memcmp("abce", "abcd", 4), 1);
	else if (memcmp("abcd", "abce", 4) >= 0)
		fail_int(__func__, "less", memcmp("abcd", "abce", 4), -1);
	else
		printf("%s [PASS]\n", __func__);
}

static void test_memccpy(void)
{
	char dst[8];
	void *result;

	memset(dst, 0, sizeof(dst));
	result = memccpy(dst, "abcd", 'c', 4);
	if (result != dst + 3)
		fail_ptr(__func__, "stop return", result, dst + 3);
	else if (memcmp(dst, "abc", 3) != 0)
		fail_int(__func__, "stop bytes", memcmp(dst, "abc", 3), 0);
	else if (dst[3] != 0)
		fail_int(__func__, "stop sentinel", (unsigned char) dst[3], 0);
	else {
		memset(dst, 0, sizeof(dst));
		result = memccpy(dst, "abcd", 'z', 4);
		if (result != NULL)
			fail_ptr(__func__, "nomatch return", result, NULL);
		else if (memcmp(dst, "abcd", 4) != 0)
			fail_int(__func__, "nomatch bytes", memcmp(dst, "abcd", 4), 0);
		else
			printf("%s [PASS]\n", __func__);
	}
}

static void test_sbrk(void)
{
	void *before = sbrk(0);
	void *after = sbrk(16);

	if (before == (void *) -1 || after == (void *) -1)
		fail_ptr(__func__, "error", after, before);
	else if (after != before)
		fail_ptr(__func__, "increment return", after, before);
	else if (sbrk(0) != (char *) before + 16)
		fail_ptr(__func__, "new break", sbrk(0), (char *) before + 16);
	else
		printf("%s [PASS]\n", __func__);
}

static void test_ibrk(void)
{
	void *before = ibrk(0);
	void *old = ibrk(16);
	void *after = ibrk(0);

	if (before == (void *) -1 || old == (void *) -1 || after == (void *) -1)
		fail_ptr(__func__, "error", after, before);
	else if (old != before)
		fail_ptr(__func__, "increment return", old, before);
	else if (after != (char *) before + 16)
		fail_ptr(__func__, "new break", after, (char *) before + 16);
	else
		printf("%s [PASS]\n", __func__);
}

static void test_brk_unbrk(void)
{
	char *before = (char *) sbrk(0);
	char *target;
	void *result;

	if (before == (char *) -1) {
		fail_ptr(__func__, "initial break", before, (void *) 1);
		return;
	}

	target = before + 16;
	result = brk(target);
	if (result == (void *) -1)
		fail_ptr(__func__, "brk grow", result, (void *) 1);
	else if (sbrk(0) != target)
		fail_ptr(__func__, "after brk", sbrk(0), target);
	else {
		result = unbrk(16);
		if (result == (void *) -1)
			fail_ptr(__func__, "unbrk shrink", result, (void *) 1);
		else if (sbrk(0) != before)
			fail_ptr(__func__, "after unbrk", sbrk(0), before);
		else
			printf("%s [PASS]\n", __func__);
	}
}

static void test_memglobs(void)
{
	if (_memend == NULL || _sttop == NULL || _stbot == NULL || _mtop == NULL)
		fail_ptr(__func__, "globals", _memend, _mtop);
	else if (!(_memend >= _sttop && _sttop >= _stbot && _stbot >= _mtop))
		fail_int(__func__, "ordering", 0, 1);
	else
		printf("%s [PASS]\n", __func__);
}

static void test_malloc(void)
{
	char *p = (char *) malloc(16);
	if (p == NULL)
		fail_ptr(__func__, "malloc(16)", p, (void *) 1);
	else {
		p[0] = 'A';
		p[15] = 'Z';
		if (p[0] != 'A' || p[15] != 'Z')
			fail_int(__func__, "readback", 0, 1);
		else
			printf("%s [PASS]\n", __func__);
		free(p);
	}
}

static void test_calloc(void)
{
	char *p = (char *) calloc(8, 1);

	if (p == NULL)
		fail_ptr(__func__, "calloc(8,1)", p, (void *) 1);
	else if (p[0] != 0 || p[1] != 0 || p[7] != 0)
		fail_int(__func__, "zero fill", 0, 1);
	else {
		printf("%s [PASS]\n", __func__);
		free(p);
	}
}

static void test_realloc(void)
{
	char *p = (char *) malloc(4);
	char *q;

	if (p == NULL) {
		fail_ptr(__func__, "malloc(4)", p, (void *) 1);
		return;
	}

	p[0] = 'A';
	p[1] = 'B';
	p[2] = 'C';
	p[3] = 'D';

	q = (char *) realloc(p, 8);
	if (q == NULL)
		fail_ptr(__func__, "realloc grow", q, (void *) 1);
	else if (q[0] != 'A' || q[1] != 'B' || q[2] != 'C' || q[3] != 'D')
		fail_int(__func__, "preserve grow", 0, 1);
	else {
		q[4] = 'E';
		q[5] = 'F';
		if (q[4] != 'E' || q[5] != 'F')
			fail_int(__func__, "grow write", 0, 1);
		else
			printf("%s [PASS]\n", __func__);
		free(q);
	}
}

int main(void)
{
	test_memglobs();
	test_sbrk();
	test_ibrk();
	test_brk_unbrk();
	test_memcpy();
	test_memset();
	test_memchr();
	test_memcmp();
	test_memccpy();
	test_malloc();
	test_calloc();
	test_realloc();
	return failed;
}
