/*
 * Adapted from suckless sbase paste.
 */

#include <stdio.h>
#include <string.h>

#define MAXFILES 8
#define LINEBUF 256

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-s] [-d list] file ...\n", progname);
}

static void
chomp(char *line)
{
    int len = strlen(line);

    while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r'))
        line[--len] = '\0';
}

int
main(int argc, char **argv)
{
    FILE *fp[MAXFILES];
    char *names[MAXFILES];
    char line[LINEBUF];
    char default_delim[] = "\t";
    char *delim;
    int sequential = 0;
    int nfiles = 0;
    int active;
    int i;
    int ret = 0;

    argv++;
    argc--;
    delim = default_delim;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        if (strcmp(argv[0], "-s") == 0) {
            sequential = 1;
        } else if (strcmp(argv[0], "-d") == 0) {
            if (argc < 2) {
                usage("paste");
                return 1;
            }
            delim = argv[1];
            argv++;
            argc--;
        } else {
            usage("paste");
            return 1;
        }
        argv++;
        argc--;
    }

    if (argc == 0 || argc > MAXFILES) {
        usage("paste");
        return 1;
    }

    while (argc-- > 0) {
        names[nfiles] = *argv;
        if (strcmp(*argv, "-") == 0) {
            fp[nfiles] = stdin;
            nfiles++;
        } else {
            fp[nfiles] = fopen(*argv, "r");
            if (!fp[nfiles]) {
                fprintf(stderr, "paste: cannot open %s\n", *argv);
                ret = 1;
            } else {
                nfiles++;
            }
        }
        argv++;
    }

    if (sequential) {
        for (i = 0; i < nfiles; i++) {
            active = 0;
            while (fgets(line, sizeof(line), fp[i])) {
                chomp(line);
                if (active)
                    putchar(delim[(active - 1) % strlen(delim)]);
                fputs(line, stdout);
                active++;
            }
            putchar('\n');
        }
    } else {
        for (;;) {
            active = 0;
            for (i = 0; i < nfiles; i++) {
                if (fgets(line, sizeof(line), fp[i])) {
                    chomp(line);
                    if (active)
                        putchar(delim[(active - 1) % strlen(delim)]);
                    fputs(line, stdout);
                    active++;
                } else if (active) {
                    putchar(delim[(active - 1) % strlen(delim)]);
                }
            }
            if (!active)
                break;
            putchar('\n');
        }
    }

    for (i = 0; i < nfiles; i++) {
        if (ferror(fp[i])) {
            fprintf(stderr, "paste: read error on %s\n", names[i]);
            ret = 1;
        }
        if (fp[i] != stdin)
            fclose(fp[i]);
    }
    fflush(stdout);

    return ret;
}
