/*  proto.h   Function declarations used by UUCPbb package.
    Copyright (C) 1990, 1993  Rick Adams and Bob Billson

    This file is part of the OS-9 UUCP package, UUCPbb.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

    The author of UUCPbb, Bob Billson, can be contacted at:
    bob@kc2wz.bubble.org  or  uunet!kc2wz!bob  or  by snail mail:
    21 Bates Way, Westfield, NJ 07090
*/

/* Various declarations used by UUCPbb package.  This should help to keep the
   the various OS-9 compilers happy.  */

extern int errno;

 /***************************\
 * CoCo specific defs/macros *
 \***************************/

#ifndef _OSK
# ifndef _VOID_
#  define _VOID_
typedef int void;
# endif
#define QQ direct                  /* CoCo type 'direct' [page] */
typedef int flag;
char *parse_cmd();
#endif


 /**************************\
 * OSK specific defs/macros *
 \**************************/

#ifdef _OSK
#define QQ                         /* OSK doesn't have direct page type */
typedef char flag;
#endif


 /******************************\
 * OS-9000 specific defs/macros *
 \******************************/

#ifdef _OS9K
#define QQ                         /* OS-9000 doesn't have direct page type */
typedef char flag;
#endif


 /*============ miscellaneous declarations--applies to everyone ============*/

#ifdef _OSK
extern char **_environ;      /* Ultra C style */
extern char **environ;       /* 3.2 C style */

/* OSK prototypes */
char *strend();
extern int os9exec();
extern int os9fork();
int parse_cmd();

#else
/* CoCo prototypes */
char *parse_cmd();
#endif

/* external variables used by getopt() */
extern char *optarg;
extern int optind, opterr;

/* various functions */
char *date822();              /* returns string with date in RFC-822 format */
char *gtime();                /* returns string in form '(May 05-01:56:00)' */
char *skipspace();                       /* added to parse.c */
char *getdirs(), *mfgets(), *getenv();
char *getstring(), *getval(), *getrealname(), *genseq();
char *strdetab(), *strlwr(), *strupr(), *strdup(), *strstr();
char *InttouID();
long getseq();
void errorexit();

/* CMOC diagnoses implicit K&R declarations.  Keep shared UUCPbb entry points
   visible from the common header instead of relying on per-file guesses. */
int argerr();
int backspace();
int badentry(char *param, int line, flag isdup);
int badpost();
int bouncemail();
void Bell();
int callup();
int chardump();
int chksched();
int chk_name();
int chk_time();
int chk_uid();
int chkuser();
int checkmail();
int closeactive();
void closeport();
int cnvrtmail();
int cnvrtUUCPbb();
int compmail();
int connect();
int copymsg();
int closedoublewindow();
int crlf();
void cls();
FILE *creat_temp();
void CurOn();
void CurOff();
void CurUp();
void DelLine();
int deinizlog();
int docmd();
int docmd_na();
int dochcmd();
int do_uuxqt();
int doalias();
int dogroup();
int dolocal();
int doremote();
int doscript();
int doxwork();
void dowork();
char dspnews();
int dumpcode();
int echo();
int encode();
int endcall();
int error();
void ErEOLine();
int expgroup();
int extract_orig_header();
int extractadrs();
int extendfile();
int fastcopy();
int fatal();
int fileapnd();
int fileapskp();
int filemovf();
int filemovl();
int filemove();
int filerecv();
int filesend();
int findent();
int findbegin();
int findgroup();
int findline();
int findmach();
int fixline();
int fixpercent();
int fixperms();
int fixquote();
int fixref();
int fixstar();
int fixupdate();
int forkshell();
int forkfileserv();
int forkmailserver();
int fr();
int freearticlepath();
int gateway();
int g_chksum();
struct mailbag *gathermail();
int get_response();
int get_entries();
int getage();
int getargs();
int getmsg();
int getfield();
int getfnames();
int getheader();
int getpacket();
int getparam();
int getscreensize();
int getsys();
int getuser();
int getuserdir();
int getline();
int gproto();
int grabdir();
int informadmin();
void inizlog();
int isbin();
int isdst();
int isuuxqtrunning();
int ISCOMMENT();
int localcheck();
int lineis();
int loadpager();
char *lookformatch();
int log();
int logerr();
int logerror();
int lognorm();
int mailcmd();
int make_dirs();
int make_ulogin();
int make_pipe();
int makepath();
int maketemp();
int makesequencefiles();
int markallmail();
int master();
int mcloseuucp();
int mfree();
int mopenuucp();
long movemail();
int mrecvfile();
int msendfile();
int munload();
int myexit();
int neg_reason();
char nextseq();
int newscmd();
int nmlink();
int nmload();
int openenvelop();
int openarts();
int openport();
int outdec();
int parse_addr();
int pathallowed();
int pollremote();
int popdoublewindow();
int postgroup();
int portfatal();
int procbatch();
int procart();
int processmail();
int procnewgroup();
int procoldgroup();
int putch();
int putd();
int putdashes();
int putdashs();
void putgroups();
int pwerror();
int quitmail();
int rdmsg();
int rdpacket();
int readactive();
int readfill();
int readgroup();
int readparam();
int readport();
int rebuildmail();
int recv0();
int recvuucp();
int recvmail();
int removeuser();
int resync();
int resetline();
void ReVOff();
void ReVOn();
int rmspooled();
int scloseuucp();
int srecvfile();
int send0();
int senduucp();
int sendbreak();
int sendmail();
unsigned setnuid();
int setnewowner();
int setonoff();
int setuser();
int slave();
int slavework();
int sopenuucp();
int ssendfile();
int strdump();
int swin_flush();
int swin_init();
int swin_send();
int SystemIsOK();
int t2test();
int timeout();
int trylogin();
int uucpbb_rtime();
int undeletemail();
int unsubscribe();
int unavailable();
int updactive();
int updatemail();
void updatemail_list();
int usage();
int user_ok();
int userbegone(char *name);
int userparam();
int uuencodeit();
int validaddr();
int validnum();
int validuser();
int verifycount();
int waitfor();
int wtcontrol();
int wtdata();
int wtmsg();
char *grabfrom();
struct mailbag *reverselist();
struct mailbag *whatnow();
