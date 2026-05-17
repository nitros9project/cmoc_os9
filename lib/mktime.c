#include <time.h>

extern int _mdays[];

extern int _isleap(int year);
extern unsigned _leaps(int year);

time_t
mktime(struct tm *tp)
{
	time_t accum;
	unsigned d;
	int y;

	/* Days between the epoch and the start of this year. */
	y = tp->tm_year - (EPOCH_YEAR - TM_YEAR_BASE);
	if (y < 0 || y > 136)
		return (time_t) -1L;

	d = y * 365 + _leaps(y);
	d += _mdays[tp->tm_mon] + ((tp->tm_mon > 1) && _isleap(y));
	d += tp->tm_mday - 1;

	accum = (time_t) d * 24;
	accum += tp->tm_hour;
	accum *= 60;
	accum += tp->tm_min;
	accum *= 60;
	accum += tp->tm_sec;

	if (timezone)
		accum -= timezone;

	return accum;
}
