/*
 * Adapted from suckless sbase seq.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-s sep] [start [step]] end\n", progname);
}

static int
parse_long(const char *text, long *value)
{
    char *end;

    *value = strtol(text, &end, 10);
    return *text != '\0' && *end == '\0';
}

int
main(int argc, char **argv)
{
    char default_sep[] = "\n";
    char *sep;
    long start = 1;
    long step = 1;
    long end;
    long n;
    int first = 1;

    argv++;
    argc--;
    sep = default_sep;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        if (strcmp(argv[0], "-s") == 0) {
            if (argc < 2) {
                usage("seq");
                return 1;
            }
            sep = argv[1];
            argv += 2;
            argc -= 2;
        } else {
            usage("seq");
            return 1;
        }
    }

    if (argc == 1) {
        if (!parse_long(argv[0], &end)) {
            usage("seq");
            return 1;
        }
    } else if (argc == 2) {
        if (!parse_long(argv[0], &start) || !parse_long(argv[1], &end)) {
            usage("seq");
            return 1;
        }
    } else if (argc == 3) {
        if (!parse_long(argv[0], &start) || !parse_long(argv[1], &step) ||
            !parse_long(argv[2], &end)) {
            usage("seq");
            return 1;
        }
    } else {
        usage("seq");
        return 1;
    }

    if (step == 0)
        return 1;

    if (step > 0) {
        for (n = start; n <= end; n += step) {
            if (!first)
                fputs(sep, stdout);
            printf("%ld", n);
            first = 0;
        }
    } else {
        for (n = start; n >= end; n += step) {
            if (!first)
                fputs(sep, stdout);
            printf("%ld", n);
            first = 0;
        }
    }
    putchar('\n');
    fflush(stdout);

    return ferror(stdout) ? 1 : 0;
}
