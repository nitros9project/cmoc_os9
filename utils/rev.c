/*
 * Adapted from suckless sbase rev.
 */

#include <stdio.h>
#include <string.h>

#define LINEBUF 256

static int
rev_stream(FILE *fp, const char *name)
{
    char buf[LINEBUF];
    int len;
    int end;
    int i;
    int ret = 0;

    while (fgets(buf, sizeof(buf), fp)) {
        len = strlen(buf);
        end = len;
        while (end > 0 && (buf[end - 1] == '\n' || buf[end - 1] == '\r'))
            end--;

        for (i = end - 1; i >= 0; i--)
            putchar(buf[i]);
        for (i = end; i < len; i++)
            putchar(buf[i]);
    }

    if (ferror(fp)) {
        fprintf(stderr, "rev: read error on %s\n", name);
        ret = 1;
    }
    if (ferror(stdout)) {
        fprintf(stderr, "rev: write error on <stdout>\n");
        ret = 1;
    }

    return ret;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    int ret = 0;

    argv++;
    argc--;

    if (argc > 0 && strcmp(argv[0], "--") == 0) {
        argv++;
        argc--;
    }

    if (argc == 0) {
        ret = rev_stream(stdin, "<stdin>");
    } else {
        while (argc-- > 0) {
            if (strcmp(*argv, "-") == 0) {
                ret |= rev_stream(stdin, "<stdin>");
            } else {
                fp = fopen(*argv, "r");
                if (!fp) {
                    fprintf(stderr, "rev: cannot open %s\n", *argv);
                    ret = 1;
                } else {
                    ret |= rev_stream(fp, *argv);
                    fclose(fp);
                }
            }
            argv++;
        }
    }

    fflush(stdout);
    return ret;
}
