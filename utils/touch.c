/* Adapted from suckless sbase touch. Reduced: creates files; time-setting options unsupported (no utime in libc). */

/*
 * This CMOC OS-9 libc has no utime()/utimensat()/futimens(), so arbitrary
 * modification times cannot be set portably.  We therefore implement touch's
 * most important behavior:
 *
 *   - If a FILE does not exist, create it empty (skipped silently with -c).
 *   - If a FILE exists, open it for append and close it.  Under OS-9 this
 *     updates the file's modification date, and append mode never truncates,
 *     so existing contents are preserved.
 *
 * Supported options:
 *   -c   do not create files that do not exist.
 *   -a   accepted and ignored (only selects which timestamp to change).
 *   -m   accepted and ignored (only selects which timestamp to change).
 *
 * NOT supported (no utime in libc): -t / -r / -d explicit time setting.
 * These are recognized but only produce a note on stderr and are ignored.
 */

#include <stdio.h>
#include <unistd.h>

static void
usage(void)
{
    fprintf(stderr, "usage: touch [-acm] file ...\n");
}

static int
touch(const char *file, int cflag)
{
    FILE *fp;

    if (access(file, F_OK) != 0 && cflag)
        return 0; /* file is missing and -c says do not create it */

    /* "a" creates the file if missing and never truncates existing data */
    fp = fopen(file, "a");
    if (!fp) {
        fprintf(stderr, "touch: cannot touch %s\n", file);
        return 1;
    }
    fclose(fp);
    return 0;
}

int
main(int argc, char **argv)
{
    int cflag = 0;
    int ret = 0;
    int i;

    for (i = 1; i < argc && argv[i][0] == '-' && argv[i][1] != '\0'; i++) {
        char *p = argv[i] + 1;
        int done = 0;

        for (; *p && !done; p++) {
            switch (*p) {
            case 'a':
            case 'm':
                break; /* accepted and ignored */
            case 'c':
                cflag = 1;
                break;
            case 't':
            case 'r':
            case 'd':
                fprintf(stderr,
                    "touch: -%c time-setting not supported "
                    "(no utime in libc); ignoring\n", *p);
                /* consume this option's argument so it is not a file name */
                if (p[1] != '\0')
                    done = 1;          /* rest of this token is the argument */
                else if (i + 1 < argc)
                    i++;               /* next token is the argument */
                break;
            default:
                usage();
                return 1;
            }
        }
    }

    argv += i;
    argc -= i;

    if (argc == 0) {
        usage();
        return 1;
    }

    for (; *argv; argv++)
        if (touch(*argv, cflag) != 0)
            ret = 1;

    return ret;
}
