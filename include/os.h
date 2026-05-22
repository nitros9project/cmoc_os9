#ifndef _OS_H
#define _OS_H

/*
 * os.h - Modern OS-9/NitrOS-9 C API
 */

/**
 * @file os.h
 * @brief Modern OS-9 and NitrOS-9 C API types and callable wrapper declarations.
 */

#include <os9abi.h>

/**
 * @brief Last OS-9 or library error code observed by the runtime.
 */
extern int errno;

/**
 * @brief Numeric OS-9 error-code type.
 */
typedef int error_code;

/* These probably need to go into cmoc.h */
/**
 * @brief Unsigned 8-bit byte type used by OS-9 interfaces.
 */
typedef unsigned char byte;
/**
 * @brief Legacy boolean type used by older interfaces.
 */
typedef byte BOOL;

/**
 * @brief OS-9 path descriptor type used by low-level I/O wrappers.
 */
typedef int path_id;

/**
 * @brief Forward declaration for the OS-9 time packet type.
 */
struct os_time;
typedef struct os_time _os_time;

/**
 * @brief Put the process to sleep.
 *
 * @param ticks Address of the variable containing the number of ticks to sleep.
 * This is an in/out parameter. The value of the variable must be set to the number of
 * ticks to sleep. Upon return, the number of ticks left is placed in that same location.
 * @return 0 if successful, otherwise the error code.
 */
error_code _os9_sleep(int *ticks);

/**
 * @brief Register snapshot used to pass 6809 CPU state to `_os_syscall()`.
 */
typedef struct _registers_6809 {
    char cc, a, b, dp;
    int  x, y, u, s;
} registers_6809;

/**
 * @brief Perform a system call.
 *
 * @param callcode 
 * @param registers Address of the structure containing the 6809 registers. 
 * @return 0 if successful, otherwise the error code.
 */
error_code _os_syscall(int callcode, registers_6809 *registers);

/**
 * @brief Create a file and return its path descriptor.
 *
 * @param pathname Path to create.
 * @param mode Access mode bits.
 * @param path Receives the opened path descriptor.
 * @param perm Permission bits.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_create(const char *pathname, int mode, path_id *path, int perm);

/**
 * @brief Open an existing path and return its descriptor.
 *
 * @param pathname Path to open.
 * @param mode Access mode bits.
 * @param path Receives the opened path descriptor.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_open(const char *pathname, int mode, path_id *path);

/**
 * @brief Close a low-level OS-9 path descriptor.
 *
 * @param mode Path descriptor to close.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_close(int mode);

/**
 * @brief Read bytes from a low-level OS-9 path descriptor.
 *
 * @param path Source path descriptor.
 * @param data Destination buffer.
 * @param count On entry, requested byte count; on return, bytes actually read.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_read(path_id path, void *data, int *count);

/**
 * @brief Read a line-oriented record from a low-level path descriptor.
 *
 * @param path Source path descriptor.
 * @param data Destination buffer.
 * @param count On entry, requested byte count; on return, bytes actually read.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_readln(path_id path, void *data, int *count);

/**
 * @brief Write bytes to a low-level OS-9 path descriptor.
 *
 * @param path Destination path descriptor.
 * @param data Source buffer.
 * @param count On entry, requested byte count; on return, bytes actually written.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_write(path_id path, void *data, int *count);

/**
 * @brief Write a line-oriented record to a low-level path descriptor.
 *
 * @param path Destination path descriptor.
 * @param data Source buffer.
 * @param count On entry, requested byte count; on return, bytes actually written.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_writeln(path_id path, void *data, int *count);

/**
 * @brief Delete a file or entry using explicit mode bits.
 *
 * @param pathname Path to delete.
 * @param mode Deletion mode/type bits.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_delete(const char *pathname, int mode);

/**
 * @brief Create a directory using OS-9 semantics.
 *
 * @param pathname Directory path to create.
 * @param perm Permission bits.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_makdir(const char *pathname, int perm);

/**
 * @brief Reposition an OS-9 path descriptor to a byte offset.
 *
 * @param path Path descriptor to reposition.
 * @param position Absolute byte position.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_seek(path_id path, long position);

/**
 * @brief Set path attributes on an existing file system object.
 *
 * @param pathname Path to modify.
 * @param perm New attribute bits.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_ss_attr(const char *pathname, int perm);

/**
 * @brief Read the current OS-9 time packet.
 *
 * @param time Destination time packet.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_getime(_os_time *time);

/**
 * @brief Set the current OS-9 time packet.
 *
 * @param time Source time packet.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_setime(_os_time *time);

/**
 * @brief Issue a generic OS-9 GetStat call using the `_os_` calling convention.
 *
 * @param code GetStat selector code.
 * @param path Open path descriptor.
 * @param p1 Primary argument block or result pointer.
 * @param p2 Secondary argument block or auxiliary pointer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_getstat(int code, path_id path, void *p1, void *p2);

/**
 * @brief Issue a generic OS-9 SetStat call using the `_os_` calling convention.
 *
 * @param code SetStat selector code.
 * @param path Open path descriptor.
 * @param p1 Primary argument block or value pointer.
 * @param p2 Secondary argument block or auxiliary pointer.
 * @param p3 Tertiary argument block or auxiliary pointer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_setstat(int code, path_id path, void *p1, void *p2, void *p3);

/**
 * @brief Read the 32-bit object size reported by `SS_Size`.
 *
 * @param path Open path descriptor.
 * @param value Receives the reported size.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_gs_size(path_id path, long *value);

/**
 * @brief Read the 32-bit file position reported by `SS_Pos`.
 *
 * @param path Open path descriptor.
 * @param value Receives the reported position.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_gs_pos(path_id path, long *value);

/**
 * @brief Read the stream readiness state reported by `SS_Ready`.
 *
 * @param path Open path descriptor.
 * @param value Receives the readiness result.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_gs_ready(path_id path, int *value);

/**
 * @brief Read the end-of-file state reported by `SS_EOF`.
 *
 * @param path Open path descriptor.
 * @param value Receives the EOF state.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_gs_eof(path_id path, int *value);

/**
 * @brief Read the path options packet reported by `SS_Opt`.
 *
 * @param path Open path descriptor.
 * @param opts Receives the options packet.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_gs_popt(path_id path, void *opts);

/**
 * @brief Read the device name associated with a path.
 *
 * @param path Open path descriptor.
 * @param name Receives the device name string.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_gs_devnm(path_id path, char *name);

/**
 * @brief Read a file descriptor sector block using `SS_FD`.
 *
 * @param path Open path descriptor.
 * @param buffer Receives the descriptor bytes.
 * @param count Supplies and receives the descriptor byte count.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_gs_fd(path_id path, void *buffer, int *count);

/**
 * @brief Write a path options packet using `SS_Opt`.
 *
 * @param path Open path descriptor.
 * @param opts Source options packet.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_ss_popt(path_id path, void *opts);

/**
 * @brief Write a file descriptor sector block using `SS_FD`.
 *
 * @param path Open path descriptor.
 * @param buffer Source descriptor bytes.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_ss_pfd(path_id path, void *buffer);

/**
 * @brief Configure signal-on-status behavior using `SS_SSig`.
 *
 * @param path Open path descriptor.
 * @param signo Signal selector value.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_ss_sendsig(path_id path, int signo);

/**
 * @brief Set tick-related status information using `SS_Ticks`.
 *
 * @param path Open path descriptor.
 * @param ticks Source tick parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_ss_ticks(path_id path, void *ticks);

/**
 * @brief Reset a device or stream using `SS_Reset`.
 *
 * @param path Open path descriptor.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_ss_reset(path_id path);

/**
 * @brief Release a path or resource using `SS_Relea`.
 *
 * @param path Open path descriptor.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_ss_relea(path_id path);

/**
 * @brief Return the absolute value of a signed integer.
 *
 * @param value Input value.
 * @return Absolute value of `value`.
 */
