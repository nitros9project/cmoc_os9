#include <stdio.h>
#include <stdlib.h>

static int failed;

static void
check_long(const char *name, long actual, long expected)
{
    char actual_buf[16];
    char expected_buf[16];

    if (actual == expected) {
        printf("%s [PASS]\n", name);
        return;
    }

    ltoa(actual, actual_buf);
    ltoa(expected, expected_buf);
    printf("%s [FAIL] actual=%s expected=%s\n", name, actual_buf, expected_buf);
    failed = 1;
}

static void
check_true(const char *name, int condition)
{
    if (condition)
        printf("%s [PASS]\n", name);
    else {
        printf("%s [FAIL]\n", name);
        failed = 1;
    }
}

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

static long
keep_long(long value)
{
    return value;
}

static unsigned long
keep_ulong(unsigned long value)
{
    return value;
}

static int
keep_int(int value)
{
    return value;
}

static void
test_add_sub_mul(void)
{
    long a = keep_long(123456L);
    long b = keep_long(-7890L);
    long c = keep_long(32768L);

    check_long("long add positive negative", a + b, 115566L);
    check_long("long add carry", 65535L + 2L, 65537L);
    check_long("long subtract negative", a - b, 131346L);
    check_long("long subtract borrow", 65536L - 1L, 65535L);
    check_long("long multiply small", 123L * 456L, 56088L);
    check_long("long multiply carry", c * 3L, 98304L);
    check_long("long multiply negative", b * 10L, -78900L);
    check_long("long multiply high byte", keep_long(0x01020304L) * keep_long(16L), 0x10203040L);
    check_long("long add overflow wrap", keep_long(0x7fffffffL) + keep_long(1L), -2147483648L);
    check_long("long subtract underflow wrap", keep_long(-2147483648L) - keep_long(1L), 2147483647L);
}

static void
test_div_mod(void)
{
    long a = keep_long(1234567L);
    long b = keep_long(-1234567L);
    long c = keep_long(1234567L);
    long d = keep_long(-97L);
    unsigned long ua = keep_ulong(1000000UL);
    unsigned long ub = keep_ulong(97UL);

    check_long("long divide positive", a / keep_long(97L), 12727L);
    check_long("long modulus positive", a % keep_long(97L), 48L);
    check_long("long divide negative lhs", b / keep_long(97L), -12727L);
    check_long("long modulus negative lhs", b % keep_long(97L), -48L);
    check_long("long divide negative rhs", c / d, -12727L);
    check_long("long modulus negative rhs", c % d, 48L);
    check_long("long divide both negative", b / d, 12727L);
    check_long("long modulus both negative", b % d, -48L);
    check_long("unsigned long divide", (long) (ua / ub), 10309L);
    check_long("unsigned long modulus", (long) (ua % ub), 27L);
    check_long("unsigned high divide", (long) (keep_ulong(0x80000000UL) / keep_ulong(256UL)), 8388608L);
    check_long("unsigned high modulus", (long) (keep_ulong(0x80000001UL) % keep_ulong(256UL)), 1L);
}

static void
test_bitwise_shift(void)
{
    long a = keep_long(0x12345678L);
    long b = keep_long(0x00ff00ffL);
    long neg = keep_long(-1024L);
    unsigned long u = keep_ulong(0x01000000UL);
    int zero = keep_int(0);
    int four = keep_int(4);
    int eight = keep_int(8);
    int twelve = keep_int(12);

    check_long("long and", a & b, 0x00340078L);
    check_long("long or", a | b, 0x12ff56ffL);
    check_long("long xor", a ^ b, 0x12cb5687L);
    check_long("long complement", ~a, -305419897L);
    check_long("long shift left", keep_long(0x12345L) << four, 0x123450L);
    check_long("long shift left zero", a << zero, 0x12345678L);
    check_long("long shift left byte", keep_long(0x12345678L) << eight, 0x34567800L);
    check_long("long arithmetic shift right", neg >> keep_int(3), -128L);
    check_long("long arithmetic shift right byte", keep_long(-65536L) >> eight, -256L);
    check_long("unsigned long shift right", (long) (u >> eight), 0x00010000L);
    check_long("unsigned long shift right wide", (long) (keep_ulong(0x80000000UL) >> twelve), 0x00080000L);
}

static void
test_compare_logical(void)
{
    long a = keep_long(123456L);
    long b = keep_long(-1L);
    long z = keep_long(0L);
    unsigned long ua = keep_ulong(40000UL);
    unsigned long ub = keep_ulong(30000UL);
    unsigned long high = keep_ulong(0x80000000UL);
    unsigned long low = keep_ulong(0x7fffffffUL);

    check_true("long compare less", b < a);
    check_true("long compare greater", a > b);
    check_true("long compare equal", a == 123456L);
    check_true("long compare not equal", a != b);
    check_true("unsigned long compare", ua > ub);
    check_true("unsigned high compare", high > low);
    check_true("signed high compare", (long) high < (long) low);
    check_int("long logical not zero", !z, 1);
    check_int("long logical not nonzero", !a, 0);
}

static void
test_conversion_incdec_move(void)
{
    int i = keep_int(-12345);
    unsigned int u = (unsigned int) keep_int(54321);
    long li = i;
    long lu = u;
    long x = keep_long(99L);
    long carry = keep_long(65535L);
    long borrow = keep_long(65536L);
    long y;
    long arr[3];

    check_long("int to long", li, -12345L);
    check_long("unsigned to long", lu, 54321L);

    ++x;
    check_long("long preincrement", x, 100L);
    x--;
    check_long("long postdecrement", x, 99L);

    ++carry;
    check_long("long increment carry", carry, 65536L);
    --borrow;
    check_long("long decrement borrow", borrow, 65535L);

    y = x;
    check_long("long assignment", y, 99L);

    arr[0] = keep_long(1L);
    arr[1] = keep_long(2L);
    arr[2] = arr[0] + arr[1];
    check_long("long array copy", arr[2], 3L);
    arr[1] = arr[2] = keep_long(0x12345678L);
    check_long("long chained assignment", arr[1], 0x12345678L);
    check_long("long chained assignment rhs", arr[2], 0x12345678L);
}

static void
test_unary(void)
{
    long a = keep_long(123456L);
    long b = keep_long(-1L);
    long c = keep_long(0L);

    check_long("long unary negative", -a, -123456L);
    check_long("long unary negative of negative", -b, 1L);
    check_long("long unary negative zero", -c, 0L);
    check_long("long complement zero", ~c, -1L);
}

int
main(void)
{
    test_add_sub_mul();
    test_div_mod();
    test_bitwise_shift();
    test_compare_logical();
    test_conversion_incdec_move();
    test_unary();

    return failed;
}
