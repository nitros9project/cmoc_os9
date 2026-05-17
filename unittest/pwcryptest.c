#include <stdio.h>
#include <string.h>

int main(void)
{
	char buf[64];

	strcpy(buf, "secret");
	pwcryp(buf);
	if (strcmp(buf, "secret") != 0 && buf[0] != '\0') {
		printf("PASS %s\n", buf);
		return 0;
	}
	printf("FAIL %s\n", buf);
	return 1;
}
