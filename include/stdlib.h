#ifndef _STDLIB_H
#define _STDLIB_H

#include <sys/types.h>

/**
 * @file stdlib.h
 * @brief Conversion, allocation, sorting, and utility routines.
 */

/**
 * @brief Return the next pseudo-random value.
 *
 * @return Pseudo-random integer in the implementation-defined range.
 */
int rand(void);

/**
 * @brief Seed the pseudo-random number generator.
 *
 * @param seed Initial seed value.
 */
void srand(unsigned seed);

#if defined(_CMOC_MC6839_) || defined(_CMOC_NATIVE_FLOAT_)
/**
 * @brief Convert a string to a floating-point value.
 *
 * @param str Input string.
 * @return Parsed floating-point value.
 */
float    atof(const char *str);
#endif
/**
 * @brief Convert a string to `int`.
 *
 * @param str Input string.
 * @return Parsed integer value.
 */
int      atoi(const char *str);

/**
 * @brief Convert a string to `long`.
 *
 * @param str Input string.
 * @return Parsed long value.
 */
long     atol(const char *str);

/**
 * @brief Convert a string to `long` with base control.
 *
 * @param str Input string.
 * @param endptr Optional pointer updated to the first unparsed character.
 * @param base Numeric base from 2 to 36, or 0 for auto-detection.
 * @return Parsed signed long value.
 */
long     strtol(const char *str, char **endptr, int base);

/**
 * @brief Convert a string to `unsigned long` with base control.
 *
 * @param str Input string.
 * @param endptr Optional pointer updated to the first unparsed character.
 * @param base Numeric base from 2 to 36, or 0 for auto-detection.
 * @return Parsed unsigned long value.
 */
unsigned long strtoul(const char *str, char **endptr, int base);

/**
 * @brief Convert an `int` to a decimal string.
 *
 * @param value Value to convert.
 * @param buffer Destination buffer.
 * @return `buffer`.
 */
char     *itoa(int value, char *buffer);

/**
 * @brief Convert a `long` to a decimal string.
 *
 * @param value Value to convert.
 * @param buffer Destination buffer.
 * @return `buffer`.
 */
char     *ltoa(long value, char *buffer);

/**
 * @brief Convert an unsigned value to a decimal string.
 *
 * @param value Value to convert.
 * @param buffer Destination buffer.
 * @return `buffer`.
 */
char     *utoa(unsigned value, char *buffer);

/**
 * @brief Convert an `int` to a base-10 string.
 *
 * @param value Value to convert.
 * @param buffer Destination buffer.
 * @return `buffer`.
 */
char     *itoa10(int value, char *buffer);

/**
 * @brief Convert an unsigned value to a base-10 string.
 *
 * @param value Value to convert.
 * @param buffer Destination buffer.
 * @return `buffer`.
 */
char     *utoa10(unsigned value, char *buffer);

/**
 * @brief Convert a hexadecimal string to `int`.
 *
 * @param str Input string.
 * @return Parsed integer value.
 */
int      htoi(const char *str);

/**
 * @brief Convert a hexadecimal string to `long`.
 *
 * @param str Input string.
 * @return Parsed long value.
 */
long     htol(const char *str);

/**
 * @brief Return the greater of two signed integers.
 *
 * @param a First value.
 * @param b Second value.
 * @return Greater value.
 */
int      max(int a, int b);

/**
 * @brief Return the lesser of two signed integers.
 *
 * @param a First value.
 * @param b Second value.
 * @return Lesser value.
 */
int      min(int a, int b);

/**
 * @brief Return the lesser of two unsigned integers.
 *
 * @param a First value.
 * @param b Second value.
 * @return Lesser value.
 */
unsigned umin(unsigned a, unsigned b);

/**
 * @brief Return the greater of two unsigned integers.
 *
 * @param a First value.
 * @param b Second value.
 * @return Greater value.
 */
unsigned umax(unsigned a, unsigned b);

/**
 * @brief Fill a `mktemp()` template in place.
 *
 * @param template Template buffer ending in replacement characters.
 * @return `template`.
 */
char     *mktemp(char *template);

/**
 * @brief Execute a command string through the system shell.
 *
 * @param command Command string to execute.
 * @return Implementation-defined status code.
 */
int      system(const char *command);

/**
 * @brief Terminate the process abnormally.
 */
void     abort(void);

/**
 * @brief Convert packed 3-byte values into longs.
 *
 * @param lp Destination long array.
 * @param cp Source packed-byte array.
 * @param n Number of values to convert.
 */
void     l3tol(long *lp, const char *cp, int n);

/**
 * @brief Convert longs into packed 3-byte values.
 *
 * @param cp Destination packed-byte array.
 * @param lp Source long array.
 * @param n Number of values to convert.
 */
void     ltol3(char *cp, const long *lp, int n);

/**
 * @brief Convert one packed 3-byte value into a long.
 *
 * @param lp Destination long pointer.
 * @param cp Source packed-byte value.
 */
void     c3tol(long *lp, const char *cp);

/**
 * @brief Convert one long into packed 3-byte form.
 *
 * @param cp Destination packed-byte buffer.
 * @param value Source long value.
 */
void     ltoc3(char *cp, long value);

/**
 * @brief Allocate zero-initialized memory.
 *
 * @param count Number of objects.
 * @param size Size of each object.
 * @return Allocated block on success, or `NULL` on failure.
 */
void     *calloc(size_t count, size_t size);

/**
 * @brief Release memory previously allocated by the allocator.
 *
 * @param ptr Allocation to free. `NULL` is allowed.
 */
void     free(void *ptr);

/**
 * @brief Allocate an uninitialized memory block.
 *
 * @param size Size in bytes.
 * @return Allocated block on success, or `NULL` on failure.
 */
void     *malloc(size_t size);

/**
 * @brief Resize an existing allocation.
 *
 * @param ptr Existing allocation, or `NULL`.
 * @param size New size in bytes.
 * @return Reallocated block on success, or `NULL` on failure.
 */
void     *realloc(void *ptr, size_t size);

/**
 * @brief Search a sorted array for a key.
 *
 * @param key Key to search for.
 * @param base Base of the sorted array.
 * @param nmemb Number of elements.
 * @param size Size of each element.
 * @param compar Comparison callback.
 * @return Pointer to matching element, or `NULL` if not found.
 */
void     *bsearch(const void *key, const void *base, size_t nmemb, size_t size,
                  int (*compar)(const void *, const void *));

/**
 * @brief Sort an array in place.
 *
 * @param base Base of the array.
 * @param nmemb Number of elements.
 * @param size Size of each element.
 * @param compar Comparison callback.
 */
void     qsort(void *base, size_t nmemb, size_t size,
               int (*compar)(const void *, const void *));

#endif
