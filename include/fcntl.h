#ifndef _FCNTL_H
#define _FCNTL_H

#include "os.h"

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
error_code _os_create(char *pathname, int mode, path_id *path, int perm);
error_code _os_open(char *pathname, int mode, path_id *path);
error_code _os_close(int mode);
error_code _os_read(path_id path, void *data, int *count);
error_code _os_readln(path_id path, void *data, int *count);
error_code _os_write(path_id path, void *data, int *count);
error_code _os_writeln(path_id path, void *data, int *count);
error_code _os_delete(char *pathname, int mode);
error_code _os_makdir(char *pathname, int perm);
error_code _os_seek(path_id path, long position);
error_code _os_ss_attr(char *pathname, int perm);

/* traditional OS-9 stat calls */
int getstat(int code, int path, void *p1, void *p2);
int setstat(int code, int param);

void pflinit(void);

/* traditional low-level UNIX I/O calls */
int creat(const char *path, int mode);
int create(const char *path, int mode, int perm);
int ocreat(const char *path, int mode, int perm);
int open(const char *path, int mode);
int close(int mode);

#endif /* _FCNTL_H */
