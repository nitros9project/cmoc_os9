#include <stdio.h>
#include <string.h>

int main(void)
{
	char buf[64];

	strcpy(buf, "secret");
	pwcryp(buf);
	printf("PASS %s\n", buf);
	return 0;
}
