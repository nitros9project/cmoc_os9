/*
 * Adapted from suckless sbase sleep.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s seconds\n", progname);
}

int
main(int argc, char **argv)
{
    char *end;
    unsigned long seconds;
    unsigned long ticks;

    if (argc != 2) {
        usage(argv[0]);
        return 1;
    }

    seconds = strtoul(argv[1], &end, 10);
    if (*argv[1] == '\0' || *end != '\0') {
        usage(argv[0]);
        return 1;
    }

    while (seconds > 0) {
        ticks = seconds > 1000UL ? 60000UL : seconds * 60UL;
        tsleep((clock_t) ticks);
        seconds -= ticks / 60UL;
    }

    return 0;
}
