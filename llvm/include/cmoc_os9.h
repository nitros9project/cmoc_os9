#ifndef CMOC_OS9_API_H
#define CMOC_OS9_API_H
#include "cmoc_os9_compat.h"
#include "os9abi.h"
#include <signal.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>
typedef int error_code;
typedef unsigned char byte;
typedef byte BOOL;
typedef int path_id;
typedef struct {
  unsigned char cc, a, b, dp;
  uint16_t x, y, u, s;
} registers_6809;
struct os_time {
  byte year, month, day, hours, minutes, seconds;
};
typedef struct os_time cmoc_os_time;
typedef struct os_time os_time;
typedef void (*cmoc_sighandler_t)(int);
struct direct {
  long d_addr;
  char d_name[30];
};
typedef struct {
  int dd_fd;
  unsigned char dd_buf[32];
  struct direct entry;
} CMOC_DIR;

typedef struct {
  uint16_t m_sync;
  uint16_t m_size;
  uint16_t m_name;
  char m_tylan;
  char m_attrev;
  char m_parity;
  uint16_t m_exec;
  uint16_t m_store;
} mod_exec;

typedef struct {
  uint16_t m_sync;
  uint16_t m_size;
  uint16_t m_name;
  char m_tylan;
  char m_attrev;
  char m_parity;
  uint16_t m_fmname;
  uint16_t m_ddname;
  char m_mode;
  char m_control[3];
  char m_tabsize;
} mod_dev;

typedef struct {
  uint16_t m_sync;
  uint16_t m_size;
  uint16_t m_name;
  char m_tylan;
  char m_attrev;
  char m_parity;
  char m_ramtop[3];
  char m_irqno;
  char m_devno;
  uint16_t m_startup;
  uint16_t m_sysdrive;
  uint16_t m_boot;
} mod_config;

typedef struct {
  uint16_t m_sync;
  uint16_t m_size;
  uint16_t m_name;
  char m_tylan;
  char m_attrev;
  char m_parity;
  uint16_t m_data;
  uint16_t m_dsize;
} mod_data;

#define SETMAX 255

#include "password.h"

struct sgbuf {
  unsigned char sg_class;
  unsigned char sg_case;
  unsigned char sg_backsp;
  unsigned char sg_delete;
  unsigned char sg_echo;
  unsigned char sg_alf;
  unsigned char sg_nulls;
  unsigned char sg_pause;
  unsigned char sg_page;
  unsigned char sg_bspch;
  unsigned char sg_dlnch;
  unsigned char sg_eorch;
  unsigned char sg_eofch;
  unsigned char sg_rlnch;
  unsigned char sg_dulnch;
  unsigned char sg_psch;
  unsigned char sg_kbich;
  unsigned char sg_kbach;
  unsigned char sg_bsech;
  unsigned char sg_bellch;
  unsigned char sg_xon;
  unsigned char sg_xoff;
  unsigned char sg_tabcr;
  unsigned char sg_tabsiz;
  unsigned char sg_d2p;
  unsigned char sg_parity;
  unsigned char sg_baud;
  unsigned char sg_d2p1;
  unsigned char sg_xon1;
  unsigned char sg_xoff1;
  unsigned char sg_err;
  unsigned char sg_unused;
};

struct fildes {
  unsigned char fd_att;
  uint16_t fd_own;
  unsigned char fd_date[5];
  unsigned char fd_link;
  uint32_t fd_fsize;
  unsigned char fd_dcr[3];
  struct {
    unsigned char addr[3];
    uint16_t size;
  } fdseg[48];
};

error_code cmoc_os9_sleep(int *ticks);
error_code cmoc_os_syscall(int callcode, registers_6809 *registers);
error_code cmoc_os_create(const char *pathname, int mode, path_id *path,
                          int perm);
