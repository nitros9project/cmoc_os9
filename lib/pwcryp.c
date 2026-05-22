#include <string.h>
#include <os.h>

static char to_hex_digit(unsigned char value)
{
	value &= 0x0f;
	if (value <= 9)
		return value + '0';
	return value - 10 + 'A';
}

char *pwcryp(char *str)
{
	registers_6809 regs;
	unsigned char accum[3];
	int len;

	accum[0] = 0xff;
	accum[1] = 0xff;
	accum[2] = 0xff;

	len = strlen(str);
	regs.cc = 0;
	regs.a = 0;
	regs.b = 0;
	regs.dp = 0;
	regs.x = (int) str;
	regs.y = len;
	regs.u = (int) accum;
	regs.s = 0;
	_os_syscall(F$CRC, &regs);

	str[0] = to_hex_digit(accum[0] >> 4);
	str[1] = to_hex_digit(accum[0]);
	str[2] = to_hex_digit(accum[1] >> 4);
	str[3] = to_hex_digit(accum[1]);
	str[4] = to_hex_digit(accum[2] >> 4);
	str[5] = to_hex_digit(accum[2]);
	str[6] = '\0';

	return str;
}
