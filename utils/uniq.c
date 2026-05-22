/*
 * Adapted from suckless sbase uniq.
 */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINEBUF 256

static int cflag;
static int dflag;
static int uflag;
static int fskip;
static int sskip;

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-c] [-d | -u] [-f fields] [-s chars] [input [output]]\n",
            progname);
}

static char *
skip_key(char *line)
{
    char *p = line;
    int f = fskip;
    int s = sskip;

    while (f-- > 0) {
        while (*p && isspace((unsigned char) *p))
            p++;
        while (*p && !isspace((unsigned char) *p))
            p++;
    }
    while (s-- > 0 && *p && *p != '\n' && *p != '\r')
        p++;

    return p;
}

static int
same_line(char *a, char *b)
{
    return strcmp(skip_key(a), skip_key(b)) == 0;
}

static int
emit_line(FILE *out, char *line, unsigned long count)
{
    if ((count == 1 && dflag) || (count != 1 && uflag))
        return 0;
    if (cflag)
        fprintf(out, "%7lu ", count);
    if (fputs(line, out) == EOF)
        return 1;
    return 0;
}

int
main(int argc, char **argv)
{
    FILE *in = stdin;
    FILE *out = stdout;
    char *end;
    char prev[LINEBUF];
    char line[LINEBUF];
    unsigned long count = 0;
    int have_prev = 0;
    int ret = 0;

    argv++;
    argc--;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        if (strcmp(argv[0], "-c") == 0) {
            cflag = 1;
        } else if (strcmp(argv[0], "-d") == 0) {
            dflag = 1;
        } else if (strcmp(argv[0], "-u") == 0) {
            uflag = 1;
        } else if (strcmp(argv[0], "-f") == 0) {
            if (argc < 2) {
                usage("uniq");
                return 1;
            }
            fskip = (int) strtoul(argv[1], &end, 10);
            if (*argv[1] == '\0' || *end != '\0') {
                usage("uniq");
                return 1;
            }
            argv++;
            argc--;
        } else if (strcmp(argv[0], "-s") == 0) {
            if (argc < 2) {
                usage("uniq");
                return 1;
            }
            sskip = (int) strtoul(argv[1], &end, 10);
            if (*argv[1] == '\0' || *end != '\0') {
                usage("uniq");
                return 1;
            }
            argv++;
            argc--;
        } else {
            usage("uniq");
            return 1;
        }
        argv++;
        argc--;
    }

    if (dflag && uflag) {
        usage("uniq");
        return 1;
    }
    if (argc > 2) {
        usage("uniq");
        return 1;
    }

    if (argc > 0 && strcmp(argv[0], "-") != 0) {
        in = fopen(argv[0], "r");
        if (!in) {
            fprintf(stderr, "uniq: cannot open %s\n", argv[0]);
            return 1;
        }
    }
    if (argc > 1 && strcmp(argv[1], "-") != 0) {
        out = fopen(argv[1], "w");
        if (!out) {
            fprintf(stderr, "uniq: cannot open %s\n", argv[1]);
            if (in != stdin)
                fclose(in);
            return 1;
        }
    }

    while (fgets(line, sizeof(line), in)) {
        if (!have_prev) {
            strcpy(prev, line);
            count = 1;
            have_prev = 1;
        } else if (same_line(prev, line)) {
            count++;
        } else {
            ret |= emit_line(out, prev, count);
            strcpy(prev, line);
            count = 1;
        }
    }

    if (have_prev)
        ret |= emit_line(out, prev, count);
    if (ferror(in)) {
        fprintf(stderr, "uniq: read error\n");
        ret = 1;
    }

    fflush(out);
    if (in != stdin)
        fclose(in);
    if (out != stdout)
        fclose(out);

    return ret;
}
