/*
 * Adapted from suckless sbase cksum.
 */

#include <stdio.h>
#include <string.h>

#define POLY 0x04c11db7UL

static unsigned long
crc_byte(unsigned long crc, unsigned int ch)
{
    int i;

    crc ^= ((unsigned long) ch) << 24;
    for (i = 0; i < 8; i++) {
        if (crc & 0x80000000UL)
            crc = (crc << 1) ^ POLY;
        else
            crc <<= 1;
    }

    return crc;
}

static int
cksum_stream(FILE *fp, const char *name, int print_name)
{
    unsigned char buf[128];
    unsigned long crc = 0;
    unsigned long len = 0;
    unsigned long n;
    unsigned int i;

    while ((n = fread(buf, 1, sizeof(buf), fp)) > 0) {
        for (i = 0; i < n; i++)
            crc = crc_byte(crc, buf[i]);
        len += n;
    }

    if (ferror(fp)) {
        fprintf(stderr, "cksum: read error on %s\n", name);
        return 1;
    }

    for (n = len; n != 0; n >>= 8)
        crc = crc_byte(crc, (unsigned int) (n & 0xff));

    printf("%lu %lu", ~crc, len);
    if (print_name)
        printf(" %s", name);
    putchar('\n');

    return 0;
}

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [file ...]\n", progname);
}

int
main(int argc, char **argv)
{
    FILE *fp;
    int ret = 0;

    argv++;
    argc--;

    if (argc > 0 && argv[0][0] == '-') {
        if (strcmp(argv[0], "--") == 0) {
            argv++;
            argc--;
        } else if (strcmp(argv[0], "-") != 0) {
            usage("cksum");
            return 1;
        }
    }

    if (argc == 0) {
        ret = cksum_stream(stdin, "<stdin>", 0);
    } else {
        while (argc-- > 0) {
            if (strcmp(*argv, "-") == 0) {
                ret |= cksum_stream(stdin, "<stdin>", 0);
            } else {
                fp = fopen(*argv, "r");
                if (!fp) {
                    fprintf(stderr, "cksum: cannot open %s\n", *argv);
                    ret = 1;
                } else {
                    ret |= cksum_stream(fp, *argv, 1);
                    fclose(fp);
                }
            }
            argv++;
        }
    }

    fflush(stdout);
    return ret;
}
