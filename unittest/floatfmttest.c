#include <stdio.h>
#include <string.h>

extern char *ftoa(char out[38], float f);
extern char *pffloat(int c, int prec, float **args);

static int failed;

static void
expect_string(const char *label, const char *got, const char *expected)
{
	if (strcmp(got, expected) == 0)
		printf("floatfmttest [PASS] %s\n", label);
	else {
		printf("floatfmttest [FAIL] %s got=%s expected=%s\n", label, got, expected);
		failed = 1;
	}
}

int main(void)
{
	float a = 18.44f;
	float b = 0.125f;
	float c = 1234.5f;
	char buf[64];
	char raw[38];
	char *pebuf;
	char *pgbuf;

	expect_string("ftoa(a)", ftoa(raw, a), "18.44");
	expect_string("ftoa(b)", ftoa(raw, b), ".125");
	expect_string("ftoa(c)", ftoa(raw, c), "1234.5");

	{
		float *ap = &a;
		pebuf = pffloat('e', 6, &ap);
		expect_string("pffloat(e)", pebuf, "1.844000e+01");
		ap = &a;
		pgbuf = pffloat('g', 6, &ap);
		expect_string("pffloat(g)", pgbuf, "18.44");
		ap = &a;
		expect_string("pffloat(f)", pffloat('f', 6, &ap), "18.440000");
		ap = &a;
		expect_string("pffloat(E)", pffloat('E', 6, &ap), "1.844000E+01");
		ap = &a;
		expect_string("pffloat(G)", pffloat('G', 6, &ap), "18.44");
	}

	sprintf(buf, "%f", a);
	expect_string("sprintf float f", buf, "18.440000");
	sprintf(buf, "%e", a);
	expect_string("sprintf float e", buf, "1.844000e+01");
	sprintf(buf, "%g", a);
	expect_string("sprintf float g", buf, "18.44");

	sprintf(buf, "%.4f", b);
	expect_string("sprintf float .4f", buf, "0.1250");
	sprintf(buf, "%.4e", b);
	expect_string("sprintf float .4e", buf, "1.2500e-01");
	sprintf(buf, "%.4g", b);
	expect_string("sprintf float .4g", buf, "0.125");

	sprintf(buf, "%.2f", c);
	expect_string("sprintf float .2f", buf, "1234.50");
	sprintf(buf, "%.2e", c);
	expect_string("sprintf float .2e", buf, "1.23e+03");
	sprintf(buf, "%.2g", c);
	expect_string("sprintf float .2g", buf, "1.2e+03");

	return failed;
}
