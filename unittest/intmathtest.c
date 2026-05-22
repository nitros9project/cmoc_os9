#include <stdio.h>

static int failed;
static int mul_a = 123;
static int mul_b = -45;
static unsigned mul_ua = 40000U;
static unsigned mul_ub = 3U;
static int div_a = 12345;
static int div_b = -12345;
static unsigned div_ua = 60000U;
static unsigned div_ub = 97U;
static int shift_neg = -1024;
static int shift_pos = 0x1234;
static unsigned shift_upos = 0x8000U;
static int shift_count = 3;
static int shift_zero = 0;

static void
check_int(const char *name, int actual, int expected)
{
    if (actual == expected)
        printf("%s [PASS]\n", name);
    else {
        printf("%s [FAIL] actual=%d expected=%d\n", name, actual, expected);
        failed = 1;
    }
}

static void
check_uint(const char *name, unsigned actual, unsigned expected)
{
    if (actual == expected)
        printf("%s [PASS]\n", name);
    else {
        printf("%s [FAIL] actual=%u expected=%u\n", name, actual, expected);
        failed = 1;
    }
}

static void
test_multiply(void)
{
	check_int("int multiply positive", mul_a * 45, 5535);
	check_int("int multiply negative", mul_a * mul_b, -5535);
	check_int("int multiply high byte", 0x1234 * 16, 0x2340);
	check_uint("unsigned multiply wrap", mul_ua * mul_ub, 54464U);
}

static void
test_divide_mod(void)
{
    check_int("int divide positive", div_a / 97, 127);
    check_int("int modulus positive", div_a % 97, 26);
	check_int("int divide negative lhs", div_b / 97, -127);
	check_int("int modulus negative lhs", div_b % 97, -26);
	check_int("int divide negative rhs", div_a / -97, -127);
	check_int("int modulus negative rhs", div_a % -97, 26);
	check_int("int divide both negative", div_b / -97, 127);
	check_int("int modulus both negative", div_b % -97, -26);
	check_uint("unsigned divide", div_ua / div_ub, 618U);
	check_uint("unsigned modulus", div_ua % div_ub, 54U);
}

static void
test_shifts(void)
{
	check_int("int arithmetic shift right", shift_neg >> shift_count, -128);
	check_int("int shift left", shift_pos << shift_count, 0x91a0);
	check_int("int shift left zero", shift_pos << shift_zero, shift_pos);
	check_int("int arithmetic shift right zero", shift_neg >> shift_zero, shift_neg);
	check_uint("unsigned logical shift right", shift_upos >> shift_count, 0x1000U);
	check_uint("unsigned shift left wrap", shift_upos << 1, 0U);
	check_uint("unsigned logical shift right zero", shift_upos >> shift_zero, shift_upos);
}

int
main(void)
{
    test_multiply();
    test_divide_mod();
    test_shifts();

    return failed;
}
