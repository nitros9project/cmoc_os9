#include <sys/types.h>

#ifndef _STRING_H
#define _STRING_H

/**
 * @file string.h
 * @brief String, memory, hstring, and pattern-matching helpers.
 */

/**
 * @brief Append `src` to the end of `dst`.
 *
 * @param dst Destination string buffer.
 * @param src Source string.
 * @return `dst`.
 */
char  *strcat(char *dst, const char *src);

/**
 * @brief Append at most `n` characters from `src` to `dst`.
 *
 * @param dst Destination string buffer.
 * @param src Source string.
 * @param n Maximum number of characters to append.
 * @return `dst`.
 */
char  *strncat(char *dst, const char *src, size_t n);

/**
 * @brief Copy a string using hstring-compatible semantics.
 *
 * @param dst Destination buffer.
 * @param src Source string.
 * @return `dst`.
 */
char  *strhcpy(char *dst, const char *src);

/**
 * @brief Copy a null-terminated string.
 *
 * @param dst Destination buffer.
 * @param src Source string.
 * @return `dst`.
 */
char  *strcpy(char *dst, const char *src);

/**
 * @brief Copy at most `len` characters from `src`.
 *
 * @param dst Destination buffer.
 * @param src Source string.
 * @param len Maximum number of bytes to copy.
 * @return `dst`.
 */
char  *strncpy(char *dst, const char *src, size_t len);

/**
 * @brief Clear `cnt` characters in a string buffer.
 *
 * @param str Buffer to modify.
 * @param cnt Number of bytes to clear.
 * @return `str`.
 */
char  *strclr(char *str, int cnt);

/**
 * @brief Concatenate strings with uppercase conversion semantics.
 *
 * @param dst Destination buffer.
 * @param src Source string.
 * @return `dst`.
 */
char  *strucat(char *dst, const char *src);

/**
 * @brief Copy a string with uppercase conversion semantics.
 *
 * @param dst Destination buffer.
 * @param src Source string.
 * @return `dst`.
 */
char  *strucpy(char *dst, const char *src);

/**
 * @brief Find the first occurrence of a character in a string.
 *
 * @param str String to search.
 * @param c Character value to find.
 * @return Pointer to the matching character, or `NULL`.
 */
char  *index(char *str, int c);

/**
 * @brief Find the last occurrence of a character in a string.
 *
 * @param str String to search.
 * @param c Character value to find.
 * @return Pointer to the matching character, or `NULL`.
 */
char  *rindex(char *str, int c);

/**
 * @brief Reverse a string in place.
 *
 * @param str String to reverse.
 * @return `str`.
 */
char  *reverse(char *str);

/**
 * @brief Encrypt or transform a password string in place.
 *
 * @param str String buffer to transform.
 * @return `str`.
 */
char  *pwcryp(char *str);

/**
 * @brief Return a pointer to the end of a string.
 *
 * @param str Input string.
 * @return Pointer to the terminating null byte.
 */
char  *strend(const char *str);

/**
 * @brief Compare two strings lexically.
 *
 * @param s1 First string.
 * @param s2 Second string.
 * @return Negative, zero, or positive according to lexical ordering.
 */
int   strcmp(const char *s1, const char *s2);

/**
 * @brief Compare two strings up to `len` characters.
 *
 * @param s1 First string.
 * @param s2 Second string.
 * @param len Maximum number of characters to compare.
 * @return Negative, zero, or positive according to lexical ordering.
 */
int   strncmp(const char *s1, const char *s2, size_t len);

/**
 * @brief Return the length of a string.
 *
 * @param s Input string.
 * @return Number of characters before the terminating null.
 */
int   strlen(const char *s);

/**
 * @brief Compare two strings ignoring case.
 *
 * @param s1 First string.
 * @param s2 Second string.
 * @return Negative, zero, or positive according to lexical ordering.
 */
int   strucmp(const char *s1, const char *s2);

/**
 * @brief Compare two strings ignoring case up to `len` characters.
 *
 * @param s1 First string.
 * @param s2 Second string.
 * @param len Maximum number of characters to compare.
 * @return Negative, zero, or positive according to lexical ordering.
 */
int   strnucmp(const char *s1, const char *s2, size_t len);

/**
 * @brief Match a string against a wildcard or pattern string.
 *
 * @param pattern Pattern to test.
 * @param str Candidate string.
 * @param forceCase Non-zero to force case-sensitive matching.
 * @return Non-zero if the string matches.
 */
int   patmatch(const char *pattern, const char *str, char forceCase);

/**
 * @brief Standard alias for `index()`.
 *
 * @param str String to search.
 * @param c Character value to find.
 * @return Pointer to the matching character, or `NULL`.
 */