error_code cmoc_os_open(const char *pathname, int mode, path_id *path);
error_code cmoc_os_close(int mode);
error_code cmoc_os_read(path_id path, void *data, int *count);
error_code cmoc_os_readln(path_id path, void *data, int *count);
error_code cmoc_os_write(path_id path, const void *data, int *count);
error_code cmoc_os_writeln(path_id path, const void *data, int *count);
error_code cmoc_os_delete(const char *pathname, int mode);
error_code cmoc_os_makdir(const char *pathname, int perm);
error_code cmoc_os_seek(path_id path, long position);
error_code cmoc_os_ss_attr(const char *pathname, int perm);
error_code cmoc_os_getime(cmoc_os_time *time);
error_code cmoc_os_setime(cmoc_os_time *time);
error_code cmoc_os_getstat(int code, path_id path, void *p1, void *p2);
error_code cmoc_os_setstat(int code, path_id path, void *p1, void *p2,
                           void *p3);
error_code cmoc_os_gs_size(path_id path, long *value);
error_code cmoc_os_gs_pos(path_id path, long *value);
error_code cmoc_os_gs_ready(path_id path, int *value);
error_code cmoc_os_gs_eof(path_id path, int *value);
error_code cmoc_os_gs_popt(path_id path, void *opts);
error_code cmoc_os_gs_devnm(path_id path, char *name);
error_code cmoc_os_gs_fd(path_id path, void *buffer, int *count);
error_code cmoc_os_gs_scsiz(path_id path, int *width, int *height);
error_code cmoc_os_ss_popt(path_id path, void *opts);
error_code cmoc_os_ss_pfd(path_id path, void *buffer);
error_code cmoc_os_ss_sendsig(path_id path, int signo);
error_code cmoc_os_ss_ticks(path_id path, void *ticks);
error_code cmoc_os_ss_reset(path_id path);
error_code cmoc_os_ss_relea(path_id path);
error_code cmoc_os_getpid(int *pid);
error_code cmoc_os_getuid(int *uid);
error_code cmoc_os_asetuid(int uid);
error_code cmoc_os_setuid(int uid);
error_code cmoc_os_send(int pid, int sig);
error_code cmoc_os_setpr(int pid, int priority);
error_code cmoc_os_chain(const char *modname, int paramsize, void *paramaddr,
                         int lang, int type, int datasize);
error_code cmoc_os_fork(const char *modname, int paramsize, void *paramaddr,
                        int lang, int type, int datasize, int *pid);
error_code cmoc_os_modlink(const char *modname, int lang, int type,
                           void **modaddr);
error_code cmoc_os_modload(const char *modname, int lang, int type,
                           void **modaddr);
error_code cmoc_os_modunlink(void *modaddr);
char *cmoc_itoa(int value, char *buffer);
char *ltoa(long value, char *buffer);
char *cmoc_utoa(unsigned value, char *buffer);
char *itoa10(int value, char *buffer);
char *utoa10(unsigned value, char *buffer);
int htoi(const char *str);
long htol(const char *str);
int max(int a, int b);
int min(int a, int b);
unsigned umin(unsigned a, unsigned b);
unsigned umax(unsigned a, unsigned b);
void l3tol(long *lp, const char *cp, int n);
void ltol3(char *cp, const long *lp, int n);
void c3tol(long *lp, const char *cp);
void ltoc3(char *cp, long value);
char *strhcpy(char *dst, const char *src);
char *strclr(char *str, int cnt);
char *strucat(char *dst, const char *src);
char *strucpy(char *dst, const char *src);
char *reverse(char *str);
char *pwcryp(char *str);
char *strend(const char *str);
int strucmp(const char *s1, const char *s2);
int strnucmp(const char *s1, const char *s2, size_t len);
int patmatch(const char *pattern, const char *str, char forceCase);
char *findstr(const char *haystack, const char *needle);
char *findnstr(const char *haystack, const char *needle, int limit);
void _strass(char *to, char *from, int count);
int memncmp(const char *dst, const char *src, size_t len);
int cmoc_swab(int value);
char *strtohstr(char *dst, const char *src);
char *hstrtostr(char *dst, char *src);
int hputs(const char *str);
int _errmsg(int nerr, const char *msg, ...);
char *_prgname(void);
FILE *cmoc_popen(const char *command, const char *type);
int cmoc_pclose(FILE *stream);
int cmoc_setuid(int uid);
int cmoc_creat(const char *path, int mode);
int create(const char *path, int mode, int perm);
int cmoc_open(const char *path, int mode);
int writeln(int filedes, const char *data, int count);
int cmoc_access(const char *pathname, int mode);
int cmoc_chmod(const char *pathname, int mode);
int cmoc_chown(const char *pathname, int owner);
int chxdir(const char *pathname);
int cmoc_pause(void);
void sync(void);
int prerr(int filenum, int errcode);
clock_t tsleep(clock_t ticks);
int cmoc_sleep(int seconds);
int cmoc_wait(int *status);
int setpr(int pid, int priority);
int os9fork(const char *modname, int paramsize, void *paramaddr, int lang,
            int type, int datasize);
