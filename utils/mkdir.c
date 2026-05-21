/*
 * Adapted from suckless sbase mkdir.
 */

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <os.h>

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s dir ...\n", progname);
}

int
main(int argc, char **argv)
{
    int ret = 0;
    int perm = FAP_DIR | FAP_READ | FAP_WRITE | FAP_PREAD | FAP_PWRITE;

    argv++;
    argc--;

    if (argc == 0) {
        usage("mkdir");
        return 1;
    }

    while (argc-- > 0) {
        if (_os_makdir(*argv, perm) != 0) {
            fprintf(stderr, "mkdir: cannot create %s\n", *argv);
            ret = 1;
        }
        argv++;
    }

    return ret;
}
