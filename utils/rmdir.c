/*
 * Adapted from suckless sbase rmdir.
 */

#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s dir ...\n", progname);
}

int
main(int argc, char **argv)
{
    int ret = 0;

    argv++;
    argc--;

    if (argc == 0) {
        usage("rmdir");
        return 1;
    }

    while (argc-- > 0) {
        if (unlinkx(*argv, S_DIR | FAM_READ) != 0) {
            fprintf(stderr, "rmdir: cannot remove %s\n", *argv);
            ret = 1;
        }
        argv++;
    }

    return ret;
}
