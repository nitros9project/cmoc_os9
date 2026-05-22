/* Based on the historical Kreider-compatible SETS declarations. */
#ifndef _SETS_H
#define _SETS_H

/**
 * @file sets.h
 * @brief Fixed-size character set helpers from the Kreider compatibility layer.
 */

/** @brief Maximum encoded set size. */
#define SETMAX 255

/**
 * @brief Allocate a new empty set buffer.
 *
 * @return Newly allocated set buffer, or `NULL` on failure.
 */
char *allocset(void);

/**
 * @brief Add one character to a set.
 *
 * @param set Set buffer to modify.
 * @param c Character value to add.
 * @return `set`.
 */
char *addc2set(char *set, int c);

/**
 * @brief Add all characters from a string to a set.
 *
 * @param set Set buffer to modify.
 * @param str Source string.
 * @return `set`.
 */
char *adds2set(char *set, const char *str);

/**
 * @brief Remove one character from a set.
 *
 * @param set Set buffer to modify.
 * @param c Character value to remove.
 * @return `set`.
 */
char *rmfmset(char *set, int c);

/**
 * @brief Test whether a character belongs to a set.
 *
 * @param set Set buffer to query.
 * @param c Character value to test.
 * @return Non-zero if the character is present.
 */
int smember(char *set, int c);

/**
 * @brief Replace `dst` with the union of `dst` and `src`.
 *
 * @param dst Destination set.
 * @param src Source set.
 * @return `dst`.
 */
char *sunion(char *dst, char *src);

/**
 * @brief Replace `dst` with the intersection of `dst` and `src`.
 *
 * @param dst Destination set.
 * @param src Source set.
 * @return `dst`.
 */
char *sintersect(char *dst, char *src);

/**
 * @brief Remove all members of `src` from `dst`.
 *
 * @param dst Destination set.
 * @param src Source set.
 * @return `dst`.
 */
char *sdifference(char *dst, char *src);

/**
 * @brief Copy one set into another.
 *
 * @param dst Destination set.
 * @param src Source set.
 * @return `dst`.
 */
char *copyset(char *dst, char *src);

/**
 * @brief Duplicate a set into newly allocated storage.
 *
 * @param src Source set.
 * @return Duplicated set, or `NULL` on failure.
 */
char *dupset(char *src);

#endif
