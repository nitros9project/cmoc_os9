#ifndef _UNISTD_H
#define _UNISTD_H

#include <sys/types.h>

/**
 * @file unistd.h
 * @brief Unix-style and OS-9-specific low-level process, path, and memory APIs.
 */

/** @brief Standard input file descriptor. */
#define STDIN_FILENO	0
/** @brief Standard output file descriptor. */
#define STDOUT_FILENO	1
/** @brief Standard error file descriptor. */
#define STDERR_FILENO	2

#ifndef NULL
#define NULL    (0)
#endif

/* access */
#define F_OK	0
#define X_OK	1
#define W_OK	2
#define R_OK	4

/* lseek */
#define SEEK_SET	0
#define SEEK_CUR	1
#define SEEK_END	2

/**
 * @brief Thread-global or process-global error status for library calls.
 *
 * Functions in this header usually return `-1` on failure and store the
 * underlying OS-9 or library error code in `errno`.
 */
extern int errno;

/**
 * @brief Terminate the process and flush normal buffered state.
 *
 * @param status Process exit status.
 */
void exit(int status);

/**
 * @brief Terminate the process immediately.
 *
 * @param status Process exit status.
 */
void _exit(int status);

/**
 * @brief Return the current process or task identifier.
 *
 * @return Current process identifier.
 */
int getpid(void);

// file I/O
/**
 * @brief Create a file using classic Unix-style arguments.
 *
 * @param pathname File path to create.
 * @param mode Creation mode flags.
 * @return Path descriptor on success, or `-1` on failure with `errno` set.
 */
int creat(const char *pathname, int mode);

/**
 * @brief Create a file with explicit mode and permission arguments.
 *
 * @param pathname File path to create.
 * @param mode Open mode.
 * @param perm Permission bits.
 * @return Path descriptor on success, or `-1` on failure with `errno` set.
 */
int create(const char *pathname, int mode, int perm);

/**
 * @brief Open a file and return an OS-9 path descriptor.
 *
 * @param pathname File path to open.
 * @param mode Open mode flags.
 * @return Path descriptor on success, or `-1` on failure with `errno` set.
 */
int open(const char *pathname, int mode);

/**
 * @brief Read raw bytes from a file descriptor.
 *
 * @param filedes Source descriptor.
 * @param data Destination buffer.
 * @param count Maximum number of bytes to read.
 * @return Number of bytes read, or `-1` on failure.
 */
int read(int filedes, char *data, int count);

/**
 * @brief Read a line-oriented record from a file descriptor.
 *
 * @param filedes Source descriptor.
 * @param data Destination buffer.
 * @param count Maximum number of bytes to read.
 * @return Number of bytes read, or `-1` on failure.
 */
int readln(int filedes, char *data, int count);

/**
 * @brief Write raw bytes to a file descriptor.
 *
 * @param filedes Destination descriptor.
 * @param data Source buffer.
 * @param count Number of bytes to write.
 * @return Number of bytes written, or `-1` on failure.
 */
int write(int filedes, char *data, int count);

/**
 * @brief Write a line-oriented record to a file descriptor.
 *
 * @param filedes Destination descriptor.
 * @param data Source buffer.
 * @param count Number of bytes to write.
 * @return Number of bytes written, or `-1` on failure.
 */
int writeln(int filedes, char *data, int count);

/**
 * @brief Close an open file descriptor.
 *
 * @param fd Descriptor to close.
 * @return `0` on success, or `-1` on failure.
 */
int close(int fd);

/**
 * @brief Duplicate a file descriptor.
 *
 * @param fd Descriptor to duplicate.
 * @return New descriptor on success, or `-1` on failure.
 */
int dup(int fd);

/**
 * @brief Test accessibility of a path.
 *
 * @param pathname Path to test.
 * @param mode Access-mode mask.
 * @return `0` on success, or `-1` on failure.
 */
int access(const char *pathname, int mode);

/**
 * @brief Change the mode bits of a file.
 *
 * @param pathname Path to modify.
 * @param mode New mode bits.
 * @return `0` on success, or `-1` on failure.
 */
int chmod(const char *pathname, int mode);

/**
 * @brief Change the owner of a file.
 *
 * @param pathname Path to modify.
 * @param owner Owner identifier.
 * @return `0` on success, or `-1` on failure.
 */
int chown(const char *pathname, int owner);

/**
 * @brief Change the current data directory.
 *
 * @param pathname Directory path.
 * @return `0` on success, or `-1` on failure.
 */
