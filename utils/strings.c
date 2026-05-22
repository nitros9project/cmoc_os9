/*
 * Adapted from suckless sbase strings.
 */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXRUN 256

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-a] [-n num] [file ...]\n", progname);
}

static int
strings_stream(FILE *fp, const char *name, unsigned int min)
{
    char run[MAXRUN];
    unsigned int len = 0;
    int printing = 0;
    int ch;

    while ((ch = fgetc(fp)) != EOF) {
        if (isprint((unsigned char) ch) || ch == '\t') {
            if (printing) {
                putchar(ch);
            } else {
                run[len++] = (char) ch;
                if (len == min) {
                    fwrite(run, 1, len, stdout);
                    printing = 1;
                }
            }
            continue;
        }

        if (printing)
            putchar('\n');
        len = 0;
        printing = 0;
    }

    if (printing)
        putchar('\n');

    if (ferror(fp)) {
        fprintf(stderr, "strings: read error on %s\n", name);
        return 1;
    }

    return 0;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    char *end;
    unsigned int min = 4;
    int ret = 0;

    argv++;
    argc--;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        if (strcmp(argv[0], "-a") == 0) {
            argv++;
            argc--;
        } else if (strcmp(argv[0], "-n") == 0) {
            if (argc < 2) {
                usage("strings");
                return 1;
            }
            min = (unsigned int) strtoul(argv[1], &end, 10);
            if (*argv[1] == '\0' || *end != '\0' || min == 0 ||
                min >= MAXRUN) {
                usage("strings");
                return 1;
            }
            argv += 2;
            argc -= 2;
        } else {
            usage("strings");
            return 1;
        }
    }

    if (argc == 0) {
        ret = strings_stream(stdin, "<stdin>", min);
    } else {
        while (argc-- > 0) {
            if (strcmp(*argv, "-") == 0) {
                ret |= strings_stream(stdin, "<stdin>", min);
            } else {
                fp = fopen(*argv, "r");
                if (!fp) {
                    fprintf(stderr, "strings: cannot open %s\n", *argv);
                    ret = 1;
                } else {
                    ret |= strings_stream(fp, *argv, min);
                    fclose(fp);
                }
            }
            argv++;
        }
    }

    fflush(stdout);
    return ret;
}
