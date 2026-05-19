#include <stdio.h>
#include <math.h>
#include <stdlib.h>

static int failed;

static void check_near(const char *name, float actual, float expected, float tolerance)
{
	float diff = actual - expected;

	if (diff < 0.0f)
		diff = -diff;

	if (diff <= tolerance)
		printf("%s [PASS]\n", name);
	else {
		printf("%s [FAIL] actual=%f expected=%f\n", name, actual, expected);
		failed = 1;
	}
}

static void check_int(const char *name, int actual, int expected)
{
	if (actual == expected)
		printf("%s [PASS]\n", name);
	else {
		printf("%s [FAIL] actual=%d expected=%d\n", name, actual, expected);
		failed = 1;
	}
}

int main(int argc, char *argv[])
{
	float f0 = 0.0f, f1 = 18.44f;
	printf("floattest [INFO] before sum\n");
	float sum = f0 + f1;
	printf("floattest [INFO] before atof1\n");
	float parsed = atof("123.5");
	printf("floattest [INFO] before atof2\n");
	float parsed_exp = atof("6.25e1");
	printf("floattest [INFO] before atof3\n");
	float parsed_exp_upper = atof("6.25E1");
	int exp = 0;
	printf("floattest [INFO] before frexp\n");
	float frac = frexp(sum, &exp);
	printf("floattest [INFO] before ldexp\n");
	float roundtrip = ldexp(frac, exp);
	printf("floattest [INFO] before print1\n");

	printf("f0=[%f], f1=[%f], sum=[%f]\n", f0, f1, sum);
	printf("floattest [INFO] before print2\n");
	printf("parsed=[%f], parsed_exp=[%f], parsed_exp_upper=[%f]\n",
	       parsed, parsed_exp, parsed_exp_upper);
	printf("floattest [INFO] before print3\n");
	printf("frac=[%f]\n", frac);
	printf("exp=[%d]\n", exp);
	printf("roundtrip=[%f]\n", roundtrip);
	printf("floattest [INFO] done\n");

	check_near("floattest sum", sum, 18.44f, 0.01f);
	check_near("floattest atof decimal", parsed, 123.5f, 0.01f);
	check_near("floattest atof exponent", parsed_exp, 62.5f, 0.01f);
	check_near("floattest atof uppercase exponent", parsed_exp_upper, 62.5f, 0.01f);
	check_int("floattest frexp exponent", exp, 5);
	check_near("floattest frexp fraction", frac, 0.57625f, 0.001f);
	check_near("floattest ldexp roundtrip", roundtrip, sum, 0.01f);

	return failed;
}
