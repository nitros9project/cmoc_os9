/* Adapted from suckless sbase od. Reduced: single output format, common flags only. */

/*
 * Differences from upstream: no util.h/queue.h/arg.h, manual option parsing,
 * a single active output format (no stacked -t types), 16-bit int with the
 * file offset carried as long, fread() instead of read()/getline, and only
 * fixed-width printf conversions (the CMOC printf has no "%*" support).
 *
 * The default format here is the 2-byte octal word form (identical to -o),
 * which is a deliberate simplification: upstream's no-flag default actually
 * groups bytes into 4-byte octal words.
 */

#include <ctype.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static char ofmt = 'o';     /* output format: o,b,c,x,d */
static char afmt = 'o';     /* address format: o,d,x,n */

static void
usage(void)
{
    fprintf(stderr, "usage: od [-bcdovx] [-A o|d|x|n] [file ...]\n");
    exit(1);
}

static void
printaddr(long addr)
{
    switch (afmt) {
    case 'd':
        printf("%07ld", addr);
        break;
    case 'x':
        printf("%07lx", addr);
        break;
    case 'n':
        putchar(' ');
        break;
    default:
        printf("%07lo", addr);
        break;
    }
}

static void
printchar(unsigned char c)
{
    const char *esc[] = {
        "\\0", "\\a", "\\b", "\\t", "\\n", "\\v", "\\f", "\\r"
    };

    switch (c) {
    case '\0': printf(" %3s", esc[0]); return;
    case '\a': printf(" %3s", esc[1]); return;
    case '\b': printf(" %3s", esc[2]); return;
    case '\t': printf(" %3s", esc[3]); return;
    case '\n': printf(" %3s", esc[4]); return;
    case '\v': printf(" %3s", esc[5]); return;
    case '\f': printf(" %3s", esc[6]); return;
    case '\r': printf(" %3s", esc[7]); return;
    }
    if (!isprint(c))
        printf(" %3o", c);
    else
        printf(" %3c", c);
}

static void
printline(const unsigned char *line, int len, long addr)
{
    unsigned long w;
    int i;

    printaddr(addr);
    for (i = 0; i < len; ) {
        if (ofmt == 'b') {
            printf(" %3o", line[i]);
            i++;
        } else if (ofmt == 'c') {
            printchar(line[i]);
            i++;
        } else {
            w = line[i];
            if (i + 1 < len)
                w |= (unsigned long)line[i + 1] << 8;
            switch (ofmt) {
            case 'x':
                printf(" %7lx", w);
                break;
            case 'd':
                printf(" %7lu", w);
                break;
            default:        /* 'o' 2-byte octal word */
                printf(" %7lo", w);
                break;
            }
            i += 2;
        }
    }
    putchar('\n');
}

/* persists across files so concatenated input is treated as continuous */
static unsigned char line[16];
static int lineoff;
static long addr;

static int
od(FILE *fp, const char *name, int last)
{
    unsigned char buf[512];
    size_t n, i;

    while ((n = fread(buf, 1, sizeof(buf), fp)) > 0) {
        for (i = 0; i < n; i++) {
            line[lineoff++] = buf[i];
            addr++;
            if (lineoff == 16) {
                printline(line, 16, addr - 16);
                lineoff = 0;
            }
        }
    }
    if (ferror(fp)) {
        fprintf(stderr, "od: read error on %s\n", name);
        return 1;
    }
    if (last) {
        if (lineoff)
            printline(line, lineoff, addr - lineoff);
        printline(line, 0, addr);
    }
    return 0;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    char *a, *p, *s;
    int i;
    int ret = 0;

    for (i = 1; i < argc; i++) {
        a = argv[i];
        if (a[0] != '-' || a[1] == '\0')
            break;
        if (a[1] == '-' && a[2] == '\0') {
            i++;
            break;
        }
        p = a + 1;
        while (*p) {
            if (*p == 'A') {
                if (p[1] != '\0')
                    s = p + 1;
                else if (++i < argc)
                    s = argv[i];
                else
                    usage();
                if (s[0] == '\0' || s[1] != '\0' || !strchr("odxn", s[0]))
                    usage();
                afmt = s[0];
                break;          /* rest of this token consumed as the arg */
            }
            switch (*p) {
            case 'b':
            case 'c':
            case 'o':
            case 'x':
            case 'd':
                ofmt = *p;
                break;
            case 'v':
                break;          /* accepted and ignored */
            default:
                usage();
            }
            p++;
        }
    }

    if (i >= argc) {
        ret |= od(stdin, "<stdin>", 1);
    } else {
        for (; i < argc; i++) {
            int last = (i == argc - 1);
            if (strcmp(argv[i], "-") == 0) {
                ret |= od(stdin, "<stdin>", last);
            } else if ((fp = fopen(argv[i], "r")) == NULL) {
                fprintf(stderr, "od: cannot open %s\n", argv[i]);
                ret = 1;
                continue;
            } else {
                ret |= od(fp, argv[i], last);
                fclose(fp);
            }
        }
    }

    fflush(stdout);
    return (ret | (ferror(stdout) ? 1 : 0));
}
