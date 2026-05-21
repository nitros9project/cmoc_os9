/*
 * Adapted from suckless sbase echo.
 */

#include <stdio.h>
#include <string.h>

int
main(int argc, char **argv)
{
    int nflag = 0;
    int first = 1;

    argv++;
    argc--;

    if (argc > 0 && strcmp(argv[0], "-n") == 0) {
        nflag = 1;
        argv++;
        argc--;
    }

    while (argc-- > 0) {
        if (!first)
            putchar(' ');
        fputs(*argv, stdout);
        first = 0;
        argv++;
    }

    if (!nflag)
        putchar('\n');

    fflush(stdout);
    return ferror(stdout) ? 1 : 0;
}
