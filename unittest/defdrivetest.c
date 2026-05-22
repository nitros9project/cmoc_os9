#include <stdio.h>
#include <string.h>
#include <module.h>

int main(void)
{
	char *drive;

	drive = getdrive();
	if (drive != 0 && strcmp(drive, "/DD") == 0)
		printf("PASS %s\n", drive);
	else {
		printf("FAIL %s\n", drive ? drive : "(null)");
		return 1;
	}

	return 0;
}
