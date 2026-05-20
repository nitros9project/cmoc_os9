#include <stdio.h>

char *skipbl(char *s);
char *skipwd(char *s);

static int failed;

static void check_ptr(const char *name, char *actual, char *expected)
{
	if (actual == expected)
		printf("%s [PASS]\n", name);
	else {
		printf("%s [FAIL] actual=%d expected=%d\n",
		       name, actual - expected, 0);
		failed = 1;
	}
}

int main(void)
{
	char blanks[] = " \t  word";
	char noblanks[] = "word";
	char word_space[] = "word next";
	char word_tab[] = "word\tnext";
	char word_end[] = "word";
	char empty[] = "";

	check_ptr("skiptest skipbl blanks", skipbl(blanks), blanks + 4);
	check_ptr("skiptest skipbl none", skipbl(noblanks), noblanks);
	check_ptr("skiptest skipbl empty", skipbl(empty), empty);

	check_ptr("skiptest skipwd space", skipwd(word_space), word_space + 4);
	check_ptr("skiptest skipwd tab", skipwd(word_tab), word_tab + 4);
	check_ptr("skiptest skipwd end", skipwd(word_end), word_end + 4);
	check_ptr("skiptest skipwd empty", skipwd(empty), empty);

	return failed;
}
