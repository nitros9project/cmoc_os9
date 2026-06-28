/* Adapted from suckless sbase fold. */
/* Note: UTF-8/Rune handling dropped - columns are counted by bytes. */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>	/* exit() lives here in the CMOC OS-9 libc */

static int  bflag = 0;
static int  sflag = 0;
static long width = 80;

static char *linebuf = NULL;
static long  linecap = 0;

static void
usage(void)
{
    fprintf(stderr, "usage: fold [-bs] [-w num | -num] [FILE ...]\n");
    exit(1);
}

static int
is_blank(int c)
{
    return c == ' ' || c == '\t';
}

static long
parse_width(const char *s)
{
    char *end;
    long  v;

    if (*s == '\0')
        usage();
    v = strtol(s, &end, 10);
    if (*end != '\0' || v < 1) {
        fprintf(stderr, "fold: illegal width value\n");
        exit(1);
    }
    return v;
}

/*
 * Read one line (including a trailing '\n' if present) into linebuf,
 * growing it as needed so there is no fixed line-length limit.  Returns
 * the byte count, or -1 at end of input with nothing read.
 */
static long
readline(FILE *fp)
{
    long n = 0;
    int  c = EOF;

    while ((c = getc(fp)) != EOF) {
        if (n + 1 > linecap) {
            long  ncap;
            char *p;

            if (linecap)
                ncap = linecap * 2;
            else
                ncap = 256;
            p = (char *)realloc(linebuf, (size_t)ncap);

            if (!p) {
                fprintf(stderr, "fold: out of memory\n");
                exit(1);
            }
            linebuf = p;
            linecap = ncap;
        }
        linebuf[n++] = (char)c;
        if (c == '\n')
            break;
    }
    if (c == EOF && n == 0)
        return -1;
    return n;
}

static void
foldline(const char *data, long len)
{
    long i, col, last, spacesect, seg;
    int  c;

    for (i = 0, last = 0, col = 0, spacesect = 0; i < len; i++) {
        c = (unsigned char)data[i];
        if (col >= width && ((c != '\r' && c != '\b') || bflag)) {
            seg = ((sflag && spacesect) ? spacesect : i) - last;
            if (seg > 0)
                fwrite(data + last, 1, (size_t)seg, stdout);
            if (c != '\n')
                putchar('\n');
            if (sflag && spacesect)
                i = spacesect;
            last = i;
            col = 0;
            spacesect = 0;
            c = (unsigned char)data[i];     /* i may have moved back */
        }
        if (sflag && is_blank(c))
            spacesect = i + 1;
        if (!bflag && iscntrl(c)) {
            switch (c) {
            case '\b':
                if (col > 0)
                    col--;
                break;
            case '\r':
                col = 0;
                break;
            case '\t':
                col += (8 - (col % 8));
                if (col >= width)
                    i--;
                break;
            }
        } else {
            col += 1;       /* one column per byte (byte mode counts bytes too) */
        }
    }
    if (len - last > 0)
        fwrite(data + last, 1, (size_t)(len - last), stdout);
}

static int
fold(FILE *fp, const char *fname)
{
    long len;

    while ((len = readline(fp)) > 0)
        foldline(linebuf, len);
    if (ferror(fp)) {
        fprintf(stderr, "fold: read error on %s\n", fname);
        return 1;
    }
    return 0;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    int   i, j;
    int   ret = 0;

    for (i = 1; i < argc; i++) {
        char *a = argv[i];

        if (a[0] != '-' || a[1] == '\0')
            break;
        if (strcmp(a, "--") == 0) {
            i++;
            break;
        }
        if (isdigit((unsigned char)a[1])) {
            width = parse_width(a + 1);
            continue;
        }
        j = 1;
        while (a[j] != '\0') {
            int o = a[j];

            if (o == 'b') {
                bflag = 1;
                j++;
            } else if (o == 's') {
                sflag = 1;
                j++;
            } else if (o == 'w') {
                if (a[j + 1] != '\0') {
                    width = parse_width(a + j + 1);
                } else {
                    if (++i >= argc)
                        usage();
                    width = parse_width(argv[i]);
                }
                break;      /* 'w' consumes the rest of the token */
            } else {
                usage();
            }
        }
    }

    if (i >= argc) {
        ret |= fold(stdin, "<stdin>");
    } else {
        for (; i < argc; i++) {
            if (strcmp(argv[i], "-") == 0) {
                ret |= fold(stdin, "<stdin>");
            } else if (!(fp = fopen(argv[i], "r"))) {
                fprintf(stderr, "fold: cannot open %s\n", argv[i]);
                ret = 1;
                continue;
            } else {
                ret |= fold(fp, argv[i]);
                fclose(fp);
            }
        }
    }

    fflush(stdout);
    return (ret | (ferror(stdout) ? 1 : 0));
}
