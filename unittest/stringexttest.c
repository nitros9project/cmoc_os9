#include <stdio.h>
#include <string.h>

void test_find_helpers(void)
{
	const char *text = "coco-shelf";
	char *hit;

	hit = findstr(text, "shelf");
	if (hit != 0 && strcmp(hit, "shelf") == 0)
		printf("%s [PASS] findstr()\n", __func__);
	else
		printf("%s [FAIL] findstr()\n", __func__);

	hit = findnstr(text, "shelf", 4);
	if (hit == 0)
		printf("%s [PASS] findnstr(limit)\n", __func__);
	else
		printf("%s [FAIL] findnstr(limit)\n", __func__);

	hit = findnstr(text, "shelf", 10);
	if (hit != 0 && strcmp(hit, "shelf") == 0)
		printf("%s [PASS] findnstr(hit)\n", __func__);
	else
		printf("%s [FAIL] findnstr(hit)\n", __func__);
}

void test_swab(void)
{
	if (swab(0x1234) == 0x3412)
		printf("%s [PASS] swab()\n", __func__);
	else
		printf("%s [FAIL] swab()\n", __func__);
}

int main(void)
{
	test_find_helpers();
	test_swab();
	return 0;
}
