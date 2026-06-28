/*
 * Adapted from suckless sbase cal.
 *
 * Differences from upstream: no util.h/ARGBEGIN, manual option parsing,
 * 16-bit int instead of size_t, sprintf instead of snprintf, and the
 * month-header centering is done with explicit padding because the CMOC
 * printf does not support the "%*s" variable-width conversion.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

enum { JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC };
enum caltype { JULIAN, GREGORIAN };
enum { TRANS_YEAR = 1752, TRANS_MONTH = SEP, TRANS_DAY = 2 };

static struct tm *ltime;

static void
usage(void)
{
    fprintf(stderr, "usage: cal [-1 | -3 | -y | -n num] "
        "[-s | -m | -f num] [-c num] [[month] year]\n");
    exit(1);
}

static int
getnum(const char *s, int lo, int hi)
{
    char *end;
    long v;

    v = strtol(s, &end, 10);
    if (*s == '\0' || *end != '\0' || v < lo || v > hi)
        usage();
    return (int)v;
}

static int
isleap(int year, int cal)
{
    if (cal == GREGORIAN) {
        if (year % 400 == 0)
            return 1;
        if (year % 100 == 0)
            return 0;
        return (year % 4 == 0);
    }
    /* cal == JULIAN */
    return (year % 4 == 0);
}

static int
monthlength(int year, int month, int cal)
{
    int mdays[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    return (month == FEB && isleap(year, cal)) ? 29 : mdays[month];
}

/* From http://www.tondering.dk/claus/cal/chrweek.php#calcdow */
static int
dayofweek(int year, int month, int dom, int cal)
{
    int y, m, a;

    a = (13 - month) / 12;
    y = year - a;
    m = month + 12 * a - 1;

    if (cal == GREGORIAN)
        return (dom + y + y / 4 - y / 100 + y / 400 + (31 * m) / 12) % 7;
    /* cal == JULIAN */
    return (5 + dom + y + y / 4 + (31 * m) / 12) % 7;
}

static void
printspaces(int n)
{
    while (n-- > 0)
        putchar(' ');
}

static void
printgrid(int year, int month, int fday, int line)
{
    int cal;
    int offset, dom, d = 0, trans; /* trans: in the Julian->Gregorian switch? */
    int today = 0;

    cal = (year < TRANS_YEAR || (year == TRANS_YEAR && month <= TRANS_MONTH)) ? JULIAN : GREGORIAN;
    trans = (year == TRANS_YEAR && month == TRANS_MONTH);
    offset = dayofweek(year, month, 1, cal) - fday;

    if (offset < 0)
        offset += 7;
    if (line == 1) {
        for (; d < offset; ++d)
            printf("   ");
        dom = 1;
    } else {
        dom = 8 - offset + (line - 2) * 7;
        if (trans && !(line == 2 && fday == 3))
            dom += 11;
    }
    if (ltime && year == ltime->tm_year + 1900 && month == ltime->tm_mon)
        today = ltime->tm_mday;
    for (; d < 7 && dom <= monthlength(year, month, cal); ++d, ++dom) {
        if (dom == today)
            /*
             * Highlight today's date using the NitrOS-9 windowing text
             * attribute codes (not ANSI): 1F 20 turns reverse video on,
             * 1F 21 turns it off.  (ESC/1B is the window command lead-in,
             * so ANSI "1B 5B" sequences make the driver error out.)
             */
            printf("\x1f\x20%2d\x1f\x21 ", dom);
        else
            printf("%2d ", dom);
        if (trans && dom == TRANS_DAY)
            dom += 11;
    }
    for (; d < 7; ++d)
        printf("   ");
}

static void
drawcal(int year, int month, int ncols, int nmons, int fday)
{
    const char *smon[] = { "January", "February", "March", "April",
                           "May", "June", "July", "August",
                           "September", "October", "November", "December" };
    const char *days[] = { "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" };
    int m, n, col, cur_year, cur_month, dow;
    int line, pad;
    char month_year[24];

    for (m = 0; m < nmons; ) {
        n = m;
        for (col = 0; m < nmons && col < ncols; ++col, ++m) {
            cur_year = year + m / 12;
            cur_month = month + m % 12;
            if (cur_month > 11) {
                cur_month -= 12;
                cur_year += 1;
            }
            sprintf(month_year, "%s %d", smon[cur_month], cur_year);
            /* center under the "Su Mo Tu We Th Fr Sa" day-name row (20 wide) */
            pad = 20 - (int)strlen(month_year);
            if (pad < 0)
                pad = 0;
            printspaces(pad / 2 + pad % 2);
            fputs(month_year, stdout);
            printspaces(pad / 2);
            fputs("   ", stdout);
        }
        putchar('\n');
        for (col = 0, m = n; m < nmons && col < ncols; ++col, ++m) {
            for (dow = fday; dow < (fday + 7); ++dow)
                printf("%s ", days[dow % 7]);
            printf("  ");
        }
        putchar('\n');
        for (line = 1; line <= 6; ++line) {
            for (col = 0, m = n; m < nmons && col < ncols; ++col, ++m) {
                cur_year = year + m / 12;
                cur_month = month + m % 12;
                if (cur_month > 11) {
                    cur_month -= 12;
                    cur_year += 1;
                }
                printgrid(cur_year, cur_month, fday, line);
                printf("  ");
            }
            putchar('\n');
        }
    }
}

int
main(int argc, char **argv)
{
    time_t now;
    int year, ncols, nmons, fday, month;
    int i;

    now   = time(NULL);
    ltime = localtime(&now);
    year  = ltime->tm_year + 1900;
    month = ltime->tm_mon + 1;
    fday  = 0;

    if (!isatty(STDOUT_FILENO))
        ltime = NULL; /* don't highlight today's date */

    ncols = 3;
    nmons = 0;

    for (i = 1; i < argc && argv[i][0] == '-' && argv[i][1] != '\0'; i++) {
        char *opt = argv[i];

        if (strcmp(opt, "-1") == 0) {
            nmons = 1;
        } else if (strcmp(opt, "-3") == 0) {
            nmons = 3;
            if (--month == 0) {
                month = 12;
                year--;
            }
        } else if (strcmp(opt, "-y") == 0) {
            month = 1;
            nmons = 12;
        } else if (strcmp(opt, "-s") == 0) { /* week starts Sunday */
            fday = 0;
        } else if (strcmp(opt, "-m") == 0) { /* week starts Monday */
            fday = 1;
        } else if (strcmp(opt, "-c") == 0) {
            if (++i >= argc)
                usage();
            ncols = getnum(argv[i], 1, 32767);
        } else if (strcmp(opt, "-f") == 0) {
            if (++i >= argc)
                usage();
            fday = getnum(argv[i], 0, 6);
        } else if (strcmp(opt, "-n") == 0) {
            if (++i >= argc)
                usage();
            nmons = getnum(argv[i], 1, 32767);
        } else {
            usage();
        }
    }

    argc -= i;
    argv += i;

    if (nmons == 0) {
        if (argc == 1) { /* a lone year argument shows the whole year */
            month = 1;
            nmons = 12;
        } else {
            nmons = 1;
        }
    }

    switch (argc) {
    case 2:
        month = getnum(argv[0], 1, 12);
        year  = getnum(argv[1], 0, 32767);
        break;
    case 1:
        year  = getnum(argv[0], 0, 32767);
        break;
    case 0:
        break;
    default:
        usage();
    }

    drawcal(year, month - 1, ncols, nmons, fday);

    fflush(stdout);
    return ferror(stdout) ? 1 : 0;
}
