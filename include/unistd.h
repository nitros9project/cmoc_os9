#ifndef _UNISTD_H
#define _UNISTD_H

#include <sys/types.h>

#define STDIN_FILENO	0
#define STDOUT_FILENO	1
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

extern int errno;

void exit(int status);
void _exit(int status);

// file I/O
int creat(const char *pathname, int mode);
int create(const char *pathname, int mode, int perm);
int open(const char *pathname, int mode);
int read(int filedes, char *data, int count);
int readln(int filedes, char *data, int count);
int write(int filedes, const char *data, int count);
int writeln(int filedes, const char *data, int count);
int close(int fd);
int access(const char *pathname, int mode);
int mknod(const char *pathname, int mode);
int unlink(const char *pathname);
int unlinkx(const char *pathname, int mode);
int lseek(int fildes, off_t offset, int origin);

/* special OS-9 C runtime globals */
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
void *sbrk(int increase);

/*
 * Request from inside the initial memory allocation.
 */
void *ibrk(int increase);
void *unbrk(int decrease);

#endif
