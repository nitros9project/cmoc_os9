/*
 * Adapted from suckless sbase yes.
 */

#include <stdio.h>

int
main(int argc, char **argv)
{
    char default_text[] = "y";
    char *text;

    if (argc > 2) {
        fprintf(stderr, "usage: %s [string]\n", argv[0]);
        return 1;
    }

    text = default_text;
    if (argc == 2)
        text = argv[1];
    while (!ferror(stdout))
        puts(text);

    return 1;
}
