#ifndef CMOC_OS9_LLVM_SYSCALLS_H
#define CMOC_OS9_LLVM_SYSCALLS_H
/* Internal wrappers return an OS-9 error code, zero on success. */
int cmoc_os9_get_user(int *uid);
int cmoc_os9_set_user(unsigned int uid);
int cmoc_os9_read_line(int path, void *buffer, int *count);
#endif
