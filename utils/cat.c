#include <arg.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-u] [file ...]\n", progname);
}

static int
copy_stream(FILE *fp, const char *name)
{
    int ch;

    while ((ch = fgetc(fp)) != EOF) {
        if (putc(ch, stdout) == EOF) {
            fprintf(stderr, "cat: write error on <stdout>\n");
            return 2;
        }
    }

    if (ferror(fp)) {
        fprintf(stderr, "cat: read error on %s\n", name);
        return 1;
    }

    return 0;
}

int
main(int argc, char **argv)
{
    FILE *fp;
    int ch;
    int ret = 0;
    int status;

    while ((ch = getopt(argc, argv, "u")) != -1) {
        switch (ch) {
        case 'u':
            break;
        default:
            usage(argv[0]);
            return 1;
        }
    }

    argv += optind;
    argc -= optind;

    if (argc == 0) {
        ret = copy_stream(stdin, "<stdin>");
    } else {
        while (*argv) {
            if (strcmp(*argv, "-") == 0) {
                status = copy_stream(stdin, "<stdin>");
            } else {
                fp = fopen(*argv, "r");
                if (!fp) {
                    fprintf(stderr, "cat: cannot open %s\n", *argv);
                    ret = 1;
                    argv++;
                    continue;
                }
                status = copy_stream(fp, *argv);
                fclose(fp);
            }

            if (status == 2)
                return 1;
            if (status == 1)
                ret = 1;
            argv++;
        }
    }

    fflush(stdout);
    fflush(stderr);
    return ret;
}
