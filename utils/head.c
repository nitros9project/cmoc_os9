#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
    if (*text == '\0' || *end != '\0')
        return 0;
    *count = (unsigned int) value;
    return 1;
}

static int
head_file(FILE *fp, const char *name, unsigned int count)
{
    char buf[256];
    unsigned int lines = 0;

    while (lines < count && fgets(buf, sizeof(buf), fp)) {
        if (fputs(buf, stdout) == EOF) {
            fprintf(stderr, "head: write error on <stdout>\n");
            return 2;
        }
        if (strchr(buf, '\n') || strchr(buf, '\r'))
            lines++;
    }

    if (ferror(fp)) {
        fprintf(stderr, "head: read error on %s\n", name);
        return 1;
    }

    return 0;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    int many;
    int ret = 0;
    int newline = 0;
    int status;
    unsigned int count = 10;

    argv++;
    argc--;

    while (argc > 0 && argv[0][0] == '-') {
        if (strcmp(argv[0], "-") == 0)
            break;
        if (strcmp(argv[0], "-n") == 0) {
            if (argc < 2 || !parse_count(argv[1], &count)) {
                usage("head");
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
        usage("head");
        return 1;
    }

    many = (argc > 1);

    if (argc == 0) {
        ret = head_file(stdin, "<stdin>", count);
    } else {
        while (*argv) {
            const char *name;
            if (strcmp(*argv, "-") == 0)
                name = "<stdin>";
            else
                name = *argv;

            if (strcmp(*argv, "-") == 0) {
                fp = stdin;
            } else {
                fp = fopen(*argv, "r");
                if (!fp) {
                    fprintf(stderr, "head: cannot open %s\n", *argv);
                    ret = 1;
                    argv++;
                    continue;
                }
            }

            if (many) {
                if (newline)
                    putchar('\n');
                printf("==> %s <==\n", name);
            }
            newline = 1;
            status = head_file(fp, name, count);
            if (fp != stdin)
                fclose(fp);
            if (status == 2)
                return 1;
            if (status == 1)
                ret = 1;
            argv++;
        }
    }

    fflush(stdout);
    fflush(stderr);
    return ret;
}
