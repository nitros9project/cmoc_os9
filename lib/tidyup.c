#include <stdio.h>

void _tidyup(void)
{
	int i;

	for (i = 0; i < _NFILE; ++i)
		fclose(&_iob[i]);
}
