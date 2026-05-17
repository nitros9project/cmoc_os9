#include <stdio.h>
#include <unistd.h>

static FILE probe;

static void outstr(const char *s)
{
	int n = 0;
	while (s[n] != '\0')
		++n;
	write(1, s, n);
}

static void outnum(unsigned n)
{
	char buf[6];
	int i = 0;
	if (n == 0) {
		write(1, "0", 1);
		return;
	}
	while (n != 0 && i < (int) sizeof(buf)) {
		buf[i++] = (char) ('0' + (n % 10));
		n /= 10;
	}
	while (i > 0)
		write(1, &buf[--i], 1);
}

static void outline(const char *label, unsigned value)
{
	outstr(label);
	outnum(value);
	write(1, "\n", 1);
}

int main(void)
{
	outline("sizeof(FILE)=", (unsigned) sizeof(FILE));
	outline("off(_ptr)=", (unsigned) ((char *) &probe._ptr - (char *) &probe));
	outline("off(_base)=", (unsigned) ((char *) &probe._base - (char *) &probe));
	outline("off(_end)=", (unsigned) ((char *) &probe._end - (char *) &probe));
	outline("off(_flag)=", (unsigned) ((char *) &probe._flag - (char *) &probe));
	outline("off(_fd)=", (unsigned) ((char *) &probe._fd - (char *) &probe));
	outline("off(_save)=", (unsigned) ((char *) &probe._save - (char *) &probe));
	outline("off(_bufsiz)=", (unsigned) ((char *) &probe._bufsiz - (char *) &probe));
	return 0;
}
