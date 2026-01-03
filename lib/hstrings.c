#include <stdio.h>
#include <unistd.h>

/* Conversion Utilities for "hstrings"
"hstrings" are standard OS-9 strings which have the high bit
set as the last character. */

/* Convert string to hstring.
NOTE: If dst is NULL the source
string is modified
Return: Pointer to string */
char *strtohstr(char *dst, char *src)
{
	char *d, *s;

	if(src == NULL)
		return NULL;

	if(dst == NULL)
		dst = src;

	for (d=dst, s=src; *s; s++)
		*d++ = *s;

	if (*dst)
		*(d-1) |= 0x80;

	return dst;
}

/* Convert hstring to string.
NOTE: If dst is NULL the source
string is modified
Return: Pointer to string */
char *hstrtostr(char *dst, char *src)
{
	char *d, *s;

	if(dst == NULL)
		dst = src;

	d = dst;
	s = src;
	while (! (*s&0x80))
		*d++ = *s++;

	*d++ = *s&0x7f;
	*d = 0;

	return dst;
}

/* Print a hstr */
int hputs(char *str)
{
	char *s;
	s = str;
	while (! (*s&0x80))
		putchar(*s++);
	putchar((*s)&0x7f);
	return 0;
}


int Xmain()
{
	char s[]="test";
	char buf[10];
	strtohstr(buf, s);
	hputs(buf);
	printf("\n");
	hstrtostr(NULL, buf);
	printf("%s\n", buf);
	return 0;
}

