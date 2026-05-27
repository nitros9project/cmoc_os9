#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static const char text_file[] = "fiotest.out.tmp";
static const char word_file[] = "fiotest.word.tmp";
static int failed;

static void check_true(const char *name, int condition)
{
    if (condition)
        printf("%s [PASS]\n", name);
    else {
        printf("%s [FAIL]\n", name);
        failed = 1;
    }
}

static void test_text_output(void)
{
    FILE *fp;
    char buf[256];
    size_t n;
    const char expected[] =
        "123\n"
        "fputs test\n"
        "printf Hello world!\n"
        "printf Hello small world!\n"
        "printf Hello CoCo community!\n"
        "printf Long value is 32\n"
        "fprintf Hello world!\n"
        "fprintf Hello small world!\n"
        "fprintf Hello CoCo community!\n";

    unlink(text_file);
    fp = fopen(text_file, "w+");
    if (fp == 0) {
        printf("%s [FAIL] fopen(w+)\n", __func__);
        failed = 1;
        return;
    }

    check_true("test_text_output putc(1)", putc('1', fp) == '1');
    check_true("test_text_output putc(2)", putc('2', fp) == '2');
    check_true("test_text_output putc(3)", putc('3', fp) == '3');
    check_true("test_text_output putc(\\n)", putc('\n', fp) == '\n');
    check_true("test_text_output fputs()", fputs("fputs test\n", fp) >= 0);
    check_true("test_text_output printf()", fprintf(fp, "printf Hello world!\n") > 0);
    check_true("test_text_output printf(%s)",
               fprintf(fp, "printf Hello %s world!\n", "small") > 0);
    check_true("test_text_output printf(%s,%s)",
               fprintf(fp, "printf Hello %s %s!\n", "CoCo", "community") > 0);
    check_true("test_text_output printf(%ld)",
               fprintf(fp, "printf Long value is %ld\n", 32L) > 0);
    check_true("test_text_output fprintf(world)",
               fprintf(fp, "fprintf Hello world!\n") > 0);
    check_true("test_text_output fprintf(%s)",
               fprintf(fp, "fprintf Hello %s world!\n", "small") > 0);
    check_true("test_text_output fprintf(%s,%s)",
               fprintf(fp, "fprintf Hello %s %s!\n", "CoCo", "community") > 0);
    check_true("test_text_output fflush()", fflush(fp) == 0);
    fclose(fp);

    fp = fopen(text_file, "r");
    if (fp == 0) {
        printf("%s [FAIL] fopen(readback)\n", __func__);
        unlink(text_file);
        failed = 1;
        return;
    }
    memset(buf, 0, sizeof(buf));
    n = fread(buf, 1, sizeof(buf) - 1, fp);
    check_true("test_text_output fread()", n > 0 && ferror(fp) == 0);
    check_true("test_text_output content", strcmp(buf, expected) == 0);

    fclose(fp);
    unlink(text_file);
}

static void test_stdout_puts(void)
{
    check_true("test_stdout_puts puts()", puts("fiotest stdout smoke") >= 0);
}

static void test_putw(void)
{
    FILE *fp;
    int value;

    unlink(word_file);
    fp = fopen(word_file, "w+");
    if (fp == 0) {
        printf("%s [FAIL] fopen(w+)\n", __func__);
        failed = 1;
        return;
    }

    check_true("test_putw putw()", putw(0x1234, fp) == 0);
    check_true("test_putw fflush()", fflush(fp) == 0);
    rewind(fp);
    value = getw(fp);
    check_true("test_putw getw()", value == 0x1234);

    fclose(fp);
    unlink(word_file);
}

int main(void)
{
    test_text_output();
    test_stdout_puts();
    test_putw();
    return failed;
}
