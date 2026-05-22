/*
 * Adapted from suckless sbase tty.
 */

#include <os.h>
#include <stdio.h>
#include <unistd.h>

static void
clear_high_bit_string(char *s)
{
    while (*s) {
        if ((unsigned char) *s & 0x80) {
            *s &= 0x7f;
            s++;
            break;
        }
        s++;
    }
    *s = '\0';
}

int
main(int argc, char **argv)
{
    char name[32];

    if (argc != 1) {
        fprintf(stderr, "usage: %s\n", argv[0]);
        return 1;
    }

    if (!isatty(STDIN_FILENO)) {
        puts("not a tty");
        return 1;
    }

    if (_os_gs_devnm(STDIN_FILENO, name) != 0) {
        puts("tty");
        return 0;
    }

    clear_high_bit_string(name);
    puts(name);
    return ferror(stdout) ? 1 : 0;
}
