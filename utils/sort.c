/* Adapted from suckless sbase sort.
 *
 * In-memory line sort for the CMOC OS-9 environment.
 *
 * Supported flags:
 *   -r  reverse the result of comparisons
 *   -n  numeric: compare the leading integer value of each line
 *   -u  unique: suppress lines that compare equal to the previous one
 *   -f  fold case in comparisons
 *   -b  ignore leading blanks when comparing
 *   -c  check whether the input is already sorted (no output)
 *
 * Omitted from upstream: the key/field machinery (-k, -t), the
 * merge/output-file options (-m, -o), and the -C/-d/-i modifiers.
 *
 * Differences from upstream: no util.h/text.h/arg.h (manual option
 * parsing, fprintf for diagnostics, strtol helper, malloc/realloc with
 * NULL checks, a private line reader and a private strdup); comparisons
 * operate on bytes for stable C-locale ordering; -n uses strtol (32-bit
 * long) so only the integer part is significant (no floating point).
 *
 * Line endings: input lines may end in CR (OS-9 native), LF (data piped
 * from other programs), or CRLF; all are accepted.  Output lines end in LF.
 *
 * Limits:
 *   - Lines are read into a fixed 512-byte buffer, so the maximum line
 *     length is 511 bytes; a longer input line is truncated.
 *   - The line array grows by doubling (starting at 256 entries); the
 *     only hard limit is available memory.  If an allocation fails the
 *     program prints a message to stderr and exits with status 2.
 */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define LINEBUF 512

static int rflag, nflag, uflag, fflag, bflag, cflag;

static char **lines;
static size_t nlines, cap;

static void
usage(void)
{
    fprintf(stderr, "usage: sort [-bcfnru] [file ...]\n");
    exit(1);
}

/*
 * Read one line, treating CR, LF, or CRLF as the terminator and stripping
 * it.  OS-9 text files use CR (0x0D); data piped from other programs uses
 * LF (0x0A).  fgets() stops only on CR, so it would swallow piped LF input
 * as a single line -- hence this byte reader.  Returns the line length, or
 * -1 at end of input with nothing read.  Over-long lines are truncated to
 * the buffer.
 */
static int
readline(FILE *fp, char *buf, int size)
{
    int c, n = 0;

    c = getc(fp);
    if (c == EOF)
        return -1;
    while (c != EOF && c != '\n' && c != '\r') {
        if (n < size - 1)
            buf[n++] = (char)c;
        c = getc(fp);
    }
    if (c == '\r') {                /* swallow the LF of a CRLF pair */
        c = getc(fp);
        if (c != '\n' && c != EOF)
            ungetc(c, fp);
    }
    buf[n] = '\0';
    return n;
}

static void
addline(const char *s)
{
    size_t n = (size_t)strlen(s);
    char *d;

    if (nlines == cap) {
        cap = cap ? cap * 2 : 256;
        lines = (char **)realloc(lines, cap * sizeof(*lines));
        if (!lines) {
            fprintf(stderr, "sort: out of memory\n");
            exit(2);
        }
    }
    if (!(d = (char *)malloc(n + 1))) {
        fprintf(stderr, "sort: out of memory\n");
        exit(2);
    }
    memcpy(d, s, n + 1);
    lines[nlines++] = d;
}

static int
readfile(FILE *fp, const char *name)
{
    char buf[LINEBUF];

    while (readline(fp, buf, sizeof(buf)) >= 0)
        addline(buf);
    if (ferror(fp)) {
        fprintf(stderr, "sort: read error on %s\n", name);
        return 1;
    }
    return 0;
}

static const char *
skipblank(const char *s)
{
    while (*s == ' ' || *s == '\t')
        s++;
    return s;
}

/* Byte comparison in the C locale (unsigned chars). */
static int
bytecmp(const char *a, const char *b)
{
    const unsigned char *x = (const unsigned char *)a;
    const unsigned char *y = (const unsigned char *)b;

    while (*x && *x == *y) {
        x++;
        y++;
    }
    return (int)*x - (int)*y;
}

