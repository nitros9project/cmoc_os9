#include <stdio.h>
#include <unistd.h>

static FILE probe;
static int failed;

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

static void check_layout(const char *label, unsigned actual, unsigned expected)
{
	outstr(label);
	if (actual == expected)
		outstr(" [PASS] ");
	else {
		outstr(" [FAIL] ");
		failed = 1;
	}
	outnum(actual);
	outstr(" expected=");
	outnum(expected);
	write(1, "\n", 1);
}

int main(void)
{
	check_layout("sizeof(FILE)", (unsigned) sizeof(FILE), 13);
	check_layout("off(_ptr)", (unsigned) ((char *) &probe._ptr - (char *) &probe), 0);
	check_layout("off(_base)", (unsigned) ((char *) &probe._base - (char *) &probe), 2);
	check_layout("off(_end)", (unsigned) ((char *) &probe._end - (char *) &probe), 4);
	check_layout("off(_flag)", (unsigned) ((char *) &probe._flag - (char *) &probe), 6);
	check_layout("off(_fd)", (unsigned) ((char *) &probe._fd - (char *) &probe), 8);
	check_layout("off(_save)", (unsigned) ((char *) &probe._save - (char *) &probe), 10);
	check_layout("off(_bufsiz)", (unsigned) ((char *) &probe._bufsiz - (char *) &probe), 11);
	return failed;
}
