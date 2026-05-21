/*
 * Adapted from suckless sbase dirname.
 */

#include <stdio.h>
#include <string.h>

int
main(int argc, char **argv)
{
    char *path;
    char *p;
    int len;

    if (argc != 2) {
        fprintf(stderr, "usage: %s path\n", argv[0]);
        return 1;
    }

    path = argv[1];
    len = strlen(path);
    while (len > 1 && (path[len - 1] == '/' || path[len - 1] == '\\'))
        path[--len] = '\0';

    p = path + len;
    while (p > path && p[-1] != '/' && p[-1] != '\\')
        p--;

    if (p == path) {
        puts(".");
    } else {
        while (p > path && (p[-1] == '/' || p[-1] == '\\'))
            p--;
        if (p == path) {
            putchar(path[0]);
            putchar('\n');
        } else {
            *p = '\0';
            puts(path);
        }
    }

    return ferror(stdout) ? 1 : 0;
}
