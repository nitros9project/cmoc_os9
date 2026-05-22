#include <stdio.h>
#include <string.h>

static int cflag;
static int dflag;
static int sflag;

struct charset {
    unsigned char list[256];
    unsigned char map[256];
    unsigned char present[256];
    unsigned int len;
};

static void
usage(const char *progname)
{
    fprintf(stderr, "usage: %s [-c] [-d] [-s] set1 [set2]\n", progname);
}

static int
escaped_char(const char **sp, unsigned char *out)
{
    const char *s = *sp;

    if (*s != '\\') {
        *out = (unsigned char) *s;
        *sp = s + 1;
        return 1;
    }

    s++;
    switch (*s) {
    case 'n':
        *out = '\n';
        break;
    case 'r':
        *out = '\r';
        break;
    case 't':
        *out = '\t';
        break;
    case '\\':
        *out = '\\';
        break;
    case '0':
        *out = '\0';
        break;
    case '\0':
        return 0;
    default:
        *out = (unsigned char) *s;
        break;
    }
    *sp = s + 1;
    return 1;
}

static void
add_char(struct charset *set, unsigned char ch)
{
    set->present[ch] = 1;
    set->map[ch] = 1;
    if (set->len < 256)
        set->list[set->len++] = ch;
}

static void
parse_set(const char *text, struct charset *set)
{
    const char *s = text;
    const char *look;
    unsigned char first;
    unsigned char last;
    unsigned char ch;
    int i;

    memset(set, 0, sizeof(*set));

    while (*s) {
        if (!escaped_char(&s, &first))
            break;

        if (*s == '-' && s[1] != '\0') {
            look = s + 1;
            if (escaped_char(&look, &last) && last >= first) {
                for (i = first; i <= last; i++)
                    add_char(set, (unsigned char) i);
                s = look;
                continue;
            }
        }

        ch = first;
        add_char(set, ch);
    }
}

static void
complement_set(struct charset *set)
{
    struct charset tmp;
    int i;

    memset(&tmp, 0, sizeof(tmp));
    for (i = 0; i < 256; i++) {
        if (!set->present[i])
            add_char(&tmp, (unsigned char) i);
    }
    *set = tmp;
}

int
main(int argc, char **argv)
{
    struct charset set1;
    struct charset set2;
    unsigned char xlat[256];
    int ch;
    int last_out = -1;
    unsigned int i;

    argv++;
    argc--;

    while (argc > 0 && argv[0][0] == '-' && argv[0][1] != '\0') {
        if (strcmp(argv[0], "-c") == 0) {
            cflag = 1;
        } else if (strcmp(argv[0], "-d") == 0) {
            dflag = 1;
        } else if (strcmp(argv[0], "-s") == 0) {
            sflag = 1;
        } else {
            usage("tr");
            return 1;
        }
        argv++;
        argc--;
    }

    if (argc < 1 || argc > 2 || (dflag && argc != 1 && argc != 2)) {
        usage("tr");
        return 1;
    }

    parse_set(argv[0], &set1);
    if (cflag)
        complement_set(&set1);

    memset(&set2, 0, sizeof(set2));
    if (argc == 2)
        parse_set(argv[1], &set2);

    for (i = 0; i < 256; i++)
        xlat[i] = (unsigned char) i;

    if (argc == 2 && !dflag) {
        if (set2.len == 0) {
            fprintf(stderr, "tr: cannot map to an empty set\n");
            return 1;
        }
        for (i = 0; i < set1.len; i++) {
            if (i < set2.len)
                xlat[set1.list[i]] = set2.list[i];
            else
                xlat[set1.list[i]] = set2.list[set2.len - 1];
        }
    }

    while ((ch = getc(stdin)) != EOF) {
        if (set1.present[(unsigned char) ch]) {
            if (dflag)
                continue;
            ch = xlat[(unsigned char) ch];
        }

        if (sflag && ch == last_out) {
            if (argc == 2) {
                if (set2.present[(unsigned char) ch])
                    continue;
            } else {
                if (set1.present[(unsigned char) ch])
                    continue;
            }
        }

        if (putc(ch, stdout) == EOF) {
            fprintf(stderr, "tr: write error on <stdout>\n");
            return 1;
        }
        last_out = ch;
    }

    if (_iob[0]._flag & _ERR) {
        fprintf(stderr, "tr: read error on <stdin>\n");
        return 1;
    }

    fflush(stdout);
    fflush(stderr);
    return 0;
}
