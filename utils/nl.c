/* Adapted from suckless sbase nl. */
/*
 * Numbers the lines of a single file (or stdin) and writes them to stdout.
 *
 * Differences from upstream sbase:
 *   - No util.h/text.h/utf.h/arg.h.  Option parsing is a manual argv loop
 *     (see cal.c), eprintf is replaced by fprintf(stderr,...), and
 *     estrtonum by a small strtol helper.
 *   - The regex "-b p<regex>" / "-f p" / "-h p" pattern line type is dropped
 *     entirely (no regex on this platform).
 *   - The multi-section header/body/footer logic driven by the "\:\:\:"
 *     logical-page delimiters is omitted; only the body is numbered.
 *   - 'int' is 16-bit here, so line numbers are 'long'.
 *   - The CMOC printf has no "%*ld" variable-width conversion, so the number
 *     is formatted with sprintf into a temp buffer and the field width is
 *     padded by hand (spaces, or zeros for the 'rz' format).
 *
 * Line endings: input lines may end in CR (OS-9 native), LF (data piped
 * from other programs), or CRLF; all are accepted.  Output lines end in LF.
 *
 * Line-length cap: lines are read into a fixed 512-byte buffer, so a line
 * longer than 511 bytes is truncated.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>

/* number formats */
enum { FMT_RN, FMT_LN, FMT_RZ }; /* right, left, right zero-padded */

static long startnum = 1;        /* -v */
static long incr = 1;            /* -i */
static int  width = 6;           /* -w */
static int  nfmt = FMT_RN;       /* -n */
static char btype = 't';         /* -b: 'a' all, 't' non-empty, 'n' none */
/*
 * sbase/POSIX nl uses a TAB as the default separator, but the OS-9
 * windowing terminal interprets 0x09 as "cursor up" (not a horizontal
 * tab), which scrambles the display.  Default to spaces so terminal
 * output is readable; use -s to choose any separator (e.g. a real tab
 * when piping to a file).
 */
static char default_sep[] = "  ";
static char *sep = default_sep;  /* -s */

static void
usage(void)
{
    fprintf(stderr, "usage: nl [-b type] [-i num] [-n format] "
        "[-s sep] [-v num] [-w num] [file]\n");
    exit(1);
}

static long
getnum(const char *s, long lo, long hi)
{
    char *end;
    long v;

    v = strtol(s, &end, 10);
    if (*s == '\0' || *end != '\0' || v < lo || v > hi)
        usage();
    return v;
}

static void
printnumber(long n)
{
    char buf[24];
    int len, pad, i;

    sprintf(buf, "%ld", n);
    len = (int)strlen(buf);
    pad = width - len;
    if (pad < 0)
        pad = 0;

    if (nfmt == FMT_LN) {        /* left justified, trailing spaces */
        fputs(buf, stdout);
        for (i = 0; i < pad; i++)
            putchar(' ');
    } else if (nfmt == FMT_RZ) { /* right justified, zero padded */
        if (buf[0] == '-') {
            putchar('-');
            for (i = 0; i < pad; i++)
                putchar('0');
            fputs(buf + 1, stdout);
        } else {
            for (i = 0; i < pad; i++)
                putchar('0');
            fputs(buf, stdout);
        }
    } else {                     /* FMT_RN: right justified, leading spaces */
        for (i = 0; i < pad; i++)
            putchar(' ');
        fputs(buf, stdout);
    }
}

/*
 * Read one line, treating CR, LF, or CRLF as the terminator and stripping
 * it.  OS-9 text files use CR (0x0D); data piped from other programs uses
 * LF (0x0A).  fgets() stops only on CR, so it would swallow piped LF input
 * as one line -- hence this byte reader.  Returns the line length, or -1 at
 * end of input with nothing read.  Over-long lines are truncated.
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

static int
nl(const char *fname, FILE *fp)
{
    char line[512];
    long number = startnum;
    int len;

    while ((len = readline(fp, line, sizeof(line))) >= 0) {
        int donumber = 0;

        switch (btype) {
        case 'a':
            donumber = 1;
            break;
        case 't':
            if (len > 0)
                donumber = 1;
            break;
        case 'n':
        default:
            donumber = 0;
            break;
        }

        if (donumber) {
            printnumber(number);
            fputs(sep, stdout);
            number += incr;
        }
        fputs(line, stdout);
        putchar('\n');
    }

    if (ferror(fp)) {
        fprintf(stderr, "nl: read error on %s\n", fname);
        return 1;
    }
    return 0;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    const char *fname;
    int i;
    int ret = 0;

    for (i = 1; i < argc && argv[i][0] == '-' && argv[i][1] != '\0'; i++) {
        char *opt = argv[i];

        if (strcmp(opt, "-b") == 0) {
            if (++i >= argc)
                usage();
            if (!argv[i][0] || argv[i][1] || !strchr("atn", argv[i][0]))
                usage();
            btype = argv[i][0];
        } else if (strcmp(opt, "-i") == 0) {
            if (++i >= argc)
                usage();
            incr = getnum(argv[i], -2147483647L, 2147483647L);
        } else if (strcmp(opt, "-v") == 0) {
            if (++i >= argc)
                usage();
            startnum = getnum(argv[i], -2147483647L, 2147483647L);
        } else if (strcmp(opt, "-w") == 0) {
            if (++i >= argc)
                usage();
            width = (int)getnum(argv[i], 1, 255);
        } else if (strcmp(opt, "-s") == 0) {
            if (++i >= argc)
                usage();
            sep = argv[i];
        } else if (strcmp(opt, "-n") == 0) {
            if (++i >= argc)
                usage();
            if (strcmp(argv[i], "ln") == 0)
                nfmt = FMT_LN;
            else if (strcmp(argv[i], "rn") == 0)
                nfmt = FMT_RN;
            else if (strcmp(argv[i], "rz") == 0)
                nfmt = FMT_RZ;
            else
                usage();
        } else {
            usage();
        }
    }

    argc -= i;
    argv += i;

    if (argc > 1)
        usage();

    if (argc == 0 || strcmp(argv[0], "-") == 0) {
        ret = nl("<stdin>", stdin);
    } else {
        fname = argv[0];
        if (!(fp = fopen(fname, "r"))) {
            fprintf(stderr, "nl: cannot open %s\n", fname);
            return 1;
        }
        ret = nl(fname, fp);
        fclose(fp);
    }

    fflush(stdout);
    if (ferror(stdout))
        ret = 1;
    return ret;
}
