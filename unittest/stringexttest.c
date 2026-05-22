#include <stdio.h>
#include <string.h>

static int failed;

static void check_true(const char *name, int cond)
{
	if (cond)
		printf("%s [PASS]\n", name);
	else {
		printf("%s [FAIL]\n", name);
		failed = 1;
	}
}

void test_find_helpers(void)
{
	const char *text = "coco-shelf";
	char *hit;

	hit = findstr(text, "shelf");
	check_true("test_find_helpers findstr()", hit != 0 && strcmp(hit, "shelf") == 0);

	hit = findnstr(text, "shelf", 4);
	check_true("test_find_helpers findnstr(limit)", hit == 0);

	hit = findnstr(text, "shelf", 10);
	check_true("test_find_helpers findnstr(hit)", hit != 0 && strcmp(hit, "shelf") == 0);

	hit = findnstr(text, "coco", 4);
	check_true("test_find_helpers findnstr(start exact)", hit == text);
}

void test_find_edge_cases(void)
{
	const char *text = "banana";
	char *hit;

	hit = findstr(text, "");
	check_true("test_find_edge_cases findstr(empty)", hit == text);

	hit = findstr(text, "band");
	check_true("test_find_edge_cases findstr(miss)", hit == 0);

	hit = findstr(text, "ana");
	check_true("test_find_edge_cases findstr(overlap)", hit != 0 && strcmp(hit, "anana") == 0);

	hit = findnstr(text, "ana", 1);
	check_true("test_find_edge_cases findnstr(limit miss)", hit == 0);

	hit = findnstr(text, "ana", 0);
	check_true("test_find_edge_cases findnstr(zero limit)", hit == 0);

	hit = findnstr(text, "ana", 2);
	check_true("test_find_edge_cases findnstr(limit exact)", hit != 0 && strcmp(hit, "anana") == 0);

	hit = findnstr(text, "", 3);
	check_true("test_find_edge_cases findnstr(empty)", hit == text);

	hit = findnstr(text, "", 0);
	check_true("test_find_edge_cases findnstr(empty zero limit)", hit == text);
}

void test_swab(void)
{
	check_true("test_swab swab()", swab(0x1234) == 0x3412);
}

int main(void)
{
	test_find_helpers();
	test_find_edge_cases();
	test_swab();
	return failed;
}
