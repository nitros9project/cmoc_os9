/*
 * time.h - Time definitions
 */

#ifndef CMOC_OS9_TIME_H
#define CMOC_OS9_TIME_H

#include <os.h>

/**
 * @file time.h
 * @brief OS-9 and Unix-style time conversion and formatting services.
 */

#define TM_YEAR_BASE 1900
#define EPOCH_YEAR 1970
#define EPOCH_DOW 4

/**
 * @brief Unix-style seconds value used by the CMOC OS-9 C Library.
 */
typedef long time_t;

/**
 * @brief OS-9 date/time packet used by low-level clock calls.
 */
struct os_time
{
    /** Year offset stored by OS-9. */
    byte year;
    /** Month number in OS-9 packet form. */
    byte month;
    /** Day of month. */
    byte day;
    /** Hour of day. */
    byte hours;
    /** Minute of hour. */
    byte minutes;
    /** Second of minute. */
    byte seconds;
};

/**
 * @brief Broken-down calendar time structure.
 */
struct tm {
    /** Seconds after the minute, 0-60. */
    int tm_sec;
    /** Minutes after the hour, 0-59. */
    int tm_min;
    /** Hours since midnight, 0-23. */
    int tm_hour;
    /** Day of month, 1-31. */
    int tm_mday;
    /** Months since January, 0-11. */
    int tm_mon;
    /** Years since 1900. */
    int tm_year;
    /** Days since Sunday, 0-6. */
    int tm_wday;
    /** Days since January 1, 0-365. */
    int tm_yday;
    /** Daylight-saving flag, if known. */
    int tm_isdst;
};

/** @brief Non-zero when local time observes daylight saving rules. */
extern int daylight;
/** @brief Seconds west of UTC for the current local time zone. */
extern long timezone;

/**
 * @brief Return the current Unix-style time value.
 *
 * @param arg Optional destination pointer.
 * @return Current time value.
 */
time_t time(time_t *arg);

/**
 * @brief Convert an OS-9 time packet to `time_t`.
 *
 * @param tp Source OS-9 time packet.
 * @return Converted Unix-style time value.
 */
time_t o2utime(_os_time *tp);

/**
 * @brief Convert broken-down time into an OS-9 time packet.
 *
 * @param otime Destination OS-9 time packet.
 * @param tmp Source broken-down time.
 */
void u2otime(_os_time *otime, struct tm *tmp);

/**
 * @brief Convert `time_t` to local broken-down time.
 *
 * @param ticks Source time value.
 * @return Pointer to a static `struct tm`.
 */
struct tm *localtime(const time_t *ticks);

/**
 * @brief Convert `time_t` to UTC broken-down time.
 *
 * @param ticks Source time value.
 * @return Pointer to a static `struct tm`.
 */
struct tm *gmtime(const time_t *ticks);

/**
 * @brief Format broken-down time as an ASCII string.
 *
 * @param tmp Source broken-down time.
 * @return Pointer to a static string buffer.
 */
char *asctime(const struct tm *tmp);

/**
 * @brief Format a `time_t` value as an ASCII string.
 *
 * @param ticks Source time value.
 * @return Pointer to a static string buffer.
 */
char *ctime(const time_t *ticks);

/**
 * @brief Convert broken-down local time to `time_t`.
 *
 * @param tp Broken-down time to normalize and convert.
 * @return Converted time value.
 */
time_t mktime(struct tm *tp);

#endif