char  *strchr(char *str, int c);

/**
 * @brief Standard alias for `rindex()`.
 *
 * @param str String to search.
 * @param c Character value to find.
 * @return Pointer to the matching character, or `NULL`.
 */
char  *strrchr(char *str, int c);

/**
 * @brief Return the length of the initial accepted-character span.
 *
 * @param s1 Input string.
 * @param s2 Set of accepted characters.
 * @return Length of the initial span.
 */
size_t strspn(const char *s1, const char *s2);

/**
 * @brief Return the length of the initial rejected-character span.
 *
 * @param s1 Input string.
 * @param s2 Set of stop characters.
 * @return Length of the initial span.
 */
size_t strcspn(const char *s1, const char *s2);

/**
 * @brief Tokenize a string using separator characters.
 *
 * @param str Input string on first call, or `NULL` to continue.
 * @param step Separator-character string.
 * @return Pointer to the next token, or `NULL` when done.
 */
char  *strtok(char *str, char *step);

/**
 * @brief Find the first character in `s1` that belongs to `s2`.
 *
 * @param s1 Input string.
 * @param s2 Character set to search for.
 * @return Pointer to the first matching character, or `NULL`.
 */
char  *strpbrk(const char *s1, const char *s2);

/**
 * @brief Find a substring inside another string.
 *
 * @param haystack String to search.
 * @param needle Substring to find.
 * @return Pointer to the first match, or `NULL`.
 */
char  *findstr(const char *haystack, const char *needle);

/**
 * @brief Find a substring inside another string with a maximum search limit.
 *
 * @param haystack String to search.
 * @param needle Substring to find.
 * @param limit Maximum number of bytes to scan.
 * @return Pointer to the first match, or `NULL`.
 */
char  *findnstr(const char *haystack, const char *needle, int limit);

/**
 * @brief Low-level counted string assignment helper.
 *
 * @param to Destination buffer.
 * @param from Source buffer.
 * @param count Number of bytes to copy.
 */
void _strass(char *to, char *from, int count);

/**
 * @brief Copy raw bytes from `src` to `dst`.
 *
 * @param dst Destination buffer.
 * @param src Source buffer.
 * @param len Number of bytes to copy.
 * @return `dst`.
 */
void *memcpy(void *dst, void *src, size_t len);

/**
 * @brief Copy bytes until a terminator byte is seen or `n` bytes are copied.
 *
 * @param dst Destination buffer.
 * @param src Source buffer.
 * @param c Terminator byte to stop after copying.
 * @param n Maximum number of bytes to copy.
 * @return Pointer just past the copied terminator byte, or `NULL`.
 */
void *memccpy(char *dst, const char *src, int c, int n);

/**
 * @brief Fill a memory region with a byte value.
 *
 * @param dst Destination buffer.
 * @param c Fill byte value.
 * @param len Number of bytes to fill.
 * @return `dst`.
 */
void *memset(void *dst, int c, size_t len);

/**
 * @brief Find the first occurrence of a byte in a memory region.
 *
 * @param data Buffer to scan.
 * @param c Byte value to find.
 * @param len Number of bytes to scan.
 * @return Pointer to the matching byte, or `NULL`.
 */
void *memchr(void *data, int c, size_t len);

/**
 * @brief Compare two byte buffers.
 *
 * @param dst First buffer.
 * @param src Second buffer.
 * @param len Number of bytes to compare.
 * @return Negative, zero, or positive according to lexical ordering.
 */
int memcmp(const char *dst, const char *src, size_t len);

/**
 * @brief Compare two byte buffers using legacy semantics.
 *
 * @param dst First buffer.
 * @param src Second buffer.
 * @param len Number of bytes to compare.
 * @return Negative, zero, or positive according to lexical ordering.
 */
int memncmp(const char *dst, const char *src, size_t len);

/**
 * @brief Swap the bytes in a 16-bit integer value.
 *
 * @param value Value to swap.
 * @return Byte-swapped value.
 */
int swab(int value);

/**
 * @brief Convert a standard string to hstring form.
 *
 * @param dst Destination buffer.
 * @param src Source string.
 * @return `dst`.
 */
char *strtohstr(char *dst, const char *src);

/**
 * @brief Convert an hstring to standard string form.
 *
 * @param dst Destination buffer.
 * @param src Source hstring buffer.
 * @return `dst`.
 */
char *hstrtostr(char *dst, char *src);

/**
 * @brief Print an hstring.
 *
 * @param str Pointer to hstring data.
 * @return Non-negative on success, or `EOF` on failure.
 */
int hputs(const char *str);

#endif
