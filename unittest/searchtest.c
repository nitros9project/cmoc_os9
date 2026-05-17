#include <stdio.h>
#include <stdlib.h>

static int failed;

static int
cmp_int(const void *lhs, const void *rhs)
{
	int a = *(const int *) lhs;
	int b = *(const int *) rhs;

	return a - b;
}

static void
check_true(const char *name, int condition)
{
	if (condition)
		printf("%s [PASS]\n", name);
	else {
		printf("%s [FAIL]\n", name);
		failed = 1;
	}
}

void test_qsort_bsearch(void)
{
	int data[6];
	int key = 7;
	int miss = 8;
	int dup_data[5];
	int solo[1];
	int empty_count = 0;
	int *found;

	data[0] = 9;
	data[1] = 3;
	data[2] = 7;
	data[3] = 1;
	data[4] = 5;
	data[5] = 11;

	qsort(data, 6, sizeof(data[0]), cmp_int);
	check_true("test_qsort_bsearch qsort()",
		   data[0] == 1 && data[1] == 3 && data[2] == 5 &&
		   data[3] == 7 && data[4] == 9 && data[5] == 11);

	found = (int *) bsearch(&key, data, 6, sizeof(data[0]), cmp_int);
	check_true("test_qsort_bsearch bsearch(hit)", found != 0 && *found == 7);

	found = (int *) bsearch(&miss, data, 6, sizeof(data[0]), cmp_int);
	check_true("test_qsort_bsearch bsearch(miss)", found == 0);

	dup_data[0] = 4;
	dup_data[1] = 1;
	dup_data[2] = 4;
	dup_data[3] = 2;
	dup_data[4] = 4;
	qsort(dup_data, 5, sizeof(dup_data[0]), cmp_int);
	check_true("test_qsort_bsearch qsort(duplicates)",
		   dup_data[0] == 1 && dup_data[1] == 2 &&
		   dup_data[2] == 4 && dup_data[3] == 4 &&
		   dup_data[4] == 4);
	found = (int *) bsearch(&dup_data[2], dup_data, 5, sizeof(dup_data[0]), cmp_int);
	check_true("test_qsort_bsearch bsearch(duplicates)", found != 0 && *found == 4);

	solo[0] = 42;
	qsort(solo, 1, sizeof(solo[0]), cmp_int);
	check_true("test_qsort_bsearch qsort(single)", solo[0] == 42);

	qsort(solo, empty_count, sizeof(solo[0]), cmp_int);
	check_true("test_qsort_bsearch qsort(empty)", solo[0] == 42);
}

int main(void)
{
	test_qsort_bsearch();
	return failed;
}
