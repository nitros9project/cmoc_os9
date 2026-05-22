#include <stdio.h>

static int failed;

static void
check_errmsg(const char *name, int expected, int actual)
{
	if (actual == expected)
		printf("%s [PASS] actual=%d expected=%d\n", name, actual, expected);
	else {
		printf("%s [FAIL] actual=%d expected=%d\n", name, actual, expected);
		failed = 1;
	}
}

int
main(void)
{
	int result;

	result = _errmsg(5, "plain message\n");
	check_errmsg("errmsg plain", 5, result);

	result = _errmsg(7, "test message %d\n", 123);
	check_errmsg("errmsg one arg", 7, result);

	result = _errmsg(42, "test message %d %d %d\n", 1, 2, 3);
	check_errmsg("errmsg three args", 42, result);

	return failed;
}
