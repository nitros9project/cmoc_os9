#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void test_xtoa(void)
{
	char buf[16];

	itoa(-1234, buf);
	if (strcmp(buf, "-1234") == 0)
		printf("%s [PASS] itoa()\n", __func__);
	else
		printf("%s [FAIL] itoa(): got %s\n", __func__, buf);

	utoa(54321, buf);
	if (strcmp(buf, "54321") == 0)
		printf("%s [PASS] utoa()\n", __func__);
	else
		printf("%s [FAIL] utoa(): got %s\n", __func__, buf);

	ltoa(1234567L, buf);
	if (strcmp(buf, "1234567") == 0)
		printf("%s [PASS] ltoa()\n", __func__);
	else
		printf("%s [FAIL] ltoa(): got %s\n", __func__, buf);
}

void test_minmax(void)
{
	if (min(4, 9) == 4 && max(4, 9) == 9 &&
	    umin(7U, 3U) == 3U && umax(7U, 3U) == 7U)
		printf("%s [PASS] min/max family\n", __func__);
	else
		printf("%s [FAIL] min/max family\n", __func__);
}

void test_mktemp(void)
{
	char name[16];

	strcpy(name, "tmp.XXXXX");
	mktemp(name);
	if (strncmp(name, "tmp.", 4) == 0 && strlen(name) >= 5)
		printf("%s [PASS] mktemp()\n", __func__);
	else
		printf("%s [FAIL] mktemp(): got %s\n", __func__, name);
}

void test_setbuf(void)
{
	char buf[BUFSIZ];

	setbuf(stdout, buf);
	if (stdout->_base == buf &&
	    stdout->_end == buf + BUFSIZ &&
	    stdout->_ptr == stdout->_end &&
	    stdout->_bufsiz == BUFSIZ &&
	    (stdout->_flag & _BIGBUF) != 0 &&
	    (stdout->_flag & _UNBUF) == 0)
		printf("%s [PASS] setbuf(buffered)\n", __func__);
	else
		printf("%s [FAIL] setbuf(buffered) flag=%04x bufsiz=%d\n",
		       __func__, stdout->_flag, stdout->_bufsiz);

	setbuf(stdout, 0);
	if ((stdout->_flag & _UNBUF) != 0 &&
	    (stdout->_flag & _BIGBUF) == 0 &&
	    stdout->_ptr == stdout->_end &&
	    stdout->_bufsiz == BUFSIZ)
		printf("%s [PASS] setbuf(unbuffered)\n", __func__);
	else
		printf("%s [FAIL] setbuf(unbuffered)\n", __func__);

	setbuf(stdout, buf);
	if (stdout->_base == buf &&
	    stdout->_end == buf + BUFSIZ &&
	    stdout->_ptr == stdout->_end &&
	    (stdout->_flag & _BIGBUF) != 0 &&
	    (stdout->_flag & _UNBUF) == 0)
		printf("%s [PASS] setbuf(rebuffered)\n", __func__);
	else
		printf("%s [FAIL] setbuf(rebuffered)\n", __func__);
}

void test_rand(void)
{
	srand(1);
	if (rand() == 16838 &&
	    rand() == 5758 &&
	    rand() == 10113)
		printf("%s [PASS] srand()/rand()\n", __func__);
	else
		printf("%s [FAIL] srand()/rand()\n", __func__);
}

int main(void)
{
	test_xtoa();
	test_minmax();
	test_mktemp();
	test_setbuf();
	test_rand();
	return 0;
}
