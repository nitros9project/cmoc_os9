#include <os.h>
#include <stdio.h>

int main(void)
{
	int ticks = 1;
	error_code result = _os9_sleep(&ticks);

	if (result != 0) {
		printf("sleeptest [FAIL] _os9_sleep result=%d\n", result);
		return 1;
	}

	if (ticks != 0) {
		printf("sleeptest [FAIL] ticks remaining=%d\n", ticks);
		return 1;
	}

	printf("sleeptest [PASS] _os9_sleep\n");
	return 0;
}
