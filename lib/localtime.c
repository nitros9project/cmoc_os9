#include <time.h>

extern int _mdays[];
extern int _myears[];

static struct tm _tm;

extern int _isleap(int year);

struct tm *
gmtime(const time_t *tp)
{
	time_t ticks = *tp;
	int days;
	int leap;
	int i;

	_tm.tm_sec = ticks % 60;
	ticks /= 60;

	_tm.tm_min = ticks % 60;
	ticks /= 60;

	_tm.tm_hour = ticks % 24;
	days = ticks / 24;
	_tm.tm_wday = (days + EPOCH_DOW) % 7;

	i = 0;
	while (days >= _myears[leap = _isleap(i)]) {
		days -= _myears[leap];
		i++;
	}
	_tm.tm_year = (EPOCH_YEAR - TM_YEAR_BASE) + i;
	_tm.tm_yday = days;

	for (i = 0; i < 12; i++) {
		if ((_mdays[i + 1] + (leap && i > 0)) > days)
			break;
	}
	_tm.tm_mday = days - (_mdays[i] + (leap && i > 1)) + 1;
	_tm.tm_mon = i;
	_tm.tm_isdst = -1;

	return &_tm;
}

struct tm *
localtime(const time_t *tp)
{
	time_t tt = *tp + timezone;

	return gmtime(&tt);
}
