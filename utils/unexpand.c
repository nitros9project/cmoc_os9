/* Adapted from suckless sbase unexpand.
 *
 * Reduced from upstream: only a single numeric tabstop is supported (the
 * comma/space-separated tablist form is omitted), and the converter works
 * on raw bytes -- one byte counts as one column, with no UTF-8/Rune
 * handling.  As in POSIX/sbase, -t implies -a.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

static int  aflag   = 0;
static long tabsize = 8;

static void
usage(void)
{
    fprintf(stderr, "usage: unexpand [-a] [-t tabstop] [file ...]\n");
    exit(1);
}

static long
getnum(const char *s, long lo, long hi)
{
    char *end;
    long  v;

    v = strtol(s, &end, 10);
    if (*s == '\0' || *end != '\0' || v < lo || v > hi)
        usage();
    return v;
}

/* Emit the run of blanks spanning output columns [last, col), packing as
 * many tabs as fit and padding the remainder with spaces. */
static void
unexpandspan(long last, long col)
{
    long off;

    off = last % tabsize;
    if ((col - last) + off >= tabsize && last < col)
        last -= off;
    for (; last + tabsize <= col; last += tabsize)
        putchar('\t');
    for (; last < col; last++)
        putchar(' ');
}

static void
unexpand(FILE *fp)
{
    long last = 0, col = 0;
    int  bol = 1;
    int  c;

    while ((c = getc(fp)) != EOF) {
        switch (c) {
        case ' ':
            if (!bol && !aflag)
                last++;
            col++;
            break;
        case '\t':
            if (!bol && !aflag)
                last += tabsize - col % tabsize;
            col += tabsize - col % tabsize;
            break;
        case '\b':
            if (bol || aflag)
                unexpandspan(last, col);
            if (col > 0)
                col--;
            last = col;
            bol = 0;
            break;
        case '\n':
            if (bol || aflag)
                unexpandspan(last, col);
            last = col = 0;
            bol = 1;
            break;
        default:
            if (bol || aflag)
                unexpandspan(last, col);
            last = ++col;
            bol = 0;
            break;
        }
        /* Blanks inside a convertible region are accumulated and flushed
         * by unexpandspan(); everything else is written verbatim. */
        if ((c != ' ' && c != '\t') || (!aflag && !bol))
            putchar(c);
    }
    if (last < col && (bol || aflag))
        unexpandspan(last, col);
}

int
main(int argc, char **argv)
{
    FILE *fp;
    int   ret = 0;
    int   i;

    for (i = 1; i < argc && argv[i][0] == '-' && argv[i][1] != '\0'; i++) {
        char *opt = argv[i];

        if (strcmp(opt, "-a") == 0) {
            aflag = 1;
        } else if (strcmp(opt, "-t") == 0) {
            if (++i >= argc)
                usage();
            tabsize = getnum(argv[i], 1, 32767);
            aflag = 1; /* -t implies -a, matching POSIX/sbase */
        } else {
            usage();
        }
    }

    argc -= i;
    argv += i;

    if (argc == 0) {
        unexpand(stdin);
    } else {
        for (; *argv; argv++) {
            if (strcmp(*argv, "-") == 0) {
                unexpand(stdin);
            } else if (!(fp = fopen(*argv, "r"))) {
                fprintf(stderr, "unexpand: cannot open %s\n", *argv);
                ret = 1;
                continue;
            } else {
                unexpand(fp);
                fclose(fp);
            }
        }
    }

    fflush(stdout);
    return (ret | (ferror(stdout) ? 1 : 0));
}
