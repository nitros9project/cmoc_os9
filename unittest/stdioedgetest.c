#include <stdio.h>
#include <string.h>
#include <unistd.h>

static const char edge_file[] = "stdioedge.tmp";
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

int main(void)
{
    FILE *fp;
    int ch;

    unlink(edge_file);
    fp = fopen(edge_file, "w");
    if (fp == 0) {
        printf("stdioedgetest [FAIL] fopen(write)\n");
        return 1;
    }
    fwrite("abc\r", 1, 4, fp);
    fclose(fp);

    fp = fopen(edge_file, "r");
    if (fp == 0) {
        printf("stdioedgetest [FAIL] fopen(read)\n");
        unlink(edge_file);
        return 1;
    }

    ch = fgetc(fp);
    check_true("stdioedgetest fgetc(first)", ch == 'a');
    check_true("stdioedgetest ungetc(first)", ungetc(ch, fp) == 'a');
    check_true("stdioedgetest fgetc(replayed)", fgetc(fp) == 'a');
    check_true("stdioedgetest fgetc(second)", fgetc(fp) == 'b');
    check_true("stdioedgetest fgetc(third)", fgetc(fp) == 'c');
    check_true("stdioedgetest fgetc(newline)", fgetc(fp) == '\r');
    check_true("stdioedgetest fgetc(eof)", fgetc(fp) == EOF);
    check_true("stdioedgetest feof()", feof(fp) != 0);
    check_true("stdioedgetest ferror(clear)", ferror(fp) == 0);

    clearerr(fp);
    if (feof(fp) == 0 && ferror(fp) == 0)
        printf("%s [PASS]\n", "stdioedgetest clearerr()");
    else {
        printf("%s [FAIL] flag=%04x eof=%d err=%d\n",
               "stdioedgetest clearerr()", fp->_flag, feof(fp), ferror(fp));
        failed = 1;
    }
    rewind(fp);
    check_true("stdioedgetest rewind()", ftell(fp) == 0L);
    check_true("stdioedgetest ungetc(start)", ungetc('Z', fp) == 'Z');
    check_true("stdioedgetest fgetc(injected)", fgetc(fp) == 'Z');
    check_true("stdioedgetest fgetc(after injected)", fgetc(fp) == 'a');

    fclose(fp);
    unlink(edge_file);
    return failed;
}
