/*
 * Adapted from suckless sbase tail.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINEBUF 256
#define MAXTAIL 100

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-num | -n num] [file ...]\n", progname);
}

static int
parse_count(const char *text, unsigned int *count)
{
    char *end;
    unsigned long value;

    value = strtoul(text, &end, 10);
    if (*text == '\0' || *end != '\0' || value == 0 || value > MAXTAIL)
        return 0;
    *count = (unsigned int) value;
    return 1;
}

static int
tail_file(FILE *fp, const char *name, unsigned int count)
{
    char lines[MAXTAIL][LINEBUF];
    char buf[LINEBUF];
    unsigned int used = 0;
    unsigned int next = 0;
    unsigned int start;
    unsigned int i;
    unsigned int idx;

    while (fgets(buf, sizeof(buf), fp)) {
        strcpy(lines[next], buf);
        next = (next + 1) % count;
        if (used < count)
            used++;
    }

    if (ferror(fp)) {
        fprintf(stderr, "tail: read error on %s\n", name);
        return 1;
    }

    if (used == count)
        start = next;
    else
        start = 0;
    for (i = 0; i < used; i++) {
        idx = (start + i) % count;
        if (fputs(lines[idx], stdout) == EOF) {
            fprintf(stderr, "tail: write error on <stdout>\n");
            return 1;
        }
    }

    return 0;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    unsigned int count = 10;
    int many;
    int newline = 0;
    int ret = 0;

    argv++;
    argc--;

    while (argc > 0 && argv[0][0] == '-') {
        if (strcmp(argv[0], "-") == 0)
            break;
        if (strcmp(argv[0], "-n") == 0) {
            if (argc < 2 || !parse_count(argv[1], &count)) {
                usage("tail");
                return 1;
            }
            argv += 2;
            argc -= 2;
            continue;
        }
        if (argv[0][1] && parse_count(argv[0] + 1, &count)) {
            argv++;
            argc--;
            continue;
        }
        usage("tail");
        return 1;
    }

    many = argc > 1;
    if (argc == 0) {
        ret = tail_file(stdin, "<stdin>", count);
    } else {
        while (argc-- > 0) {
            if (strcmp(*argv, "-") == 0) {
                fp = stdin;
            } else {
                fp = fopen(*argv, "r");
                if (!fp) {
                    fprintf(stderr, "tail: cannot open %s\n", *argv);
                    ret = 1;
                    argv++;
                    continue;
                }
            }
            if (many) {
                if (newline)
                    putchar('\n');
                if (fp == stdin)
                    printf("==> <stdin> <==\n");
                else
                    printf("==> %s <==\n", *argv);
            }
            newline = 1;
            if (fp == stdin)
                ret |= tail_file(fp, "<stdin>", count);
            else
                ret |= tail_file(fp, *argv, count);
            if (fp != stdin)
                fclose(fp);
            argv++;
        }
    }

    fflush(stdout);
    return ret;
}
