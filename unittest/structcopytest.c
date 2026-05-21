#include <fcntl.h>
#include <stdio.h>

static int failed;

struct small_record {
    char a;
    int b;
    char c;
};

struct nested_record {
    char prefix;
    struct small_record inner;
    char suffix;
};

struct option_record {
    unsigned char bytes[32];
};

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
fill_option_record(struct option_record *rec, int seed)
{
    int i;

    for (i = 0; i < 32; i++)
        rec->bytes[i] = (unsigned char) (seed + i * 3);
}

static int
same_option_record(const struct option_record *lhs, const struct option_record *rhs)
{
    int i;

    for (i = 0; i < 32; i++) {
        if (lhs->bytes[i] != rhs->bytes[i])
            return 0;
    }
    return 1;
}

static int
same_sgbuf(const struct sgbuf *lhs, const struct sgbuf *rhs)
{
    const unsigned char *l = (const unsigned char *) lhs;
    const unsigned char *r = (const unsigned char *) rhs;
    int i;

    for (i = 0; i < 32; i++) {
        if (l[i] != r[i])
            return 0;
    }
    return 1;
}

static void
test_small_struct_copy(void)
{
    struct small_record src;
    struct small_record dst;

    src.a = 0x12;
    src.b = 0x3456;
    src.c = 0x78;
    dst.a = 0;
    dst.b = 0;
    dst.c = 0;

    dst = src;
    check_true("struct copy small",
               dst.a == 0x12 && dst.b == 0x3456 && dst.c == 0x78);
}

static void
test_nested_struct_copy(void)
{
    struct nested_record src;
    struct nested_record dst;

    src.prefix = 0x21;
    src.inner.a = 0x32;
    src.inner.b = 0x4354;
    src.inner.c = 0x65;
    src.suffix = 0x76;
    dst.prefix = 0;
    dst.inner.a = 0;
    dst.inner.b = 0;
    dst.inner.c = 0;
    dst.suffix = 0;

    dst = src;
    check_true("struct copy nested",
               dst.prefix == 0x21 &&
               dst.inner.a == 0x32 &&
               dst.inner.b == 0x4354 &&
               dst.inner.c == 0x65 &&
               dst.suffix == 0x76);
}

static void
test_32_byte_struct_copy(void)
{
    struct option_record src;
    struct option_record dst;
    struct option_record other;

    fill_option_record(&src, 7);
    fill_option_record(&dst, 0xa0);
    fill_option_record(&other, 0x33);

    dst = src;
    check_true("struct copy 32 byte", same_option_record(&dst, &src));
    check_true("struct copy 32 byte no overwrite",
               (unsigned char) other.bytes[0] == 0x33 &&
               (unsigned char) other.bytes[31] == (unsigned char) (0x33 + 31 * 3));
}

static void
test_sgbuf_struct_copy(void)
{
    struct sgbuf src;
    struct sgbuf dst;
    unsigned char *bytes;
    int i;

    bytes = (unsigned char *) &src;
    for (i = 0; i < 32; i++)
        bytes[i] = (unsigned char) (0x40 + i);

    bytes = (unsigned char *) &dst;
    for (i = 0; i < 32; i++)
        bytes[i] = 0;

    dst = src;
    check_true("struct copy sgbuf", same_sgbuf(&dst, &src));
}

int
main(void)
{
    test_small_struct_copy();
    test_nested_struct_copy();
    test_32_byte_struct_copy();
    test_sgbuf_struct_copy();
    return failed;
}
