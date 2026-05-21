/*
 * Adapted from suckless sbase split.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NAMEBUF 32

static int suffix_base = 26;
static int suffix_start = 'a';

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-a num] [-l num] [-d] [file [prefix]]\n",
            progname);
}

static int
make_suffix(char *out, int number, int width)
{
    out[width] = '\0';
    while (width-- > 0) {
        out[width] = (char) (suffix_start + (number % suffix_base));
        number /= suffix_base;
    }
    return number == 0;
}

static FILE *
next_file(FILE *old, const char *prefix, int number, int width)
{
    char name[NAMEBUF];
    char suffix[8];

    if (old)
        fclose(old);
    if (!make_suffix(suffix, number, width))
        return 0;
    strcpy(name, prefix);
    strcat(name, suffix);
    return fopen(name, "w");
}

int
main(int argc, char **argv)
{
    FILE *in = stdin;
    FILE *out = 0;
    char default_prefix[] = "x";
    char *file = 0;
    char *prefix;
    char *end;
    unsigned long lines_per_file = 1000;
    unsigned long line_count = 0;
    int suffix_width = 2;
    int file_count = 0;
    int ch;
    int ret = 0;

    argv++;
    argc--;
    prefix = default_prefix;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        if (strcmp(argv[0], "-d") == 0) {
            suffix_base = 10;
            suffix_start = '0';
        } else if (strcmp(argv[0], "-a") == 0) {
            if (argc < 2) {
                usage("split");
                return 1;
            }
            suffix_width = (int) strtoul(argv[1], &end, 10);
            if (*argv[1] == '\0' || *end != '\0' ||
                suffix_width <= 0 || suffix_width > 7) {
                usage("split");
                return 1;
            }
            argv++;
            argc--;
        } else if (strcmp(argv[0], "-l") == 0) {
            if (argc < 2) {
                usage("split");
                return 1;
            }
            lines_per_file = strtoul(argv[1], &end, 10);
            if (*argv[1] == '\0' || *end != '\0' || lines_per_file == 0) {
                usage("split");
                return 1;
            }
            argv++;
            argc--;
        } else {
            usage("split");
            return 1;
        }
        argv++;
        argc--;
    }

    if (argc > 0)
        file = *argv++;
    if (argc > 1)
        prefix = *argv++;
    if (argc > 2 || strlen(prefix) + suffix_width >= NAMEBUF) {
        usage("split");
        return 1;
    }

    if (file && strcmp(file, "-") != 0) {
        in = fopen(file, "r");
        if (!in) {
            fprintf(stderr, "split: cannot open %s\n", file);
            return 1;
        }
    }

    while ((ch = getc(in)) != EOF) {
        if (!out || line_count >= lines_per_file) {
            out = next_file(out, prefix, file_count++, suffix_width);
            if (!out) {
                fprintf(stderr, "split: cannot create output file\n");
                ret = 1;
                break;
            }
            line_count = 0;
        }
        if (putc(ch, out) == EOF) {
            fprintf(stderr, "split: write error\n");
            ret = 1;
            break;
        }
        if (ch == '\n' || ch == '\r')
            line_count++;
    }

    if (ferror(in)) {
        fprintf(stderr, "split: read error\n");
        ret = 1;
    }
    if (in != stdin)
        fclose(in);
    if (out)
        fclose(out);

    return ret;
}
