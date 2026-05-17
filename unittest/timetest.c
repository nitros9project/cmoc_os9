#include <stdio.h>
#include <time.h>

struct _os_time p = {2014 - 1900, 3, 4, 11, 33, 22};
extern int errno;

void test_getime()
{
	struct _os_time localP;

	int result = _os_getime(&localP);
	// Sanity check... compare year/month/day
	if (result == 0 &&
		 localP.year == p.year &&
		 localP.month == p.month &&
		 localP.day == p.day)
	{
		printf("%s [PASS] _os_getime()\n", __func__);
	}
	else
	{
		printf("%s [FAIL] _os_getime(), errno=%d\n", __func__, errno);
	}
}

void test_setime()
{
	int result = _os_setime(&p);
	if (result == 0)
	{
		printf("%s [PASS] _os_setime()\n", __func__);
	}
	else
	{
		printf("%s [FAIL] _os_setime(), errno=%d\n", __func__, errno);
	}
}

int main()
{
	test_setime();
	test_getime();

	return 0;
}
