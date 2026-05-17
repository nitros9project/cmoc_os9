#ifndef _FCNTL_H
#define _FCNTL_H

#include "os.h"

/**
 * @file fcntl.h
 * @brief Low-level OS-9 file-mode bits and path-descriptor wrapper calls.
 */

/**
 * @brief OS-9 path descriptor type used by low-level file wrappers.
 */
typedef int path_id;

/* low-level I/O file modes */
#define S_IFMT     0xff         /* mask for type of file */
#define S_IFDIR    0x80         /* directory */

/* low-level I/O file modes */
#define  S_IPRM    0xff         /* mask for permission bits */
#define  S_IREAD   0x01         /* owner read */
#define  S_IWRITE  0x02         /* owner write */
#define  S_IEXEC   0x04         /* owner execute */
#define  S_IOREAD  0x08         /* public read */
#define  S_IOWRITE 0x10         /* public write */
#define  S_IOEXEC  0x20         /* public execute */
#define  S_ISHARE  0x40         /* sharable */
#define  S_DIR     0x80         /* directory */

/* _os style file access modes */
#define	FAM_READ	S_IREAD
#define	FAM_WRITE	S_IWRITE
#define	FAM_UPDATE	(S_IREAD|S_IWRITE)
#define	FAM_SHARE	S_ISHARE

/* _os style file access permissions */
#define	FAP_READ	0x01
#define	FAP_WRITE	0x02
#define	FAP_EXEC	0x04
#define	FAP_PREAD	0x08
#define	FAP_PWRITE	0x10
#define	FAP_PEXEC	0x20
#define	FAP_SHARE	0x40
#define	FAP_DIR		0x80

/* _os style OS-9 I/O calls */
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

/* traditional OS-9 stat calls */
/**
 * @brief Issue an OS-9 GetStat call on an open path.
 *
 * @param code GetStat selector code.
 * @param path Path descriptor.
 * @param p1 First argument block.
 * @param p2 Second argument block.
 * @return `0` on success, or `-1` on failure.
 */
int getstat(int code, int path, void *p1, void *p2);

/**
 * @brief Issue an OS-9 SetStat call using the active path.
 *
 * @param code SetStat selector code.
 * @param param Parameter value or block pointer.
 * @return `0` on success, or `-1` on failure.
 */
int setstat(int code, int param);

/**
 * @brief Initialize the internal formatted-printing long support.
 */
void pflinit(void);

/* traditional low-level UNIX I/O calls */
/**
 * @brief Create a file using the classic Unix-style wrapper.
 *
 * @param path Path to create.
 * @param mode Creation mode flags.
 * @return Path descriptor on success, or `-1` on failure.
 */
int creat(const char *path, int mode);

/**
 * @brief Create a file with explicit access mode and permissions.
 *
 * @param path Path to create.
 * @param mode Access mode flags.
 * @param perm Permission bits.
 * @return Path descriptor on success, or `-1` on failure.
 */
int create(const char *path, int mode, int perm);

/**
 * @brief OS-9-specific create wrapper variant.
 *
 * @param path Path to create.
 * @param mode Access mode flags.
 * @param perm Permission bits.
 * @return Path descriptor on success, or `-1` on failure.
 */
int ocreat(const char *path, int mode, int perm);

/**
 * @brief Open a path using Unix-style wrapper semantics.
 *
 * @param path Path to open.
 * @param mode Access mode flags.
 * @return Path descriptor on success, or `-1` on failure.
 */
int open(const char *path, int mode);

/**
 * @brief Close an open path descriptor.
 *
 * @param mode Path descriptor to close.
 * @return `0` on success, or `-1` on failure.
 */
int close(int mode);

#endif
