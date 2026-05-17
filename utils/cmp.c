#include <stdio.h>
#include <string.h>

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-l | -s] file1 file2\n", progname);
}

int
main(int argc, char **argv)
{
    FILE *fp[2];
    const char *name[2];
    unsigned long line = 1;
    unsigned long byte = 0;
    int b[2];
    int lflag = 0;
    int sflag = 0;
    int same = 1;
    int prev_cr = 0;

    argv++;
    argc--;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        if (strcmp(argv[0], "-l") == 0) {
            lflag = 1;
        } else if (strcmp(argv[0], "-s") == 0) {
            sflag = 1;
        } else {
            usage("cmp");
            return 2;
        }
        argv++;
        argc--;
    }

    if (argc != 2 || (lflag && sflag)) {
        usage("cmp");
        return 2;
    }

    if (strcmp(argv[0], "-") == 0) {
        fp[0] = stdin;
        name[0] = "<stdin>";
    } else {
        fp[0] = fopen(argv[0], "r");
        if (!fp[0]) {
            if (!sflag)
                fprintf(stderr, "cmp: cannot open %s\n", argv[0]);
            return 2;
        }
        name[0] = argv[0];
    }

    if (strcmp(argv[1], "-") == 0) {
        fp[1] = stdin;
        name[1] = "<stdin>";
    } else {
        fp[1] = fopen(argv[1], "r");
        if (!fp[1]) {
            if (!sflag)
                fprintf(stderr, "cmp: cannot open %s\n", argv[1]);
            if (fp[0] != stdin)
                fclose(fp[0]);
            return 2;
        }
        name[1] = argv[1];
    }

    for (;;) {
        b[0] = getc(fp[0]);
        b[1] = getc(fp[1]);
        byte++;

        if (b[0] == b[1]) {
            if (b[0] == EOF)
                break;
            if (b[0] == '\r') {
                line++;
                prev_cr = 1;
            } else if (b[0] == '\n') {
                if (!prev_cr)
                    line++;
                prev_cr = 0;
            } else {
                prev_cr = 0;
            }
            continue;
        }

        if (b[0] == EOF || b[1] == EOF) {
            if (!sflag)
                fprintf(stderr, "cmp: EOF on %s\n", name[(b[0] != EOF)]);
            same = 0;
            break;
        }

        if (!lflag) {
            if (!sflag)
                printf("%s %s differ: byte %ld, line %ld\n",
                       name[0], name[1], (long) byte, (long) line);
            same = 0;
            break;
        }

        printf("%ld %d %d\n", (long) byte, b[0], b[1]);
        same = 0;
    }

    if (fp[0] != stdin)
        fclose(fp[0]);
    if (fp[1] != stdin && fp[1] != fp[0])
        fclose(fp[1]);

    if (_iob[0]._flag & _ERR) {
        fprintf(stderr, "cmp: read error on <stdin>\n");
        return 2;
    }

    fflush(stdout);
    fflush(stderr);

    return same ? 0 : 1;
}
