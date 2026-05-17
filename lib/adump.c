#include <stdio.h>

void _dump(char *string, char *addr, int count)
{
	char *p;
	char c;
	int j;
	unsigned u;

	fprintf(stderr, "%s\n\n", string);
	fprintf(stderr, "      ");

	for (j = 0, p = addr; j < 16; ++j, ++p)
		fprintf(stderr, " %1x ", (u = (unsigned) p) & 0x000f);

	fprintf(stderr, " ");

	for (j = 0, p = addr; j < 16; ++j, ++p)
		fprintf(stderr, "%1x", (u = (unsigned) p) & 0x000f);

	putc('\n', stderr);
	fprintf(stderr,
		"      -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --  ----------------\n");

	for (; count > 0; count -= 16)
	{
		fprintf(stderr, "%04x: ", addr);

		for (j = 0, p = addr; j < 16; ++j)
			fprintf(stderr, "%02x ", (*p++ & 0xff));

		fprintf(stderr, " ");

		for (j = 0, p = addr; j < 16; ++j)
			fprintf(stderr, "%c", ((c = *p++ & 0x7f) >= 32 ? c : '.'));

		putc('\n', stderr);
		addr = p;
	}

	putc('\n', stderr);
}
