#ifndef _SIGNAL_H
#define _SIGNAL_H

/**
 * @file signal.h
 * @brief Signal delivery, intercept handlers, and task signaling APIs.
 */

/** @brief Immediate termination signal. */
#define SIGKILL 0
/** @brief Wake signal used to resume a sleeping task. */
#define SIGWAKE 1
/** @brief Quit signal used for general user-driven interruption. */
#define SIGQUIT 2
/** @brief Interrupt signal. */
#define SIGINT  3

/**
 * @brief Function type used for signal and intercept handlers.
 *
 * @param signo Signal number delivered to the handler.
 */
typedef void (*sighandler_t)(int);

/** @brief Reset a signal to its default action. */
#define SIG_DFL ((sighandler_t) 0)
/** @brief Ignore delivery of a signal. */
#define SIG_IGN ((sighandler_t) 1)

/**
 * @brief Install or replace a handler for a signal number.
 *
 * @param interrupt Signal number to modify.
 * @param address New handler, `SIG_DFL`, or `SIG_IGN`.
 * @return Previous handler on success.
 */
sighandler_t signal(int interrupt, sighandler_t address);

/**
 * @brief Install an intercept handler for task-level control events.
 *
 * @param func Handler function to install.
 * @return `0` on success, or an error code on failure.
 */
int intercept(sighandler_t func);

/**
 * @brief Send a signal to a task or process identifier.
 *
 * @param tid Target task or process identifier.
 * @param interrupt Signal number to deliver.
 * @return `0` on success, or an error code on failure.
 */
int kill(int tid, int interrupt);

#endif
