/*
 * Adapted from suckless sbase sync.
 */

#include <stdio.h>
#include <unistd.h>

int
main(int argc, char **argv)
{
    if (argc != 1) {
        fprintf(stderr, "usage: %s\n", argv[0]);
        return 1;
    }

    sync();
    return 0;
}
