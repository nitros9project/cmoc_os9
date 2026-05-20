#include <stdio.h>
#include <stdlib.h>

static int failed;

extern void call_lmul(long *out, const long *lhs, const long *rhs);

static void check_lmul(const char *name, long lhs, long rhs, long expected)
{
	long actual;
	char actual_buf[16];
	char expected_buf[16];

	call_lmul(&actual, &lhs, &rhs);

	if (actual == expected)
	{
		printf("%s [PASS] %s\n", __func__, name);
		return;
	}

	ltoa(actual, actual_buf);
	ltoa(expected, expected_buf);
	printf("%s [FAIL] %s actual=%s expected=%s\n", __func__, name, actual_buf, expected_buf);
	failed = 1;
}

int main(void)
{
	check_lmul("zero", 0L, 12345L, 0L);
	check_lmul("small", 123L, 456L, 56088L);
	check_lmul("word-carry", 32768L, 3L, 98304L);
	check_lmul("negative-lhs", -12345L, 10L, -123450L);
	check_lmul("negative-rhs", 12345L, -10L, -123450L);
	check_lmul("both-negative", -123L, -456L, 56088L);
	check_lmul("multiply-by-10", 123456L, 10L, 1234560L);

	return failed;
}
