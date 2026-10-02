#include "cmoc_os9.h"
#include <assert.h>
#include <errno.h>
#include <math.h>
int main(void) {
  char b[32], s[32] = "abc", packed[6];
  long values[] = {0xabcdefL, 0x123456L}, back[2];
  unsigned char state[3] = {255, 255, 255};
  char *a = allocset(), *c = allocset();
  struct os_time t = {100, 2, 29, 12, 34, 56};
  struct tm tm = {0};
  int e;
  const char *banana = "banana";
  assert(a && c);
  addc2set(a, 255);
  adds2set(a, "abc");
  assert(smember(a, 255) && smember(a, 'a'));
  addc2set(c, 'b');
  sdifference(a, c);
  assert(!smember(a, 'b') && smember(a, 255));
  free(a);
  free(c);
  assert(strhcpy(b, "co\xef") == b && !strcmp(b, "coo"));
  assert(strtohstr(b, "") == b && b[0] == 0);
  strucpy(b, "ab-C");
  assert(!strcmp(b, "AB-C"));
  assert(!strucmp("AbC", "abc") && !strnucmp("AbCd", "aBcX", 3));
  assert(reverse(s) == s && !strcmp(s, "cba"));
  assert(findnstr(banana, "ana", 2) == banana + 1);
  assert(findnstr("banana", "ana", 1) == 0);
  ltol3(packed, values, 2);
  l3tol(back, packed, 2);
  assert(back[0] == values[0] && back[1] == values[1]);
  assert(cmoc_swab(0x1234) == 0x3412);
  assert(!strcmp(cmoc_itoa(-32768, b), "-32768"));
  assert(!strcmp(ltoa(-2147483647L - 1, b), "-2147483648"));
  /* ToolShed c3/test/_os9.c kernel CRC reference vector. */
  crc("This is a buffer", 16, state);
  assert(state[0] == 0xb3 && state[1] == 0xa7 && state[2] == 0xcc);
  assert(o2utime(&t) == (time_t)951827696);
  t.year = 200;
  t.month = 2;
  t.day = 29;
  assert(o2utime(&t) == (time_t)-1 && errno == E$IBA);
  tm.tm_year = 126;
  tm.tm_mon = 9;
  tm.tm_mday = 1;
  u2otime(&t, &tm);
  assert(t.year == 126 && t.month == 10 && t.day == 1);
  assert(frexp(-8, &e) == -0.5 && e == 4);
  assert(ldexp(0.5, 4) == 8);
  assert(frexp(0, &e) == 0 && e == 0);
  puts("LLVM extension regression tests passed");
  return 0;
}
