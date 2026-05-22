#include <stdio.h>
#include <time.h>

static char xx[26];

static const char *days[] = {
	"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
};

static const char *months[] = {
	"Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
};

char *
asctime(const struct tm *tmp)
{
	sprintf(xx, "%s %s %2d %02d:%02d:%02d %4d\n",
		days[tmp->tm_wday], months[tmp->tm_mon], tmp->tm_mday,
		tmp->tm_hour, tmp->tm_min, tmp->tm_sec,
		TM_YEAR_BASE + tmp->tm_year);
	return xx;
}
