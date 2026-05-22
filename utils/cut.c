#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Range {
    unsigned int min;
    unsigned int max;
    struct Range *next;
} Range;

static Range *ranges;
static char delim = '\t';
static int sflag;

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s -f list [-d delim] [-s] [file ...]\n", progname);
}

static Range *
new_range(unsigned int min, unsigned int max)
{
    static Range pool[64];
    static unsigned int used;
    Range *r;

    if (used >= 64)
        return 0;
    r = &pool[used++];
    r->min = min;
    r->max = max;
    r->next = 0;
    return r;
}

static int
parse_uint(const char **sp, unsigned int *value)
{
    const char *s = *sp;
    unsigned int n = 0;

    if (*s < '0' || *s > '9')
        return 0;
    while (*s >= '0' && *s <= '9') {
        n = n * 10 + (unsigned int) (*s - '0');
        s++;
    }
    *sp = s;
    *value = n;
    return 1;
}

static int
append_range(unsigned int min, unsigned int max)
{
    Range *r;
    Range *tail;

    r = new_range(min, max);
    if (!r)
        return 0;
    if (!ranges) {
        ranges = r;
        return 1;
    }
    for (tail = ranges; tail->next; tail = tail->next)
        ;
    tail->next = r;
    return 1;
}

static int
parse_list(char *text)
{
    const char *s = text;
    unsigned int min;
    unsigned int max;

    if (!*s)
        return 0;

    while (*s) {
        if (*s == '-') {
            min = 1;
        } else if (!parse_uint(&s, &min) || min == 0) {
            return 0;
        }

        if (*s == '-') {
            s++;
            if (*s == '\0' || *s == ',') {
                max = 0;
            } else if (!parse_uint(&s, &max) || max < min) {
                return 0;
            }
        } else {
            max = min;
        }

        if (!append_range(min, max))
            return 0;

        if (*s == ',') {
            s++;
            continue;
        }
        if (*s != '\0')
            return 0;
    }

    return 1;
}

static int
parse_delim(const char *text, char *out)
{
    if (!text || text[0] == '\0')
        return 0;

    if (strcmp(text, "space") == 0) {
        *out = ' ';
        return 1;
    }
    if (strcmp(text, "tab") == 0) {
        *out = '\t';
        return 1;
    }
    if (strcmp(text, "nl") == 0) {
        *out = '\n';
        return 1;
    }
    if (strcmp(text, "cr") == 0) {
        *out = '\r';
        return 1;
    }
    if (strcmp(text, "bs") == 0) {
        *out = '\\';
        return 1;
    }

    if (text[0] != '\\') {
        *out = text[0];
        return 1;
    }

    switch (text[1]) {
    case '0':
        *out = '\0';
        return text[2] == '\0';
    case 't':
        *out = '\t';
        return text[2] == '\0';
    case 'n':
        *out = '\n';
        return text[2] == '\0';
    case 'r':
        *out = '\r';
        return text[2] == '\0';
    case 's':
        *out = ' ';
        return text[2] == '\0';
    case '\\':
        *out = '\\';
        return text[2] == '\0';
    default:
        return 0;
    }
}

static void
output_line(char *line)
{
    Range *r;
    unsigned int field = 1;
    int first = 1;
    char *start = line;
    char *p = line;

    while (1) {
        if (*p == delim || *p == '\0' || *p == '\r' || *p == '\n') {
            for (r = ranges; r; r = r->next) {
                if (field >= r->min && (r->max == 0 || field <= r->max)) {
                    if (!first)
                        putchar(delim);
                    fwrite(start, 1, (size_t) (p - start), stdout);
                    first = 0;
                    break;
                }
            }

            if (*p == '\0' || *p == '\r' || *p == '\n')
                break;

            field++;
            start = p + 1;
        }
        p++;
    }

    putchar('\n');
}

static int
cut_file(FILE *fp, const char *name)
{
    char line[512];

    while (fgets(line, sizeof(line), fp)) {
        if (!strchr(line, delim)) {
            if (!sflag)
                fputs(line, stdout);
            continue;
        }
        output_line(line);
    }

    if (ferror(fp)) {
        fprintf(stderr, "cut: read error on %s\n", name);
        return 1;
    }

    return 0;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    int ret = 0;
    int status;
    char *list = 0;

    argv++;
    argc--;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        if (strcmp(argv[0], "-f") == 0) {
            if (argc < 2) {
                usage("cut");
                return 1;
            }
            list = argv[1];
            argv += 2;
            argc -= 2;
        } else if (argv[0][1] == 'f' && argv[0][2] != '\0') {
            list = argv[0] + 2;
            argv++;
            argc--;
        } else if (strcmp(argv[0], "-d") == 0) {
            if (argc < 2 || !parse_delim(argv[1], &delim)) {
                usage("cut");
                return 1;
            }
            argv += 2;
            argc -= 2;
        } else if (argv[0][1] == 'd' && argv[0][2] != '\0') {
            if (!parse_delim(argv[0] + 2, &delim)) {
                usage("cut");
                return 1;
            }
            argv++;
            argc--;
        } else if (strcmp(argv[0], "-s") == 0) {
            sflag = 1;
            argv++;
            argc--;
        } else {
            usage("cut");
            return 1;
        }
    }

    if (!list || !parse_list(list)) {
        usage("cut");
        return 1;
    }

    if (argc == 0) {
        ret = cut_file(stdin, "<stdin>");
    } else {
        while (*argv) {
            if (strcmp(*argv, "-") == 0) {
                status = cut_file(stdin, "<stdin>");
            } else {
                fp = fopen(*argv, "r");
                if (!fp) {
                    fprintf(stderr, "cut: cannot open %s\n", *argv);
                    ret = 1;
                    argv++;
                    continue;
                }
                status = cut_file(fp, *argv);
                fclose(fp);
            }
            if (status)
                ret = 1;
            argv++;
        }
    }

    fflush(stdout);
    fflush(stderr);
    return ret;
}
