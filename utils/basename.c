/*
 * Adapted from suckless sbase basename.
 */

#include <stdio.h>
#include <string.h>

static char *
base_name(char *path)
{
    char *p;
    int len;

    len = strlen(path);
    while (len > 1 && (path[len - 1] == '/' || path[len - 1] == '\\'))
        path[--len] = '\0';

    p = path + len;
    while (p > path && p[-1] != '/' && p[-1] != '\\')
        p--;

    return p;
}

int
main(int argc, char **argv)
{
    char *name;
    char *suffix;
    int nlen;
    int slen;

    if (argc < 2 || argc > 3) {
        fprintf(stderr, "usage: %s path [suffix]\n", argv[0]);
        return 1;
    }

    name = base_name(argv[1]);
    if (argc == 3) {
        suffix = argv[2];
        nlen = strlen(name);
        slen = strlen(suffix);
        if (slen > 0 && nlen > slen &&
            strcmp(name + nlen - slen, suffix) == 0)
            name[nlen - slen] = '\0';
    }

    puts(name);
    return ferror(stdout) ? 1 : 0;
}
