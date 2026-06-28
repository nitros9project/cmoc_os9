/*
 * Adapted from suckless sbase uuencode.
 *
 * Differences from upstream: no util.h/ARGBEGIN, manual option parsing,
 * fprintf(stderr,...) instead of eprintf, fread/getc instead of getline,
 * and 16-bit int.  The base64 (-m) mode is dropped; only the classic
 * historical uuencode format is produced.  The target has no <sys/stat.h>
 * (no struct stat / fstat), so the begin-line mode is fixed at 0644
 * instead of being taken from the input file's permissions.
 */

#include <stdio.h>
#include <string.h>

#define FIXED_MODE 0644

static void
usage(void)
{
    fprintf(stderr, "usage: uuencode [file] name\n");
}

/* emit one 6-bit value using the historical uuencode mapping */
static void
putuu(int v)
{
    int ch;

    v &= 0x3f;
    ch = v ? v + 0x20 : 0x60;
    putchar(ch);
}

static int
uuencode(FILE *fp, const char *name, const char *s)
{
    unsigned char buf[45];
    int n, i;

    printf("begin %o %s\n", FIXED_MODE, name);

    while ((n = (int)fread(buf, 1, sizeof(buf), fp)) > 0) {
        putuu(n);
        for (i = 0; i < n; i += 3) {
            unsigned char b0, b1, b2;

            b0 = buf[i];
            b1 = (i + 1 < n) ? buf[i + 1] : 0;
            b2 = (i + 2 < n) ? buf[i + 2] : 0;

            putuu(b0 >> 2);
            putuu((b0 << 4) | (b1 >> 4));
            putuu((b1 << 2) | (b2 >> 6));
            putuu(b2);
        }
        putchar('\n');
    }

    if (ferror(fp)) {
        fprintf(stderr, "uuencode: read error on %s\n", s);
        return 1;
    }

    /* zero-length line (single backtick) followed by end */
    printf("`\nend\n");
    return 0;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    const char *name, *s;
    int ret;

    argv++;
    argc--;

    if (argc < 1 || argc > 2) {
        usage();
        return 1;
    }

    if (argc == 1 || strcmp(argv[0], "-") == 0) {
        name = argv[argc - 1];
        ret = uuencode(stdin, name, "<stdin>");
    } else {
        s = argv[0];
        name = argv[1];
        fp = fopen(s, "r");
        if (!fp) {
            fprintf(stderr, "uuencode: cannot open %s\n", s);
            return 1;
        }
        ret = uuencode(fp, name, s);
        fclose(fp);
    }

    fflush(stdout);
    if (ferror(stdout))
        ret = 1;
    return ret;
}
