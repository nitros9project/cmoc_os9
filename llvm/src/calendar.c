#include "cmoc_os9.h"
#include <errno.h>
#include <stdarg.h>
static int leap(int y) { return y % 4 == 0 && (y % 100 != 0 || y % 400 == 0); }
time_t o2utime(const struct os_time *p) {
  static const unsigned char days[] = {31, 28, 31, 30, 31, 30,
                                       31, 31, 30, 31, 30, 31};
  long d = 0;
  int year = 1900 + p->year, y, m;
  if (p->month < 1 || p->month > 12 || p->day < 1 ||
      p->day > days[p->month - 1] + (p->month == 2 && leap(year)) ||
      p->hours > 23 || p->minutes > 59 || p->seconds > 59) {
    errno = E$IBA;
    return (time_t)-1;
  }
  if (year >= 1970)
    for (y = 1970; y < year; y++)
      d += 365 + leap(y);
  else
    for (y = year; y < 1970; y++)
      d -= 365 + leap(y);
  for (m = 1; m < p->month; m++)
    d += days[m - 1] + (m == 2 && leap(year));
  d += p->day - 1;
  return (time_t)d * 86400 + (time_t)p->hours * 3600 + p->minutes * 60 +
         p->seconds;
}
void u2otime(struct os_time *p, const struct tm *t) {
  p->year = t->tm_year;
  p->month = t->tm_mon + 1;
  p->day = t->tm_mday;
  p->hours = t->tm_hour;
  p->minutes = t->tm_min;
  p->seconds = t->tm_sec;
}
/* Formatting support is always linked by picolibc: there is no registration
 * state to initialize as there was in the Kreider printf implementation. */
void pflinit(void) {}
void pffinit(void) {}
