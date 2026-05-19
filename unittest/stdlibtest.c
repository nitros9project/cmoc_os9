#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int failed;

static void check_string(const char *name, const char *actual, const char *expected)
{
	if (strcmp(actual, expected) == 0)
		printf("%s [PASS]\n", name);
	else {
		printf("%s [FAIL] got %s expected %s\n", name, actual, expected);
		failed = 1;
	}
}

void test_xtoa(void)
{
	char buf[16];

	itoa(-1234, buf);
	check_string("test_xtoa itoa()", buf, "-1234");

	utoa(54321, buf);
	check_string("test_xtoa utoa()", buf, "54321");

	ltoa(0L, buf);
	check_string("test_xtoa ltoa(zero)", buf, "0");

	ltoa(-1L, buf);
	check_string("test_xtoa ltoa(negative one)", buf, "-1");

	ltoa(-1234567L, buf);
	check_string("test_xtoa ltoa(negative)", buf, "-1234567");

	ltoa(1234567L, buf);
	check_string("test_xtoa ltoa(positive)", buf, "1234567");
}

void test_minmax(void)
{
	if (min(4, 9) == 4 && max(4, 9) == 9 &&
	    umin(7U, 3U) == 3U && umax(7U, 3U) == 7U &&
	    umin(65535U, 1U) == 1U && umax(65535U, 1U) == 65535U &&
	    umin(42U, 42U) == 42U && umax(42U, 42U) == 42U)
		printf("%s [PASS] min/max family\n", __func__);
	else {
		printf("%s [FAIL] min/max family\n", __func__);
		failed = 1;
	}
}

void test_abs_atoi_atol(void)
{
	int atol_ok = 1;
	long value;

	if (abs(0) == 0 && abs(123) == 123 && abs(-123) == 123)
		printf("%s [PASS] abs()\n", __func__);
	else
		printf("%s [FAIL] abs()\n", __func__);

	if (atoi("123") == 123 &&
	    atoi(" -42") == -42 &&
	    atoi("\t+77x") == 77 &&
	    atoi("abc") == 0)
		printf("%s [PASS] atoi()\n", __func__);
	else
		printf("%s [FAIL] atoi()\n", __func__);

	value = atol("abc");
	if (value != 0L)
		atol_ok = 0;

	value = atol("123456");
	if (value != 123456L)
		atol_ok = 0;

	value = atol(" -12345");
	if (value != -12345L)
		atol_ok = 0;

	value = atol("\t+99x");
	if (value != 99L)
		atol_ok = 0;

	if (atol_ok)
		printf("%s [PASS] atol()\n", __func__);
	else
		printf("%s [FAIL] atol()\n", __func__);
}

void test_htoi_htol(void)
{
	int htoi_ok = 1;
	int htol_ok = 1;
	long value;

	if (htoi("0") != 0)
		htoi_ok = 0;

	if (htoi(" 7f") != 0x7f)
		htoi_ok = 0;

	if (htoi("\tABCx") != 0x0abc)
		htoi_ok = 0;

	if (htoi_ok)
		printf("%s [PASS] htoi()\n", __func__);
	else {
		printf("%s [FAIL] htoi()\n", __func__);
		failed = 1;
	}

	value = htol("0");
	if (value != 0L)
		htol_ok = 0;

	value = htol(" abc");
	if (value != 2748L)
		htol_ok = 0;

	value = htol("\t12345678x");
	if (value != 305419896L)
		htol_ok = 0;

	if (htol_ok)
		printf("%s [PASS] htol()\n", __func__);
	else {
		printf("%s [FAIL] htol()\n", __func__);
		failed = 1;
	}
}

void test_mktemp(void)
{
	char name[16];
	char unchanged[16];
	char *result;

	strcpy(name, "tmp.XXXXX");
	result = mktemp(name);
	if (result != name) {
		printf("%s [FAIL] mktemp() returned wrong pointer\n", __func__);
		failed = 1;
	} else if (strncmp(name, "tmp.", 4) != 0 || strlen(name) < 5) {
		printf("%s [FAIL] mktemp(): got %s\n", __func__, name);
		failed = 1;
	} else {
		strcpy(unchanged, "plain.tmp");
		result = mktemp(unchanged);
		if (result != unchanged || strcmp(unchanged, "plain.tmp") != 0) {
			printf("%s [FAIL] mktemp(no X): got %s\n", __func__, unchanged);
			failed = 1;
		} else
			printf("%s [PASS] mktemp()\n", __func__);
	}
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
	test_abs_atoi_atol();
	test_htoi_htol();
	test_mktemp();
	test_setbuf();
	test_rand();
	return failed;
}
