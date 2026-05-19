#include <stdio.h>
#include <time.h>
#include <debug.h>
#include <fcntl.h>
// typedef unsigned int size_t;
#include <sys/types.h>
#include <string.h>

#define I$ReadLn            0x8B

struct _os_time p = {2014 - 1900, 3, 4, 11, 33, 22};
#define P_SECS_EPOCH 1393932802L
char *pStr = "Tue Mar  4 11:33:22 2014\n";
struct _os_time epoch = {1970 - 1900, 1, 1, 0, 0, 0};
char *epochStr = "Thu Jan  1 00:00:00 1970\n";
#define EPOCH_START 0L
static int failed;


void test_o2utime()
{
	long t = o2utime(&epoch);
	if (t == EPOCH_START) {
		printf("%s [PASS] o2utime(): epoch\n", __func__);
	}
	else
	{
		printf("%s [FAIL] o2utime(): epoch: expected %ld but got %ld\n", __func__, EPOCH_START, t);
		LPX(t);
		failed = 1;
	}	

	t = o2utime(&p);
	if (t == P_SECS_EPOCH) {
		printf("%s [PASS] o2utime(): date\n", __func__);
	}
	else
	{
		printf("%s [FAIL] o2utime(): date: expected %ld but got %ld\n", __func__, P_SECS_EPOCH, t);
		LPX(t);
		failed = 1;
	}
}

void test_u2otime()
{
	struct tm tmp;
	struct _os_time converted;
	int ok;

	memset(&tmp, 0, sizeof(tmp));
	memset(&converted, 0, sizeof(converted));
	tmp.tm_sec = p.seconds;
	tmp.tm_min = p.minutes;
	tmp.tm_hour = p.hours;
	tmp.tm_mday = p.day;
	tmp.tm_mon = p.month;
	tmp.tm_year = p.year;

	u2otime(&converted, &tmp);
	ok = converted.year == p.year &&
	     converted.month == p.month &&
	     converted.day == p.day &&
	     converted.hours == p.hours &&
	     converted.minutes == p.minutes &&
	     converted.seconds == p.seconds;

	if (ok)
		printf("%s [PASS] u2otime(): date\n", __func__);
	else {
		printf("%s [FAIL] u2otime(): got %d/%d/%d %d:%d:%d\n",
		       __func__,
		       converted.year,
		       converted.month,
		       converted.day,
		       converted.hours,
		       converted.minutes,
		       converted.seconds);
		failed = 1;
	}
}


void test_time()
{
	_os_setime(&p);
	long t = time(0);
	if (t == P_SECS_EPOCH) {
		printf("%s [PASS] time() by value\n", __func__);
	}
	else
	{
		printf("%s [FAIL] time() by value: expected %ld but got %ld\n", __func__, P_SECS_EPOCH, t);
		LPX(t);
		failed = 1;
	}
	_os_setime(&p);
	time(&t);
	if (t == P_SECS_EPOCH) {
		printf("%s [PASS] time() by ptr\n", __func__);
	}
	else
	{
		printf("%s [FAIL] time() by ptr: expected %ld but got %ld\n", __func__, P_SECS_EPOCH, t);
		LPX(t);
		failed = 1;
	}
}

void test_ctime()
{
	long t = P_SECS_EPOCH;
	char *ds = ctime(&t);
	if (strcmp(pStr, ds) == 0)
	{
		printf("%s [PASS] ctime() date\n", __func__);
	}
	else
	{
		printf("%s [FAIL] ctime() date\n", __func__);
		printf("%s pStr (%s)\n", __func__, pStr);
		printf("%s   ds (%s)\n", __func__, ds);
		failed = 1;
	}

	t = EPOCH_START;
	ds = ctime(&t);
	if (strcmp(epochStr, ds) == 0)
		printf("%s [PASS] ctime() epoch\n", __func__);
	else {
		printf("%s [FAIL] ctime() epoch\n", __func__);
		failed = 1;
	}

}

void test_mktime()
{
	time_t t = P_SECS_EPOCH;
	struct tm *tmp = localtime(&t);
	time_t roundtrip = mktime(tmp);

	if (roundtrip == P_SECS_EPOCH)
	{
		printf("%s [PASS] mktime() roundtrip\n", __func__);
	}
	else
	{
		printf("%s [FAIL] mktime() roundtrip: expected %ld but got %ld\n",
		       __func__, P_SECS_EPOCH, roundtrip);
		LPX(roundtrip);
		failed = 1;
	}
}

void test_gmtime_localtime()
{
	time_t t = P_SECS_EPOCH;
	struct tm *utc;
	struct tm *local;

	timezone = 0;
	utc = gmtime(&t);
	if (utc->tm_hour == 11 && utc->tm_mday == 4)
		printf("%s [PASS] gmtime() UTC decode\n", __func__);
	else
		printf("%s [FAIL] gmtime() UTC decode: got day=%d hour=%d\n",
		       __func__, utc->tm_mday, utc->tm_hour), failed = 1;

	timezone = -(6L * 60L * 60L);
	local = localtime(&t);
	if (local->tm_hour == 5 && local->tm_mday == 4)
		printf("%s [PASS] localtime() timezone adjust\n", __func__);
	else
		printf("%s [FAIL] localtime() timezone adjust: got day=%d hour=%d\n",
		       __func__, local->tm_mday, local->tm_hour), failed = 1;

	timezone = 0;
}

int main()
{
	test_o2utime();
	test_u2otime();
	test_time();
	test_ctime();
	test_mktime();
	test_gmtime_localtime();

	return failed;
}