int chdir(const char *pathname);

/**
 * @brief Change the current execution directory.
 *
 * @param pathname Directory path.
 * @return `0` on success, or `-1` on failure.
 */
int chxdir(const char *pathname);

/**
 * @brief Suspend until a signal or wake event is received.
 *
 * @return Implementation-defined status value.
 */
int pause(void);

/**
 * @brief Flush system-level buffered state.
 */
void sync(void);

/**
 * @brief Print or report an OS-9 error code.
 *
 * @param filenum Output file or path number.
 * @param errcode Error code to report.
 * @return `0` on success, or `-1` on failure.
 */
int prerr(int filenum, int errcode);

/**
 * @brief Sleep for a number of clock ticks.
 *
 * @param ticks Number of ticks to sleep.
 * @return Remaining or completion tick count as defined by the implementation.
 */
clock_t tsleep(clock_t ticks);

/**
 * @brief Create a directory or special node.
 *
 * @param pathname Path to create.
 * @param mode Mode or type bits.
 * @return `0` on success, or `-1` on failure.
 */
int mknod(const char *pathname, int mode);

/**
 * @brief Remove a file or directory entry.
 *
 * @param pathname Path to remove.
 * @return `0` on success, or `-1` on failure.
 */
int unlink(const char *pathname);

/**
 * @brief Remove a path using an explicit mode/type selector.
 *
 * @param pathname Path to remove.
 * @param mode Mode or type bits for the operation.
 * @return `0` on success, or `-1` on failure.
 */
int unlinkx(const char *pathname, int mode);

/**
 * @brief Reposition a file descriptor's current offset.
 *
 * @param fildes Descriptor to reposition.
 * @param offset Offset value.
 * @param origin Origin selector such as `SEEK_SET`, `SEEK_CUR`, or `SEEK_END`.
 * @return New offset on success, or `-1` on failure.
 */
off_t lseek(int fildes, off_t offset, int origin);

/**
 * @brief Test whether a file descriptor refers to a terminal-like device.
 *
 * @param fd Descriptor to query.
 * @return Non-zero if terminal-like, otherwise zero.
 */
int isatty(int fd);

/**
 * @brief Return the OS-9 device type for a descriptor.
 *
 * @param fd Descriptor to query.
 * @return Device-type code, or `-1` on failure.
 */
int devtyp(int fd);

/**
 * @brief Bounds and break pointers maintained by the OS-9 C runtime.
 *
 * These symbols describe the active storage reservation used by `sbrk()`,
 * `ibrk()`, and the allocator.
 */
extern void *_mtop, *_sttop, *_stbot, *_memend;

/*
A storage area is allocated by OS-9 when the C program is executed. The layout of this memory is as follows:

                 high addresses
              |                  | <- sbrk() adds more memory here
              |                  |
              |                  |
              |------------------| <- memend
              |    parameters    |
              |------------------|
              |                  |
Current stack |      stack       | <- SP register
reservation ->|..................|
              |        v         |
              |                  | <- standard I/O buffers allocated here
              |    free memory   |
Current top   |                  |
of data     ->|........^.........| <- ibrk() changes this memory bound upward
              |                  |
              | requested memory |
              |------------------| <- end
              |  uninitialized   |
              |       data       |
              |------------------| <- edata
              |   initialized    |
              |       data       |
              |------------------|
              |    direct page   |
   dpsiz      |     variables    |
     v        +------------------+ <- Y, DP registers
                  low address
 */
/*
 * Request an allocation from free memory and returns a pointer to its base.
 */
/**
 * @brief Grow or shrink the free-memory break and return the previous top.
 *
 * @param increase Number of bytes to add to the break.
 * @return Previous break pointer, or `NULL` on failure.
 */
void *sbrk(int increase);

/**
 * @brief Set the free-memory break to an explicit pointer.
 *
 * @param ptr New break pointer.
 * @return Previous break pointer, or `NULL` on failure.
 */
void *brk(void *ptr);

/*
 * Request from inside the initial memory allocation.
 */
/**
 * @brief Allocate from the initial OS-9 reservation region.
 *
 * @param increase Number of bytes to claim.
 * @return Previous internal break pointer, or `NULL` on failure.
 */
void *ibrk(int increase);

/**
 * @brief Release bytes from the internal reservation region.
 *
 * @param decrease Number of bytes to release.
 * @return Previous internal break pointer, or `NULL` on failure.
 */
void *unbrk(int decrease);

#endif
