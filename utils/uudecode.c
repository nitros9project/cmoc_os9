/*
 * Adapted from suckless sbase uudecode.
 *
 * Differences from upstream: no util.h/arg.h (manual option parsing and
 * fprintf(stderr,...) for diagnostics), no getline() (lines are read with
 * fgets() into a fixed buffer), no snprintf, and only the classic "begin"
 * (historical uuencode) format is handled -- the base64 "begin-base64"
 * decoder is dropped.  16-bit int, so a 'long' is used for the running
 * byte count.  The header's octal mode is parsed past but NOT applied:
 * OS-9 file attributes do not map onto Unix rwx triples, and applying the
 * Unix bits via chmod() corrupts the file's permissions (it becomes
 * inaccessible, OS-9 error 214).  The decoded file keeps default perms.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* a full uuencoded data line encodes 45 bytes -> 1 + 60 chars + newline */
#define UU_LINESZ 128

/* single character decode: historical 6-bit value of an encoded char */
#define UU_DEC(c)  ((((int)(c)) - ' ') & 077)

/*
 * Read one line, accepting CR, LF, or CRLF as the terminator.  uuencoded
 * text on OS-9 may carry any convention: files written via shell redirect
 * keep LF (0x0A), while os9-native text files use CR (0x0D).  fgets() only
 * splits on the host's line terminator, so we read bytes ourselves.  The
 * result is NUL-terminated with the terminator removed; returns the length,
 * or -1 at end of input with nothing read.
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
usage(void)
{
    fprintf(stderr, "usage: uudecode [-m] [-o output] [file]\n");
    exit(1);
}

/*
 * Decode the body of a uuencoded stream (positioned just after the
 * "begin" header) writing the raw bytes to outfp.  Returns 0 on success,
 * nonzero on error.
 */
static int
decode_body(FILE *fp, FILE *outfp)
{
    char line[UU_LINESZ];
    unsigned char out[64];
    char *p;
    int i, no;
    long total = 0;

    while (readline(fp, line, sizeof(line)) >= 0) {
        p = line;

        /* a stray empty line ends the data, as does "end" */
        if (line[0] == '\0')
            break;
        if (!strcmp(line, "end"))
            return 0;

        /* first character holds the byte count for this line */
        i = UU_DEC(*p);
        if (i <= 0)
            break;

        no = 0;
        for (++p; i > 0; p += 4, i -= 3) {
            if (i >= 3) {
                out[no++] = (unsigned char)(UU_DEC(p[0]) << 2 | UU_DEC(p[1]) >> 4);
                out[no++] = (unsigned char)(UU_DEC(p[1]) << 4 | UU_DEC(p[2]) >> 2);
                out[no++] = (unsigned char)(UU_DEC(p[2]) << 6 | UU_DEC(p[3]));
            } else {
                if (i >= 1)
                    out[no++] = (unsigned char)(UU_DEC(p[0]) << 2 |
                                                UU_DEC(p[1]) >> 4);
                if (i >= 2)
                    out[no++] = (unsigned char)(UU_DEC(p[1]) << 4 |
                                                UU_DEC(p[2]) >> 2);
            }
        }

        if (no > 0 && fwrite(out, 1, (size_t)no, outfp) != (size_t)no) {
            fprintf(stderr, "uudecode: write error\n");
            return 1;
        }
        total += no;
    }

    if (ferror(fp)) {
        fprintf(stderr, "uudecode: read error\n");
        return 1;
    }

    (void)total;
    return 0;
}

int
main(int argc, char **argv)
{
    FILE *fp, *outfp;
    char line[UU_LINESZ];
    char *ofname = NULL;
    const char *ifname;
    char *fname, *p, *end;
    int found = 0;
    int ret = 0;
    int i;

    /* manual option parsing: -m (accepted, unused), -o output */
    for (i = 1; i < argc && argv[i][0] == '-' && argv[i][1] != '\0'; i++) {
        if (!strcmp(argv[i], "-m")) {
            /* accepted for compatibility, no effect on classic decode */
        } else if (!strcmp(argv[i], "-o")) {
            if (++i >= argc)
                usage();
            ofname = argv[i];
        } else if (!strcmp(argv[i], "--")) {
            i++;
            break;
        } else {
            usage();
        }
    }
    argc -= i;
    argv += i;

    if (argc > 1)
        usage();

    if (argc == 0 || !strcmp(argv[0], "-")) {
        fp = stdin;
        ifname = "<stdin>";
    } else {
        if (!(fp = fopen(argv[0], "r"))) {
            fprintf(stderr, "uudecode: cannot open %s\n", argv[0]);
            return 1;
        }
        ifname = argv[0];
    }

    /* skip lines until the "begin MODE NAME" header */
    fname = NULL;
    while (readline(fp, line, sizeof(line)) >= 0) {
        if (strncmp(line, "begin ", 6))
            continue;

        p = line + 6;
        while (*p == ' ')
            p++;
        /* parse past the octal mode field; the mode is not applied */
        (void)strtol(p, &end, 8);
        if (end != p)
            p = end;
        while (*p == ' ')
            p++;
        if (*p != '\0')
            fname = p;
        found = 1;
        break;
    }

    if (!found) {
        fprintf(stderr, "uudecode: %s: no \"begin\" header found\n", ifname);
        if (fp != stdin)
            fclose(fp);
        return 1;
    }

    /* choose output destination */
    if (ofname)
        fname = ofname;
    if (!fname) {
        fprintf(stderr, "uudecode: no output file in header\n");
        if (fp != stdin)
            fclose(fp);
        return 1;
    }

    if (!strcmp(fname, "/dev/stdout") || !strcmp(fname, "-")) {
        outfp = stdout;
    } else if (!(outfp = fopen(fname, "w"))) {
        fprintf(stderr, "uudecode: cannot open %s for writing\n", fname);
        if (fp != stdin)
            fclose(fp);
        return 1;
    }

    ret = decode_body(fp, outfp);

    if (fflush(outfp) != 0) {
        fprintf(stderr, "uudecode: write error\n");
        ret = 1;
    }

    if (outfp != stdout) {
        if (fclose(outfp) != 0) {
            fprintf(stderr, "uudecode: close error on %s\n", fname);
            ret = 1;
        }
    }

    if (fp != stdin)
        fclose(fp);

    return ret ? 1 : 0;
}