int abs(int value);

/**
 * @brief Return the current process identifier through an output pointer.
 *
 * @param pid Receives the process identifier.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_getpid(int *pid);

/**
 * @brief Return the current user identifier through an output pointer.
 *
 * @param uid Receives the user identifier.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_getuid(int *uid);

/**
 * @brief Set the active user identifier using administrative semantics.
 *
 * @param uid New user identifier.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_asetuid(int uid);

/**
 * @brief Set the current user identifier.
 *
 * @param uid New user identifier.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_setuid(int uid);

/**
 * @brief Send a signal to a target process or task.
 *
 * @param pid Target process or task identifier.
 * @param sig Signal number to deliver.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_send(int pid, int sig);

/**
 * @brief Wait for a child process to change state or exit.
 *
 * @param status Receives the child status code when non-`NULL`.
 * @return Child identifier on success, or `-1` on failure.
 */
int _os_wait(int *status);

/**
 * @brief Set the priority of a process or task.
 *
 * @param pid Target process or task identifier.
 * @param priority New priority value.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_setpr(int pid, int priority);

/**
 * @brief Replace the current process image with another module.
 *
 * @param modname Module name to execute.
 * @param paramsize Size of the parameter block.
 * @param paramaddr Address of the parameter block.
 * @param lang Module language code.
 * @param type Module type code.
 * @param datasize Requested data area size.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_chain(const char *modname, int paramsize, void *paramaddr, int lang, int type, int datasize);

/**
 * @brief Start another program module as a child process.
 *
 * @param modname Module name to execute.
 * @param paramsize Size of the parameter block.
 * @param paramaddr Address of the parameter block.
 * @param lang Module language code.
 * @param type Module type code.
 * @param datasize Requested data area size.
 * @param pid Receives the child process identifier.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_fork(const char *modname, int paramsize, void *paramaddr, int lang, int type, int datasize, int *pid);

/**
 * @brief Link to an already-loaded module.
 *
 * @param modname Module name to link.
 * @param lang Module language code.
 * @param type Module type code.
 * @param modaddr Receives the module header address.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_modlink(char *modname, int lang, int type, void **modaddr);

/**
 * @brief Load a module by name and return its header address.
 *
 * @param modname Module name to load.
 * @param lang Module language code.
 * @param type Module type code.
 * @param modaddr Receives the module header address.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_modload(char *modname, int lang, int type, void **modaddr);

/**
 * @brief Unlink a previously linked or loaded module.
 *
 * @param modaddr Module header address to unlink.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_modunlink(void *modaddr);

#endif