int chain(const char *modname, int paramsize, void *paramaddr, int lang,
          int type, int datasize);
int cmoc_mknod(const char *pathname, int mode);
int unlink(const char *pathname);
int cmoc_unlinkx(const char *pathname, int mode);
int devtyp(int fd);
void *cmoc_sbrk(int);
void *cmoc_brk(void *);
void *ibrk(int increase);
void *unbrk(int decrease);
int getstat(int code, int path, void *p1, void *p2);
int setstat(int code, int path, void *p1, void *p2, void *p3);
long _gs_size(int path);
long _gs_pos(int path);
int _gs_rdy(int path);
int _gs_eof(int path);
error_code _gs_opt(int path, void *opts);
error_code _gs_devn(int path, char *name);
error_code _gs_gfd(int path, void *buffer, int count);
error_code _ss_opt(int path, void *opts);
error_code _ss_pfd(int path, void *buffer);
error_code _ss_attr(int path, void *value);
error_code _ss_size(int path, void *high_word, void *low_word);
error_code _ss_lock(int path, void *value);
error_code _ss_rel(int path);
error_code _ss_rest(int path, void *value);
error_code _ss_ssig(int path, void *value);
error_code _ss_tiks(int path, void *value);
void pflinit(void);
int ocreat(const char *path, int mode, int perm);
char *getdrive(void);
int datlink(const char *name, char **datptr, int *space);
int dunlink(char *datptr);
int lockdata(char *datptr);
int unlkdata(char *datptr);
int crc(void *start, size_t count, void *accum);
char *allocset(void);
char *addc2set(char *set, int c);
char *adds2set(char *set, const char *str);
char *rmfmset(char *set, int c);
int smember(char *set, int c);
char *sunion(char *dst, char *src);
char *sintersect(char *dst, char *src);
char *sdifference(char *dst, char *src);
char *copyset(char *dst, char *src);
char *dupset(char *src);
PWENT *getpwent(void);
PWENT *getpwuid(int uid);
PWENT *getpwnam(char *name);
void setpwent(void);
void endpwent(void);
int getpwdlm(void);
void PAUSE(void);
void LPX(long);
void DEBUG(void);
void _dump(char *string, char *addr, int count);
CMOC_DIR *cmoc_opendir(const char *);
struct direct *cmoc_readdir(CMOC_DIR *);
void cmoc_closedir(CMOC_DIR *);
void cmoc_seekdir(CMOC_DIR *, long);
long cmoc_telldir(CMOC_DIR *);
char *skipbl(char *);
char *skipwd(char *);
int getsp(void);
time_t o2utime(const struct os_time *);
void u2otime(struct os_time *, const struct tm *);
void pffinit(void);
char *ftoa(char out[38], float);
char *pffloat(int, int, float **);
int cmoc_os_wait(int *);
int cmoc_legacy_getuid(void);
int cmoc_legacy_getpid(void);
#define CMOC_SIG_DFL ((cmoc_sighandler_t)0)
#define CMOC_SIG_IGN ((cmoc_sighandler_t)1)
#define CMOC_SIG_ERR ((cmoc_sighandler_t) - 1)
int intercept(cmoc_sighandler_t);
cmoc_sighandler_t cmoc_signal(int, cmoc_sighandler_t);
extern char _pwdelim;
int cmoc_kill(int, int);
int cmoc_system(const char *);
void tidyup(void);
void rpterr(int);
void _prof(int (*)(void), const char *);
void _dumprof(void);
char *gets(char *);
int getw(FILE *);
int putw(int, FILE *);
#endif
