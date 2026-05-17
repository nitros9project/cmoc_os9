#include <time.h>

/* Shared by mktime() and other Unix-style time helpers. */
int _mdays[] = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };
int _myears[] = { 365, 366 };

int daylight = -1;
long timezone = 0;
