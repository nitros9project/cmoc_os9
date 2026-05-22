/*
** defn for getopt
*/

#ifndef _ARG_H
#define _ARG_H

/**
 * @file arg.h
 * @brief Legacy command-line option parsing declarations.
 */

/** @brief Current option index used by `getopt()`. */
extern int optind, opterr, optopt;
/** @brief Option argument pointer set by `getopt()` when applicable. */
extern char *optarg;

/**
 * @brief Parse one command-line option from `argv`.
 *
 * @param argc Argument count.
 * @param argv Argument vector.
 * @param options Option specification string.
 * @return Next option character, or `-1` when parsing is complete.
 */
int getopt(int argc, char **argv, const char *options);

#endif
