#include <module.h>
#include <os.h>

static char default_drive[12];

char *getdrive(void)
{
	char *src;
	char *dst;
	char c;
	mod_config *config;

	if (_os_modlink((char *) "init", 0x0c, 0, (void **) &config) != 0)
		return 0;

	src = ((char *) config) + config->m_sysdrive;
	dst = default_drive;

	while ((c = *src++) > 0)
		*dst++ = c;

	*dst++ = c & 0x7f;
	*dst = '\0';

	_os_modunlink(config);
	return default_drive;
}
