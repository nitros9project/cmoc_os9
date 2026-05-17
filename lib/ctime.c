#include <time.h>

char *
ctime(const time_t *ticks)
{
	return asctime(localtime(ticks));
}
