#include <stdio.h>

size_t
fread(void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	unsigned char *p = (unsigned char *) ptr;
	size_t count = 0;
	size_t remaining;
	int c;

	while (count < nmemb) {
		remaining = size;
		while (remaining--) {
			c = getc(stream);
			if (c == EOF)
				return count;
			*p++ = (unsigned char) c;
		}
		count++;
	}

	return count;
}
