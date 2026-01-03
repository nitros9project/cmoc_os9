asm int strlen(const char *str)
{
	asm
	{
 ldx 2,s
 ldd #$ffff
strlen1 addb #1
 adca #0
 tst ,x+
 bne strlen1
	}
}

