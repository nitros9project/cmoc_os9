#include <stdio.h>
#include <module.h>

int main(void)
{
	char *drive;

	drive = getdrive();
	if (drive != 0)
		printf("PASS %s\n", drive);
	else
		printf("PASS\n");

	return 0;
}
