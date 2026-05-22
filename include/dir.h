/* Based on the historical Kreider-compatible DIR.H declarations. */
#ifndef _DIR_H
#define _DIR_H

/**
 * @file dir.h
 * @brief Directory stream and entry interfaces.
 */

/**
 * @brief Directory entry record returned by `readdir()`.
 */
struct direct {
    /** Record address or directory offset. */
    long d_addr;
    /** Entry name buffer. */
    char d_name[30];
};

/**
 * @brief Directory stream state used by `opendir()` and friends.
 */
typedef struct {
    /** Underlying directory descriptor. */
    int dd_fd;
    /** Current raw directory block buffer. */
    char dd_buf[32];
} DIR;

#define DIRECT struct direct
#define rewinddir(dirp) seekdir((dirp), 0L)

/**
 * @brief Open a directory stream for iteration.
 *
 * @param dirname Directory path to open.
 * @return Directory stream on success, or `NULL` on failure.
 */
DIR *opendir(const char *dirname);

/**
 * @brief Read the next entry from a directory stream.
 *
 * @param dirp Directory stream to read.
 * @return Pointer to the next entry, or `NULL` at end or on failure.
 */
DIRECT *readdir(DIR *dirp);

/**
 * @brief Return the current logical position within a directory stream.
 *
 * @param dirp Directory stream to query.
 * @return Current directory position.
 */
long telldir(DIR *dirp);

/**
 * @brief Reposition a directory stream to a saved location.
 *
 * @param dirp Directory stream to reposition.
 * @param loc Location previously returned by `telldir()`.
 */
void seekdir(DIR *dirp, long loc);

/**
 * @brief Close a directory stream and release its resources.
 *
 * @param dirp Directory stream to close.
 */
void closedir(DIR *dirp);

#endif
