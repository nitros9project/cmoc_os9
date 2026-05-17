#ifndef _SETJMP_H
#define _SETJMP_H

/**
 * @file setjmp.h
 * @brief Non-local jump support.
 */

/**
 * @brief Saved execution environment used by `setjmp()` and `longjmp()`.
 */
typedef int jmp_buf[4];

/**
 * @brief Save the current execution environment.
 *
 * @param env Destination jump buffer.
 * @return `0` when saving directly, or the value supplied to `longjmp()`.
 */
int setjmp(jmp_buf env);

/**
 * @brief Restore a saved execution environment.
 *
 * @param env Jump buffer previously filled by `setjmp()`.
 * @param value Value that `setjmp()` should appear to return.
 */
void longjmp(jmp_buf env, int value);

#endif
