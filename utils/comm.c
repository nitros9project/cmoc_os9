/*
 * Adapted from suckless sbase comm.
 */

#include <stdio.h>
#include <string.h>

#define LINEBUF 256

static int show = 7;

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-123] file1 file2\n", progname);
}

static void
print_line(int col, char *line)
{
    int i;

    if (!(show & (1 << col)))
        return;
    for (i = 0; i < col; i++) {
        if (show & (1 << i))
            putchar('\t');
    }
    fputs(line, stdout);
}

int
main(int argc, char **argv)
{
    FILE *fp[2];
    char line0[LINEBUF];
    char line1[LINEBUF];
    char *p0 = 0;
    char *p1 = 0;
    int cmp;
    int i;
    int ret = 0;

    argv++;
    argc--;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        for (i = 1; argv[0][i]; i++) {
            if (argv[0][i] >= '1' && argv[0][i] <= '3')
                show &= ~(1 << (argv[0][i] - '1'));
            else {
                usage("comm");
                return 1;
            }
        }
        argv++;
        argc--;
    }

    if (argc != 2) {
        usage("comm");
        return 1;
    }

    for (i = 0; i < 2; i++) {
        if (strcmp(argv[i], "-") == 0) {
            fp[i] = stdin;
        } else {
            fp[i] = fopen(argv[i], "r");
            if (!fp[i]) {
                fprintf(stderr, "comm: cannot open %s\n", argv[i]);
                if (i == 1 && fp[0] != stdin)
                    fclose(fp[0]);
                return 1;
            }
        }
    }

    p0 = fgets(line0, sizeof(line0), fp[0]);
    p1 = fgets(line1, sizeof(line1), fp[1]);
    while (p0 || p1) {
        if (!p0) {
            print_line(1, line1);
            p1 = fgets(line1, sizeof(line1), fp[1]);
        } else if (!p1) {
            print_line(0, line0);
            p0 = fgets(line0, sizeof(line0), fp[0]);
        } else {
            cmp = strcmp(line0, line1);
            if (cmp < 0) {
                print_line(0, line0);
                p0 = fgets(line0, sizeof(line0), fp[0]);
            } else if (cmp > 0) {
                print_line(1, line1);
                p1 = fgets(line1, sizeof(line1), fp[1]);
            } else {
                print_line(2, line0);
                p0 = fgets(line0, sizeof(line0), fp[0]);
                p1 = fgets(line1, sizeof(line1), fp[1]);
            }
        }
    }

    if (ferror(fp[0]) || ferror(fp[1])) {
        fprintf(stderr, "comm: read error\n");
        ret = 1;
    }
    if (fp[0] != stdin)
        fclose(fp[0]);
    if (fp[1] != stdin && fp[1] != fp[0])
        fclose(fp[1]);
    fflush(stdout);

    return ret;
}
