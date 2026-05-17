#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <password.h>

static int pwpn = 0;
char _pwdelim = OS9DLM;
static char tmpbuf[PWSIZ + 1];
static PWENT pwent;

static PWENT *parse(char *p, PWENT *pwp)
{
	pwp->ugcos = 0;
	pwp->unam = p;
	*(p = strchr(p, _pwdelim)) = '\0';
	pwp->upw = ++p;
	*(p = strchr(p, _pwdelim)) = '\0';
	pwp->uid = ++p;
	*(p = strchr(p, _pwdelim)) = '\0';
	pwp->upri = ++p;
	*(p = strchr(p, _pwdelim)) = '\0';

	if (_pwdelim == UNXDLM)
	{
		pwp->ugcos = ++p;
		*(p = strchr(p, _pwdelim)) = '\0';
	}

	pwp->ucmd = ++p;
	*(p = strchr(p, _pwdelim)) = '\0';
	pwp->udat = ++p;
	*(p = strchr(p, _pwdelim)) = '\0';
	pwp->ujob = ++p;
	*(strchr(p, '\n')) = '\0';
	return pwp;
}

PWENT *getpwent(void)
{
	char *p;

	if (pwpn == 0)
	{
		pwpn = open(PASSWORD, 1);
		if (pwpn <= 0)
			return (PWENT *) 0;
	}

	for (;;)
	{
		if (readln(pwpn, tmpbuf, PWSIZ) > 0)
		{
			if (*tmpbuf == '*')
				continue;

			for (p = tmpbuf; *p != '\n' && _pwdelim != ',' && _pwdelim != ':'; )
				_pwdelim = *p++;

			if (*p != '\n')
				return parse(tmpbuf, &pwent);
		}

		return (PWENT *) 0;
	}
}

void setpwent(void)
{
	if (pwpn != 0)
		lseek(pwpn, 0L, 0);
}

void endpwent(void)
{
	if (pwpn != 0)
	{
		close(pwpn);
		pwpn = 0;
	}
}

int getpwdlm(void)
{
	return (int) _pwdelim;
}

PWENT *getpwuid(int uid)
{
	PWENT *pwp;

	while ((pwp = getpwent()) != 0)
		if (uid == atoi(pwp->uid))
			return pwp;

	return (PWENT *) 0;
}

PWENT *getpwnam(char *name)
{
	PWENT *pwp;

	while ((pwp = getpwent()) != 0)
		if (strucmp(name, pwp->unam) == 0)
			return pwp;

	return (PWENT *) 0;
}
