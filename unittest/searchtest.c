#include <stdio.h>
#include <stdlib.h>

static int
cmp_int(const void *lhs, const void *rhs)
{
	int a = *(const int *) lhs;
	int b = *(const int *) rhs;

	return a - b;
}

void test_qsort_bsearch(void)
{
	int data[6];
	int key = 7;
	int *found;

	data[0] = 9;
	data[1] = 3;
	data[2] = 7;
	data[3] = 1;
	data[4] = 5;
	data[5] = 11;

	qsort(data, 6, sizeof(data[0]), cmp_int);
	if (data[0] == 1 && data[1] == 3 && data[2] == 5 &&
	    data[3] == 7 && data[4] == 9 && data[5] == 11)
		printf("%s [PASS] qsort()\n", __func__);
	else
		printf("%s [FAIL] qsort()\n", __func__);

	found = (int *) bsearch(&key, data, 6, sizeof(data[0]), cmp_int);
	if (found != 0 && *found == 7)
		printf("%s [PASS] bsearch()\n", __func__);
	else
		printf("%s [FAIL] bsearch()\n", __func__);
}

int main(void)
{
	test_qsort_bsearch();
	return 0;
}
