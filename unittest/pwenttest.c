#include <stdio.h>
#include <password.h>

int main(void)
{
	PWENT *pw;

	pw = getpwent();
	if (pw != 0)
	{
		printf("PASS %s %s\n", pw->unam, pw->uid);
		endpwent();
	}
	else
	{
		printf("PASS\n");
	}

	return 0;
}
