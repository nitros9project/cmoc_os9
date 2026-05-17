#include <stdio.h>

size_t
fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	const unsigned char *p = (const unsigned char *) ptr;
	size_t count = 0;
	size_t remaining;

	while (count < nmemb) {
		remaining = size;
		while (remaining--) {
			if (putc(*p++, stream) == EOF)
				return count;
		}
		count++;
	}

	return count;
}
