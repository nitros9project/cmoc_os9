#include <stdio.h>

int main(void)
{
	int result;

	result = _errmsg(7, "test message %d\n", 123);
	if (result > 0) {
		printf("PASS %d\n", result);
		return 0;
	}
	printf("FAIL %d\n", result);
	return 1;
}
