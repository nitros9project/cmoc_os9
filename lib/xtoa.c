#include <stdlib.h>

static char *
utoa_core(unsigned long value, char *buffer)
{
	char tmp[12];
	int i = 0;

	do {
		tmp[i++] = (value % 10UL) + '0';
		value /= 10UL;
	} while (value);

	while (i > 0)
		*buffer++ = tmp[--i];
	*buffer = '\0';
	return buffer;
}

char *
utoa(unsigned value, char *buffer)
{
	utoa_core((unsigned long) value, buffer);
	return buffer;
}

char *
utoa10(unsigned value, char *buffer)
{
	return utoa(value, buffer);
}

char *
itoa(int value, char *buffer)
{
	return ltoa((long) value, buffer);
}

char *
itoa10(int value, char *buffer)
{
	return itoa(value, buffer);
}
