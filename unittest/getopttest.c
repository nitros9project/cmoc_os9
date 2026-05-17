#include <stdio.h>
#include <string.h>
#include <arg.h>

static int failures;

static void expect(int condition, const char *message)
{
	if (!condition)
	{
		printf("FAIL: %s\n", message);
		++failures;
	}
}

int main(void)
{
	char arg0[] = "getopttest";
	char arg1[] = "-a";
	char arg2[] = "-b";
	char arg3[] = "value";
	char arg4[] = "-cinline";
	char arg5[] = "tail";
	char *argv[] = { arg0, arg1, arg2, arg3, arg4, arg5 };
	char options[] = "ab:c:";
	int argc = sizeof(argv) / sizeof(argv[0]);
	int option;

	optind = 1;
	opterr = 0;
	optarg = 0;
	optopt = 0;

	option = getopt(argc, argv, options);
	expect(option == 'a', "first option should be -a");
	expect(optarg == 0, "-a should not set optarg");
	expect(optind == 2, "optind should advance after -a");

	option = getopt(argc, argv, options);
	expect(option == 'b', "second option should be -b");
	expect(optarg != 0 && strcmp(optarg, arg3) == 0, "-b should capture separate argument");
	expect(optind == 4, "optind should advance past -b argument");

	option = getopt(argc, argv, options);
	expect(option == 'c', "third option should be -c");
	expect(optarg != 0 && strcmp(optarg, arg4 + 2) == 0, "-c should capture inline argument");
	expect(optind == 5, "optind should advance past inline argument option");

	option = getopt(argc, argv, options);
	expect(option == EOF, "parser should stop after options");
	expect(optind == 5, "optind should point at first non-option argument");

	if (failures)
		return 1;

	printf("PASS\n");
	return 0;
}
