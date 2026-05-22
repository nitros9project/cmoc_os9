#include <arg.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

static int cflag;
static int lflag;
static int wflag;

static unsigned long total_bytes;
static unsigned long total_lines;
static unsigned long total_words;

static void
print_counts(const char *name, unsigned long bytes, unsigned long lines,
             unsigned long words)
{
    int first = 1;

    if (lflag) {
        printf("%lu", lines);
        first = 0;
    }
    if (wflag) {
        if (!first)
            putchar(' ');
        printf("%lu", words);
        first = 0;
    }
    if (cflag) {
        if (!first)
            putchar(' ');
        printf("%lu", bytes);
    }
    if (name)
        printf(" %s", name);
    putchar('\n');
}

static int
count_file(FILE *fp, const char *name)
{
    int ch;
    int in_word = 0;
    int prev_cr = 0;
    unsigned long bytes = 0;
    unsigned long lines = 0;
    unsigned long words = 0;

    while ((ch = fgetc(fp)) != EOF) {
        bytes++;
        if (ch == '\r') {
            lines++;
            prev_cr = 1;
        } else if (ch == '\n') {
            if (!prev_cr)
                lines++;
            prev_cr = 0;
        } else {
            prev_cr = 0;
        }
        if (isspace((unsigned char) ch)) {
            if (in_word) {
                words++;
                in_word = 0;
            }
        } else {
            in_word = 1;
        }
    }

    if (in_word)
        words++;

    if (ferror(fp)) {
        fprintf(stderr, "wc: read error on %s\n", name ? name : "<stdin>");
        return 1;
    }

    total_bytes += bytes;
    total_lines += lines;
    total_words += words;
    print_counts(name, bytes, lines, words);
    return 0;
}

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-clmw] [file ...]\n", progname);
}

int
main(int argc, char **argv)
{
    FILE *fp;
    int ch;
    int ret = 0;
    int many;

    while ((ch = getopt(argc, argv, "clmw")) != -1) {
        switch (ch) {
        case 'c':
        case 'm':
            cflag = 1;
            break;
        case 'l':
            lflag = 1;
            break;
        case 'w':
            wflag = 1;
            break;
        default:
            usage(argv[0]);
            return 1;
        }
    }

    if (!cflag && !lflag && !wflag) {
        cflag = 1;
        lflag = 1;
        wflag = 1;
    }

    argv += optind;
    argc -= optind;
    many = (argc > 1);

    if (argc == 0) {
        ret |= count_file(stdin, 0);
    } else {
        while (*argv) {
            if (strcmp(*argv, "-") == 0) {
                ret |= count_file(stdin, *argv);
            } else {
                fp = fopen(*argv, "r");
                if (!fp) {
                    fprintf(stderr, "wc: cannot open %s\n", *argv);
                    ret = 1;
                } else {
                    ret |= count_file(fp, *argv);
                    fclose(fp);
                }
            }
            argv++;
        }
    }

    if (many)
        print_counts("total", total_bytes, total_lines, total_words);

    fflush(stdout);
    fflush(stderr);
    return ret;
}
