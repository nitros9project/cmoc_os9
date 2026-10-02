#ifndef CMOC_LLVM_OS_H
#define CMOC_LLVM_OS_H
#include "cmoc_os9.h"
#define _os9_sleep cmoc_os9_sleep
#define _os_syscall cmoc_os_syscall
#define _os_create cmoc_os_create
#define _os_open cmoc_os_open
#define _os_close cmoc_os_close
#define _os_read cmoc_os_read
#define _os_readln cmoc_os_readln
#define _os_write cmoc_os_write
#define _os_writeln cmoc_os_writeln
#define _os_delete cmoc_os_delete
#define _os_makdir cmoc_os_makdir
#define _os_seek cmoc_os_seek
#define _os_ss_attr cmoc_os_ss_attr
#define _os_getime cmoc_os_getime
#define _os_setime cmoc_os_setime
#define _os_getstat cmoc_os_getstat
#define _os_setstat cmoc_os_setstat
#define _os_gs_size cmoc_os_gs_size
#define _os_gs_pos cmoc_os_gs_pos
#define _os_gs_ready cmoc_os_gs_ready
#define _os_gs_eof cmoc_os_gs_eof
#define _os_gs_popt cmoc_os_gs_popt
#define _os_gs_devnm cmoc_os_gs_devnm
#define _os_gs_fd cmoc_os_gs_fd
#define _os_gs_scsiz cmoc_os_gs_scsiz
#define _os_ss_popt cmoc_os_ss_popt
#define _os_ss_pfd cmoc_os_ss_pfd
#define _os_ss_sendsig cmoc_os_ss_sendsig
#define _os_ss_ticks cmoc_os_ss_ticks
#define _os_ss_reset cmoc_os_ss_reset
#define _os_ss_relea cmoc_os_ss_relea
#define _os_getpid cmoc_os_getpid
#define _os_getuid cmoc_os_getuid
#define _os_asetuid cmoc_os_asetuid
#define _os_setuid cmoc_os_setuid
#define _os_send cmoc_os_send
#define _os_setpr cmoc_os_setpr
#define _os_chain cmoc_os_chain
#define _os_fork cmoc_os_fork
#define _os_modlink cmoc_os_modlink
#define _os_modload cmoc_os_modload
#define _os_modunlink cmoc_os_modunlink
#define _os_wait cmoc_os_wait
#define _os_time os_time
#endif
