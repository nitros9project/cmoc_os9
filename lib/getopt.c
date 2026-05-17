#include <stdio.h>
#include <string.h>
#include <arg.h>

#define BADCH ((int) '?')
#define EMSG ""

int opterr = 1;
int optind = 1;
int optopt;
char *optarg;

/*
 * Kreider-style getopt() adapted to build as part of the CMOC OS-9 libc.
 */
int getopt(int argc, char **argv, const char *options)
{
	static const char *place = EMSG;
	const char *option_ptr;

	if (!*place)
	{
		if (optind >= argc || *(place = argv[optind]) != '-' || !*++place)
			return EOF;
		if (*place == '-')
		{
			++optind;
			return EOF;
		}
	}

	optopt = (unsigned char) *place++;
	if (optopt == ':' || (option_ptr = strchr((char *) options, optopt)) == 0)
	{
		if (!*place)
			++optind;
		if (opterr)
		{
			fputs(argv[0], stderr);
			fputs(": illegal option -- ", stderr);
			putc(optopt, stderr);
			putc('\n', stderr);
		}
		return BADCH;
	}

	if (*++option_ptr != ':')
	{
		optarg = 0;
		if (!*place)
			++optind;
	}
	else
	{
		if (*place)
			optarg = (char *) place;
		else if (argc <= ++optind)
		{
			place = EMSG;
			if (opterr)
			{
				fputs(argv[0], stderr);
				fputs(": option requires an argument -- ", stderr);
				putc(optopt, stderr);
				putc('\n', stderr);
			}
			return BADCH;
		}
		else
			optarg = argv[optind];

		place = EMSG;
		++optind;
	}

	return optopt;
}