/* Case-folded byte comparison. */
static int
foldcmp(const char *a, const char *b)
{
    const unsigned char *x = (const unsigned char *)a;
    const unsigned char *y = (const unsigned char *)b;
    int ca, cb;

    for (;;) {
        ca = tolower((int)*x);
        cb = tolower((int)*y);
        if (ca != cb)
            return ca - cb;
        if (*x == '\0')
            return 0;
        x++;
        y++;
    }
}

/* Compare two lines by the primary key only (the active -n/-f/-b
 * options), ignoring -r.  This is also the key used for -u and -c. */
static int
keycmp(const char *a, const char *b)
{
    const char *ka = a, *kb = b;
    char *end;
    long la, lb;

    if (bflag) {
        ka = skipblank(a);
        kb = skipblank(b);
    }
    if (nflag) {
        la = strtol(ka, &end, 10);
        lb = strtol(kb, &end, 10);
        return (la < lb) ? -1 : (la > lb);
    }
    if (fflag)
        return foldcmp(ka, kb);
    return bytecmp(ka, kb);
}

/* Like sbase, when the primary key compares equal fall back to a
 * full-line byte comparison (the "last-resort" tiebreaker). */
static int
fullcmp(const char *a, const char *b)
{
    int r = keycmp(a, b);

    if (r == 0)
        r = bytecmp(a, b);
    return r;
}

/* qsort comparator: applies -r.  -u suppresses the last-resort
 * tiebreaker so that lines with equal keys are treated as equal. */
static int
linecmp(const void *pa, const void *pb)
{
    const char *a = *(char *const *)pa;
    const char *b = *(char *const *)pb;
    int r = uflag ? keycmp(a, b) : fullcmp(a, b);

    return rflag ? -r : r;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    size_t i;
    int ret = 0;
    char *p;

    argv++;
    argc--;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        if (strcmp(argv[0], "--") == 0) {
            argv++;
            argc--;
            break;
        }
        for (p = argv[0] + 1; *p; p++) {
            switch (*p) {
            case 'r':
                rflag = 1;
                break;
            case 'n':
                nflag = 1;
                break;
            case 'u':
                uflag = 1;
                break;
            case 'f':
                fflag = 1;
                break;
            case 'b':
                bflag = 1;
                break;
            case 'c':
                cflag = 1;
                break;
            default:
                usage();
            }
        }
        argv++;
        argc--;
    }

    if (argc == 0) {
        ret |= readfile(stdin, "<stdin>");
    } else {
        for (i = 0; (int)i < argc; i++) {
            if (strcmp(argv[i], "-") == 0) {
                ret |= readfile(stdin, "<stdin>");
            } else if (!(fp = fopen(argv[i], "r"))) {
                fprintf(stderr, "sort: cannot open %s\n", argv[i]);
                ret = 1;
            } else {
                ret |= readfile(fp, argv[i]);
                fclose(fp);
            }
        }
    }

    if (cflag) {
        for (i = 1; i < nlines; i++) {
            int c = keycmp(lines[i - 1], lines[i]);
            if (rflag)
                c = -c;
            if (c > 0 || (uflag && c == 0)) {
                fprintf(stderr, "sort: disorder: ");
                fputs(lines[i], stderr);
                fputs("\n", stderr);
                ret = 1;
                break;
            }
        }
    } else {
        qsort(lines, nlines, sizeof(*lines), linecmp);
        for (i = 0; i < nlines; i++) {
            if (uflag && i > 0 &&
                keycmp(lines[i - 1], lines[i]) == 0)
                continue;
            fputs(lines[i], stdout);
            putchar('\n');
        }
    }

    fflush(stdout);
    return (ret | (ferror(stdout) ? 1 : 0));
}
