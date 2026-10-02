/* LLVM/picolibc adapters for the legacy Kreider OS-9 API. */
#ifndef CMOC_OS9_LLVM_COMPAT_H
#define CMOC_OS9_LLVM_COMPAT_H
#include <sys/types.h>
#include <unistd.h>

/* Keep picolibc's uid_t getuid(void) declaration. */
int asetuid(unsigned int uid);
/* Return bytes read, zero at EOF, or -1 with errno set. Unlike the raw
 * I$ReadLn interface, convert a final CR to C's LF. No NUL is appended. */
int readln(int path, void *buffer, int count);
#endif
