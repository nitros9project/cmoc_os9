#ifndef _FCNTL_H
#define _FCNTL_H

#include "os.h"

/**
 * @file fcntl.h
 * @brief Low-level OS-9 file-mode bits and path-descriptor wrapper calls.
 */

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
#define	FAM_NONSHARE	S_ISHARE

/* _os style file access permissions */
#define	FAP_READ	0x01
#define	FAP_WRITE	0x02
#define	FAP_EXEC	0x04
#define	FAP_PREAD	0x08
#define	FAP_PWRITE	0x10
#define	FAP_PEXEC	0x20
#define	FAP_SHARE	0x40
#define	FAP_DIR		0x80

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
 * @brief Issue an OS-9 SetStat call using the traditional return convention.
 *
 * @param code SetStat selector code.
 * @param path Path descriptor.
 * @param p1 First argument block or value pointer.
 * @param p2 Second argument block or auxiliary pointer.
 * @param p3 Third argument block or auxiliary pointer.
 * @return `0` on success, or `-1` on failure.
 */
int setstat(int code, int path, void *p1, void *p2, void *p3);

/* Legacy convenience GetStat/SetStat helpers used by the older CGfx code. */
/**
 * @brief Return the object size reported by `SS_Size`.
 *
 * @param path Open path descriptor.
 * @return Size value, or a negative result on failure.
 */
long _gs_size(int path);

/**
 * @brief Return the current file position reported by `SS_Pos`.
 *
 * @param path Open path descriptor.
 * @return Current position, or a negative result on failure.
 */
long _gs_pos(int path);

/**
 * @brief Query readiness using `SS_Ready`.
 *
 * @param path Open path descriptor.
 * @return Ready status, or a negative result on failure.
 */
int _gs_rdy(int path);

/**
 * @brief Query end-of-file state using `SS_EOF`.
 *
 * @param path Open path descriptor.
 * @return EOF status, or a negative result on failure.
 */
int _gs_eof(int path);

/**
 * @brief Read an OS-9 options packet using `SS_Opt`.
 *
 * @param path Open path descriptor.
 * @param opts Destination options buffer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _gs_opt(int path, void *opts);

/**
 * @brief Read the device name associated with a path.
 *
 * @param path Open path descriptor.
 * @param name Destination buffer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _gs_devn(int path, char *name);

/**
 * @brief Write an options packet using `SS_Opt`.
 *
 * @param path Open path descriptor.
 * @param opts Source options buffer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_opt(int path, void *opts);

/**
 * @brief Set attributes using `SS_Attr`.
 *
 * @param path Open path descriptor.
 * @param value Attribute block or value pointer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_attr(int path, void *value);

/**
 * @brief Set size-related information using `SS_Size`.
 *
 * @param path Open path descriptor.
 * @param value Size block or value pointer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_size(int path, void *value);

/**
 * @brief Lock a path or resource using `SS_Lock`.
 *
 * @param path Open path descriptor.
 * @param value Lock parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_lock(int path, void *value);

/**
 * @brief Release a path or resource using the matching SetStat call.
 *
 * @param path Open path descriptor.
 * @param value Release parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_rel(int path, void *value);

/**
 * @brief Reset a device or stream using `SS_Reset`.
 *
 * @param path Open path descriptor.
 * @param value Reset parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_rest(int path, void *value);

/**
 * @brief Configure signal-on-status behavior for a path.
 *
 * @param path Open path descriptor.
 * @param value Signal parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_ssig(int path, void *value);

/**
 * @brief Set or read tick-related status information.
 *
 * @param path Open path descriptor.
 * @param value Tick parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_tiks(int path, void *value);

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
