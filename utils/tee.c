/*
 * Adapted from suckless sbase tee.
 */

#include <stdio.h>
#include <string.h>

#define MAXFILES 8

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-ai] [file ...]\n", progname);
}

static int
write_char(FILE *fp, const char *name, int ch)
{
    if (putc(ch, fp) == EOF) {
        fprintf(stderr, "tee: write error on %s\n", name);
        return 1;
    }
    return 0;
}

int
main(int argc, char **argv)
{
    FILE *files[MAXFILES];
    const char *names[MAXFILES];
    const char *mode = "w";
    int count = 0;
    int ch;
    int i;
    int ret = 0;

    argv++;
    argc--;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        if (strcmp(argv[0], "-a") == 0) {
            mode = "a";
        } else if (strcmp(argv[0], "-i") == 0) {
            /* OS-9 signal handling is intentionally left unchanged. */
        } else {
            usage("tee");
            return 1;
        }
        argv++;
        argc--;
    }

    if (argc > MAXFILES) {
        fprintf(stderr, "tee: too many output files\n");
        return 1;
    }

    while (argc-- > 0) {
        files[count] = fopen(*argv, mode);
        if (!files[count]) {
            fprintf(stderr, "tee: cannot open %s\n", *argv);
            ret = 1;
        } else {
            names[count] = *argv;
            count++;
        }
        argv++;
    }

    while ((ch = getchar()) != EOF) {
        ret |= write_char(stdout, "<stdout>", ch);
        for (i = 0; i < count; i++)
            ret |= write_char(files[i], names[i], ch);
    }

    if (_iob[0]._flag & _ERR) {
        fprintf(stderr, "tee: read error on <stdin>\n");
        ret = 1;
    }

    fflush(stdout);
    for (i = 0; i < count; i++) {
        if (fclose(files[i]) == EOF) {
            fprintf(stderr, "tee: close error on %s\n", names[i]);
            ret = 1;
        }
    }

    return ret;
}
