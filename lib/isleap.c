#include <time.h>

int
_isleap(int year)
{
	/* Work relative to the Unix epoch to keep calculations short. */
	year += 300 - (EPOCH_YEAR - TM_YEAR_BASE);
	return (!(year & 3) && ((year % 100) || !(year % 400)));
}

unsigned
_leaps(int year)
{
	int ld = 0;

	while (year) {
		if (_isleap(--year))
			ld++;
	}
	return ld;
}
