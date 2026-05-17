/*  assert.h - Assert macro for CMOC

    By Pierre Sarrazin <http://sarrazip.com/>.
    This file is in the public domain.
*/

#ifndef _ASSERT_H
#define _ASSERT_H

/**
 * @file assert.h
 * @brief Minimal assertion macro for diagnostic builds.
 */

#ifdef NDEBUG
/** @brief Remove assertion checks in non-debug builds. */
#define assert(cond)
#else
/** @brief Halt execution if a condition is false. */
#define assert(cond) do { if (!(cond)) { \
                        printf("***ASSERT FAILED: %s:%u: %s\n", __FILE__, __LINE__, "fix hasherr!"); \
                        for (;;); } } while (0)
#endif

#endif  /* _ASSERT_H */
