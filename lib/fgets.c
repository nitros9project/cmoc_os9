#include <stdio.h>

char *
fgets(char *str, int size, FILE *stream)
{
	char *p = str;
	int c;

	if (size <= 0)
		return 0;

	while (--size > 0) {
		c = getc(stream);
		if (c == EOF)
			break;
		*p++ = (char) c;
		if (c == '\r')
			break;
	}

	*p = '\0';
	if (p == str && c == EOF)
		return 0;
	return str;
}
