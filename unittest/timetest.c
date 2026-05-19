#include <stdio.h>
#include <time.h>

struct _os_time p = {2014 - 1900, 3, 4, 11, 33, 22};
extern int errno;
static int failed;

void test_getime()
{
	struct _os_time localP;
	int seconds_delta;

	int result = _os_getime(&localP);
	seconds_delta = localP.seconds - p.seconds;
	// Sanity check the packet after test_setime(), allowing the clock to tick.
	if (result == 0 &&
		 localP.year == p.year &&
		 localP.month == p.month &&
		 localP.day == p.day &&
		 localP.hours == p.hours &&
		 localP.minutes == p.minutes &&
		 seconds_delta >= 0 &&
		 seconds_delta <= 5)
	{
		printf("%s [PASS] _os_getime()\n", __func__);
	}
	else
	{
		printf("%s [FAIL] _os_getime(), errno=%d got %d/%d/%d %d:%d:%d\n",
				__func__,
				errno,
				localP.year,
				localP.month,
				localP.day,
				localP.hours,
				localP.minutes,
				localP.seconds);
		failed = 1;
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
		failed = 1;
	}
}

int main()
{
	test_setime();
	test_getime();

	return failed;
}
