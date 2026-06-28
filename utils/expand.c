/* Adapted from suckless sbase expand. */

/*
 * Differences from upstream: no util.h/utf.h/arg.h, manual option parsing,
 * strtol-based number parsing instead of estrtonum, and byte-oriented
 * streaming with getc() (each byte counts as one column) instead of the
 * Rune/UTF-8 handling, since CMOC OS-9 is single-byte.  The -t tablist
 * (single number or ascending comma/space-separated list) and -i options
 * are both supported.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

static int  iflag      = 0;
static int *tablist    = NULL;
static int  tablistlen = 0;

static void
usage(void)
{
    fprintf(stderr, "usage: expand [-i] [-t tablist] [file ...]\n");
    exit(1);
}

static void
parselist(const char *s)
{
    const char *p = s;
    char       *end;
    long        v;
    int        *tmp;

    while (*p) {
        while (*p == ' ' || *p == ',')
            p++;
        if (*p == '\0')
            break;
        v = strtol(p, &end, 10);
        if (end == p || v < 1 || v > 32767) {
            fprintf(stderr, "expand: invalid tablist\n");
            exit(1);
        }
        if (tablistlen > 0 && tablist[tablistlen - 1] >= (int)v) {
            fprintf(stderr, "expand: tablist must be ascending\n");
            exit(1);
        }
        /* +1 extra slot for the overflow case used by the matcher */
        tmp = (int *)realloc(tablist, (tablistlen + 2) * sizeof(*tablist));
        if (!tmp) {
            fprintf(stderr, "expand: out of memory\n");
            exit(1);
        }
        tablist = tmp;
        tablist[tablistlen++] = (int)v;
        p = end;
    }

    if (tablistlen == 0) {
        fprintf(stderr, "expand: empty tablist\n");
        exit(1);
    }

    /* tab length = 1 for the overflowing case later in the matcher */
    tablist[tablistlen] = 1;
}

static void
expand(FILE *fp)
{
    int c;
    int bol = 1, col = 0, i = 0;

    while ((c = getc(fp)) != EOF) {
        switch (c) {
        case '\t':
            if (tablistlen == 1)
                i = 0;
            else {
                for (i = 0; i < tablistlen; i++)
                    if (col < tablist[i])
                        break;
            }
            if (bol || !iflag) {
                do {
                    col++;
                    putchar(' ');
                } while (col % tablist[i]);
            } else {
                putchar('\t');
                col = tablist[i];
            }
            break;
        case '\b':
            bol = 0;
            if (col)
                col--;
            putchar('\b');
            break;
        case '\n':
            bol = 1;
            col = 0;
            putchar('\n');
            break;
        default:
            col++;
            if (c != ' ')
                bol = 0;
            putchar(c);
            break;
        }
    }
}

int
main(int argc, char **argv)
{
    FILE *fp;
    int   ret = 0;
    const char *tl = "8";
    int   i;

    for (i = 1; i < argc && argv[i][0] == '-' && argv[i][1] != '\0'; i++) {
        char *opt = argv[i];

        if (strcmp(opt, "-i") == 0) {
            iflag = 1;
        } else if (strcmp(opt, "-t") == 0) {
            if (++i >= argc)
                usage();
            tl = argv[i];
            if (!*tl) {
                fprintf(stderr, "expand: tablist cannot be empty\n");
                exit(1);
            }
        } else if (strncmp(opt, "-t", 2) == 0) {
            tl = opt + 2;
        } else {
            usage();
        }
    }

    argc -= i;
    argv += i;

    parselist(tl);

    if (argc == 0) {
        expand(stdin);
    } else {
        for (; *argv; argv++) {
            if (strcmp(*argv, "-") == 0) {
                expand(stdin);
            } else if (!(fp = fopen(*argv, "r"))) {
                fprintf(stderr, "expand: cannot open %s\n", *argv);
                ret = 1;
                continue;
            } else {
                expand(fp);
                fclose(fp);
            }
        }
    }

    fflush(stdout);
    return (ret | (ferror(stdout) ? 1 : 0));
}
