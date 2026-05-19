#include <stdio.h>
#include <string.h>

int main(void)
{
	char buf[64];
	char buf2[64];

	strcpy(buf, "secret");
	strcpy(buf2, "secret");
	pwcryp(buf);
	pwcryp(buf2);
	if (strcmp(buf, "secret") != 0 && buf[0] != '\0' && strcmp(buf, buf2) == 0) {
		printf("pwcryptest [PASS] pwcryp()\n");
		return 0;
	}
	printf("pwcryptest [FAIL] pwcryp() got=%s repeat=%s\n", buf, buf2);
	return 1;
}
