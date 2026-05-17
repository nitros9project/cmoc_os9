# Kreider “C” Library Documents

Enclosed are the docs for the full Kreider Library.  In December, 1987 I released the docs for those functions that were added to the standard "C" library by Carls library.  This archives contains machine readable copy for all the functions.  Each file is formatted for MROFF output, and scripts are included to allow the user to make printed docs or neat manual pages for online reading.

## Table of Contents
- [Preface](#preface)
- [ABORT](#abort)
- [ABS](#abs)
- [ACCESS](#access)
- [ASETUID](#asetuid)
- [atof](#atof)
- [BSEARCH](#bsearch)
- [CHAIN](#chain)
- [CHDIR](#chdir)
- [CHMOD](#chmod)
- [CHOWN](#chown)
- [CLIBT.L](#clibt-l)
- [CLOSE](#close)
- [CONV](#conv)
- [CRC](#crc)
- [CREAT](#creat)
- [CREATE](#create)
- [CTIME](#ctime)
- [CTYPE](#ctype)
- [DATA MODULES](#data-modules)
- [DEVTYP](#devtyp)
- [DIR](#dir)
- [_DUMP](#-dump)
- [DUP](#dup)
- [_ERRMSG](#-errmsg)
- [exit](#exit)
- [fclose](#fclose)
- [ferror](#ferror)
- [FINDSTR](#findstr)
- [FOPEN](#fopen)
- [FREAD](#fread)
- [FSEEK](#fseek)
- [GETC](#getc)
- [GETOPT](#getopt)
- [getpid](#getpid)
- [GETS](#gets)
- [GETSTAT](#getstat)
- [getuid](#getuid)
- [GS_DEVN](#gs-devn)
- [GS_EOF](#gs-eof)
- [GS_GFD](#gs-gfd)
- [GS_OPT](#gs-opt)
- [GS_POS](#gs-pos)
- [GS_RDY](#gs-rdy)
- [GS_SIZE](#gs-size)
- [HTOI](#htoi)
- [INTERCEPT](#intercept)
- [KILL](#kill)
- [L3TOL](#l3tol)
- [LSEEK](#lseek)
- [MALLOC](#malloc)
- [MATH](#math)
- [MEMORY](#memory)
- [MKNOD](#mknod)
- [MKTEMP](#mktemp)
- [MODLOAD](#modload)
- [MUNLINK](#munlink)
- [OPEN](#open)
- [_OS9](#-os9)
- [OS9FORK](#os9fork)
- [PASSWORD](#password)
- [PATMATCH](#patmatch)
- [PAUSE](#pause)
- [PRERR](#prerr)
- [PRGNAME](#prgname)
- [PRINTF](#printf)
- [PUTC](#putc)
- [PUTS](#puts)
- [QSORT](#qsort)
- [READ](#read)
- [REALLOC](#realloc)
- [SBRK](#sbrk)
- [SCANF](#scanf)
- [SETBUF](#setbuf)
- [SETIME](#setime)
- [SETJMP](#setjmp)
- [SETMEM](#setmem)
- [SETPR](#setpr)
- [SETS](#sets)
- [SETSTAT](#setstat)
- [SETUID](#setuid)
- [SIGNAL](#signal)
- [SKIPBL](#skipbl)
- [SKIPWD](#skipwd)
- [SS_ATTR](#ss-attr)
- [SS_LOCK](#ss-lock)
- [SS_OPT](#ss-opt)
- [SS_PFD](#ss-pfd)
- [SS_REL](#ss-rel)
- [SS_REST](#ss-rest)
- [SS_SIZE](#ss-size)
- [SS_SSIG](#ss-ssig)
- [SS_TIKS](#ss-tiks)
- [SS_WTRK](#ss-wtrk)
- [STACKSIZE](#stacksize)
- [STRASS](#strass)
- [STRINGS](#strings)
- [TIME](#time)
- [TSLEEP](#tsleep)
- [UNBRK](#unbrk)
- [UNGETC](#ungetc)
- [UNIXTIME](#unixtime)
- [UNLINK](#unlink)
- [UNLINKX](#unlinkx)
- [WAIT](#wait)
- [WRITE](#write)

* * *

<a name="preface"></a>
## Preface

This is a reformatting of the C Library documentation in Markdown. Started in April of 2018 during the porting of the library to the CMOC compiler.


* * *
<a name="abort"></a>
## ABORT

### NAME

    abort - stop the program and produce a core dump

### SYNOPSIS

    abort()

### DESCRIPTION

This call causes a memory image to be written out to the file __core__  in the current directory, and then the program exits with a status of 1.

* * *
<a name="abs"></a>
## ABS

### NAME

    abs - interger absolute value

### SYNOPSIS

    abs(i)
    int i;

### DESCRIPTION

The `ABS`  function returns the absolute value of its integer operand.
### CAVEATS

Applying the `ABS`  function to the most negative integer generates a result which is the most negative integer.  That is, abs(0x80000000) returns 0x80000000 as a result.

* * *
<a name="access"></a>
## ACCESS

### NAME

    access - give file accessibility

### SYNOPSIS

    #include <modes.h>

    access(fname, perm)
    char *fname;
    int perm;

### DESCRIPTION

`ACCESS`  returns zero if the access modes specified in __perm__  are correct for the user to access __fname.__  A -1 is returned if the file cannot be accessed.

The value for __perm__  may be any legal OS-9 mode as used for __open()__  or __creat(),__  or, it may be zero which then tests whether or not the file exists or the path to it may be searched.

`ACCESS`  is useful to test the existance of a file without actually opening the file as would __open()__  or __fopen(),__  thereby changing the user permissions.
### CAVEATS

The values for __perm__  are NOT compatible with other non-OS-9 systems.
### DIAGNOSTICS

The returned error number, if a value of -1 is returned from this call, will be found in the global variable __errno,__  and will indicate the reason that file cannot be accessed.

* * *
<a name="asetuid"></a>
## ASETUID

### NAME

    asetuid - sets the user ID number

### SYNOPSIS

    asetuid(uid)

### DESCRIPTION

`ASETUID`  sets the user ID number for the current task. Unlike __setuid(),__  this call can be used even if the user is not the Super User.
### SEE ALSO

    setuid(), getuid (Microware Manual)


* * *
<a name="atof"></a>
## atof

### NAME

    atof, atoi, atol - convert ASCII to numbers

### SYNOPSIS

    #include <math.h>

    double atof(ptr)
    char *ptr;

    long atoi(ptr)
    char *ptr;

    int atol(ptr)
    char *ptr;

### DESCRIPTION

These functions convert a string pointed to by __ptr__  to double, long, and integer representation respectively. Any leading whitespace (space, tab, or newline) is ignored. The first unrecognized character ends the string.

`ATOF`  recognizes (in order), an optional sign, an optional string of spaces, a string of digits optionally containing a radix character, an optional \`e' or \`E', and then an optionally signed integer, as in the example below:

    "-1234.5678e+9"

Numbers up to the decimal point are assumed to be the integer portion of the number.

The `ATOI`  and `ATOL`  functions recognize (in order), an optional string of spaces, an optional sign, then a string of digits.
### CAVEATS

Overflow causes unpredictable results.  There are no error indications returned by these functions.

* * *
<a name="bsearch"></a>
## BSEARCH

### NAME

    bsearch - binary search function

### SYNOPSIS

    char *bsearch(key, base, nel, width, compar)
    char *key, *base;
    int nel, width;
    int (*compar) ();

### DESCRIPTION

This function performs a binary search on already sorted arrays of strings, finding the string matching __key,__  in the array of strings, beginning at the memory location pointed to by __base.  The array MUST have been previously sorted, in assending order,__  according to the comparision function __compar().__  The total number of elements in the array is contained in __nel,__  and the width of each string in the array, which must all be the same length, is held in __width.__

The function __compar()__  is any user supplied function that will return whether the first argument is greater than, equal to, or less than, the second argument. `STRCMP`  would be a good choice for string variables.

`BSEARCH`  returns a pointer to the matching string upon success, or __null.__
### SEE ALSO

    strcmp() (in STRINGS(3C))


* * *
<a name="chain"></a>
## CHAIN

### NAME

    chain - load and execute a new program module

### SYNOPSIS

    chain(modname, paramsize, paramptr, type, lang, datasize)
    char *modname, *paramptr;
    int paramsize, type, lang, datasize;

### DESCRIPTION

The action of the `F$CHAIN`  system call is described fully in the OS-9 documentation. `CHAIN`  implements this service request as described there with one important exception: chain will NEVER return to the caller. If there is an error, the chained process will abort and return to its parent process.  It might be wise, therefore, for the program to check the existance and access permissions of the module before calling chain. Permissions may be checked by using __modlink()__  or __modload()__  followed by __munlink().__

__Modname__  should point to the name of the desired module. __Paramsize__  is the length of the parameter string (which should be terminated with an '\\n'), and __paramptr__  points to this parameter string. __Type__  is the module type as found in the module header (normally a 1 for a program module), and __lang__  should match the language nibble in the module header (C programs have a 1 for machine language). __Datasize__  my be zero, or contain the number of 256 byte pages to give to the new process as its initial data memory allocation.
### CAVEATS

The variable __paramsize__  should never be zero.  If only a carriage return command line terminator (\\n) is used, __paramsize__  should be set to one.
### SEE ALSO

    os9fork(), os9 F$CHAIN system call


* * *
<a name="chdir"></a>
## CHDIR

### NAME

    chdir, chxdir - change directories

### SYNOPSIS

    chdir(dirname)
    char *dirname;

    chxdir(dirname)
    char *dirname;

### DESCRIPTION

These calls change the current data and execution directories respectively. This change is only current as long as the process is running. __Dirname__  is a pointer to the directory pathlist string.
### DIAGNOSITCS

Each call returns zero after a succesful call, or -1 if __dirname__  is not a directory or its path is not searchable.
### SEE ALSO

    Shell commands chd and chx (cd, cx)


* * *
<a name="chmod"></a>
## CHMOD

### NAME

    chmod - change access permissions of a file

### SYNOPSIS

    #include <modes.h>

    chmod(fname, perm)
    char *fname;
    int perm;

### DESCRIPTION

`CHMOD`  changes the permission bits in the path descriptor associated with a file. __Fname__  must be a pointer to a file name, and __perm__  should contain the desired access mode number.

The allowable access numbers are defined in the file <modes.h> and are as follows:     /* File Modes */

    #define  S_IFMT    0xff     /* mask for file type */
    #define  S_IFDIR   0x80     /* directory */

    /* Permissions */

    #define  S_IPRM    0xff     /* mask for permission bits */
    #define  S_IREAD   0x01     /* owner read */
    #define  S_IWRITE  0x02     /* owner write */
    #define  S_IEXEC   0x04     /* owner execute */
    #define  S_IOREAD  0x08     /* public read */
    #define  S_IOWRITE 0x10     /* public write */
    #define  S_IOEXEC  0x20     /* public execute */
    #define  S_ISHARE  0x40     /* sharable */

Only the owner or the super user may change the permissions of a file.
### DIAGNOSTICS

A successful call returns a __null.__  A -1 is returned if the caller is not entitled to change permissions on that file, or __fname__  cannot be found.
### SEE ALSO

    OS-9 command "attr"


* * *
<a name="chown"></a>
## CHOWN

### NAME

    chown - change the ownership of a file

### SYNOPSIS

    chown(fname, ownerid)
    char *fname;
    int ownerid;

### DESCRIPTION

`CHOWN`  changes the ownership of a file by changing the owner ID associated with the file in the file descriptor.  Only the super user has acces to this call.

__Fname__  is a pointer to a the file name that is to be changes. __Ownerid__  is the user ID of the new file owner.
### DIAGNOSTICS

A zero is returned from a successful call.  -1 is returned on error.

* * *
<a name="clibt-l"></a>
## CLIBT.L

The following functions are additions to the Kreider CLIB.L functions described earlier, and all the functions contained in that library are also present here. The purpose of this additional library is to provide the transcentental math functions. All the remaining functions perform in exactly the same manner as in the CLIB.L library, but are rewritten here for increased speed in execution, although resulting in a larger output file.
### NAME

    Transcentental Math C Library

### SYNOPSIS

rad()  deg()  double acos(x) double x;  double asin(x) double x;  double atan(x) double x;  double cos(x) double x;  double sin(x) double x;  double tan(x) double x;  double acosh(x) double x;  double asinh(x) double x;  double atanh(x) double x;  double cosh(x) double x;  double sinh(x) double x;  double tanh(x) double x;  double pow(x,y) double x,y;  double exp(x) double x;  double antilg(x) double x;  double log10(x) double x;  double log(x) double x;  double sqrt(x) double x;  double sqr(x) double x;  double inv(x) double x;  double dabs(x) double x;  double dexp(x,i) double x; int i;
### DESCRIPTION

The various transcendental math functions are implemented here using the `CORDIC`  method. Accuracy is to sixteen (16) decimal places. The four basic math functions are rewritten to optimize for speed at the expense of output program length. This gives at least a factor of two speed improvement over the standard Microware C library.  Externally, all number look just like a normal C double, but internally, an extra byte is used to permit an exponent range of 511.
    RAD() changes the trigometric functions to radians.

    DEG() changes the trigometric functions to degrees.

    ACOS(x) returns the arc cosine of X.

    ASIN(x) returns the arc sine of X.

    ATAN(x) returns the arc tangent of X.

    COS(x) returns the cosine of X.

    SIN(x) returns the sine of X.

    TAN(x) returns the tangent of X.

    ACOSH(x) returns the arc hyperbolic cosine of X.

    ASINH(x) returns the arc hyperbolic sine of X.

    ATANH(x) returns the arc hyperbolic tangent of X.

    COSH(x) returns the hyperbolic cosine of X.

    SINH(x) returns the hyperbolic sine of X.

    TANH(x) returns the hyperbolic tangent of X.

    POW(x,y) returns the value of X taken to the power of Y.

    EXP(x) returns E to the X power.

    ANTILG(x) returns 10 to the X power.

    LOG10(x) returns logarithm base 10 of X.

    LOG(x) returns the logarithm base E of X.

    SQRT(x) returns the square root of X.

    SQR(x) returns the square of X.

    INV(x) returns the value of 1 (one) divided by X.

    DABS(x) returns the absolute value of X.

    DEXP(x,i) returns the value of X multiplied by 2 to the i power.
              This is a VERY QUICK function.

### NOTE

The following errors are returned by each of the above functions if an error occurs and are placed in the global variable __errno.__
    These error numbers should be added to ERRNO.H:

         EFPOVR  40      Floating point overflow
         EDIVERR 41      Divide by zero error
         EINTERR 42      Overflow on conversion of a double integer
         EFPUND  43      Floating point underflow (does not abort
                         the program). Zero is returned.
         EILLARG 44      Illegal function argument, e.g  sqrt(-1)

### SEE ALSO

    math().


* * *
<a name="close"></a>
## CLOSE

### NAME

    close - close a file

### SYNOPSIS

    close(pn)
    int pn;

### DESCRIPTION

`CLOSE`  closes an already opened file as described by the path number __pn,__  which is the path number returned from an __open(),__  creat(), create() or __dup()__  call.
Termination of a process always closes all opened files automatically, but it is necessary to close files where multiple files are opened by the process and it is desired to re-use the path numbers to avoid exceeding the process or system path number limit.
### DIAGNOSTICS

This call does not return anything.
### SEE ALSO

    creat(), create(), open(), dup().


* * *
<a name="conv"></a>
## CONV

### NAME

    toupper, tolower, _toupper, _tolower, toascii - translate characters

### SYNOPSIS

     #include <ctype.h>

     toupper (c)
     int c;

     tolower (c)
     int c;

     _toupper (c)
     int c;

     _tolower (c)
     int c;

     toascii (c)
     int c;

### DESCRIPTION

The functions `TOUPPER`  and `TOLOWER`  have as domain the range of __getc(),__  which are the ASCII characters from -1 through 255. If the argument to `TOUPPER`  represents a lower case letter, the result is the corresponding upper case letter. If the argument to `TOLOWER`  represents an upper case letter, the result is the corresponding lower case letter.

The macros `_TOUPPER`  and `_TOLOWER`  accomplish the same thing as `TOUPPER`  and `TOLOWER ,`  except they are faster and are restricted to ASCII characters (for example, -1 to 127).  The macro `_TOUPPER`  requires a lowercase letter as its argument; its result is the corresponding uppercase letter. The macro `_TOLOWER`  requires an uppercase letter as its argument; its result is the corresponding lowercase letter.

The macro `TOASCII`  yields its argument with all bits turned off that are not part of a standard ASCII character set, i.e., the MSB of that character is set to 0. It is intended for compatibility with other systems.
### CAVEATS

Any arguments to the macros `_TOUPPER, _TOLOWER,`  or `TOASCII`  outside the ranges specified will yield garbage results.
### SEE ALSO

    ctype, getc()


* * *
<a name="crc"></a>
## CRC

### NAME

    crc - compute the cyclic redundancy count of a module

### SYNOPSIS

    crc(start, count, accum)
    char *start;
    int count;
    char accum[3];

### DESCRIPTION

This call accumulates a crc into a three byte array at __accum[3]__  for the __count__  bytes starting at __start.__  All three bytes of __accum__  should be initialized to 0xFF before the first call to `CRC.`  However, repeated calls can be subsequently made to cover an entire module.  If the result is to be used as an OS-9 module crc, it should have its bytes complemented before insertion at the end of the module.  An example follows:

	/*
    **  Calculate a module's CRC and insert it at the end.
    **
    **  The pointer passed in mod_desc is address of
    **  the beginning of the module already in memory.
    */

    #include <module.h>

    chg_crc(mod_desc)
    char *mod_desc;
    {
        int count;
        char accum[3];
        char *old_crc;

        old_crc = (char *) mod_desc + mod_desc->m_size - 3;
        count = mod_desc->msize - 3;

        accum[0] = 0xff;
        accum[1] = 0xff;
        accum[2] = 0xff;

        crc (mod_desc, count, accum);

        *old_crc++ = ~accum[0];
        *old_crc++ = ~accum[1];
        *old_crc = ~accum[2];
    }



* * *
<a name="creat"></a>
## CREAT

### NAME

    creat - create a new file

### SYNOPSIS

    #include <modes.h>

    creat(fname, perms)
    char *fname;
    int perms;

### DESCRIPTION

`CREAT`  returns a path number to a new file available for writing, giving it the permissions specified in the __perm__  variable and making the process user the owner of the file.  If, however, __fname__  is the name of an already existing file, the file is truncated to zero length and the ownership and permissions remain unchanged.  Note, that unlike the OS-9 assembler service request, `CREAT`  DOES NOT return an error if the file already exists. __Access()__  should be used to establish the existance of the file if it is important that a file should not be overwritten.

It is unnecessary to specifiy writing permissions in __perm__  in order to write to the file in the current process.

The following permissions are defined in the the include file `MODES.H`  as follows:

	/* File Modes */

    #define  S_IFMT     0xff  /* mask for type of file */
    #define  S_IFDIR    0x80  /* directory */

    /* Permissions */

    #define  S_IPRM     0xff  /* mask for permission bits */
    #define  S_IREAD    0x01  /* owner read */
    #define  S_IWRITE   0x02  /* owner write */
    #define  S_IEXEC    0x04  /* owner execute */
    #define  S_IOREAD   0x08  /* public read */
    #define  S_IOWRITE  0x10  /* public write */
    #define  S_IOEXEC   0x20  /* public execute */
    #define  S_ISHARE   0x40  /* sharable */

Directories may not be created with this call -- use __mknod()__  instead.
### DIAGNOSTICS

This call returns -1 if there are too many files opened, if the pathname cannot be searched, if permission to write is denied, or of the file already exists and IS A DIRECTORY.
### CAVEATS

File permissions that specify either owner or public executable files will cause the new file to be created in the current execution directory.  All other permissions will cause the file to be created in the current data directory.  To create an executeable file in the current data directory, see __create().__
### SEE ALSO

    create(), write(), close(), chmod()


* * *
<a name="create"></a>
## CREATE

### NAME

    create - creates and opens a file

### SYNOPSIS

    #include <modes.h>

    create(fname, mode, pmode)
    char *fname;
    int mode, pmode;

    ocreat(fname, mode, pmode)
    char *fname;
    int mode, pmode;

### DESCRIPTION

`CREATE`  creates and opens the file named __fname.__  This call accepts the file mode and access permissions in the same function and is useful in setting up user permissions as soon as the file is opened.

This function returns -1 if the file already exists, or the path number if the file is successfully created.

`OCREAT`  performs the same function, except it deletes the old file if it already exists when `OCREAT`  is called.
### SEE ALSO

    creat(), open(), fopen().


* * *
<a name="ctime"></a>
## CTIME

### NAME

    ctime, localtime, gmtime, asctime, tzset - convert date and time

### SYNOPSIS

    #include <utime.h>


    *ctime (clock)
    long *clock;


    *localtime (clock)
    long *clock;


    *asctime (tm)
    struct tm *tm;


    extern long timezone;  /* used here for compatibility only */


    extern int daylight;


    void tzset()

### DESCRIPTION

`CTIME`  converts a long integer, usually returned from `TIME()`, or pointed to by __clock,__  representing the time in seconds since 00:00:00, January 1, 1970, and returns a pointer to a 26-character string in the following form:

    Sun Sep 16 01:03:52 1973\\n\\0

The `TIME`  function is ideally suited to return the long interger time value.

`LOCALTIME`  returns a pointer to the __tm__  structure.

`ASCTIME`  converts a __tm__  structure to a 26-character string, as shown in the above example, and returns a pointer to the string.

For user convience, declarations of all the functions and the externals, and the __tm__  structure, are provided in the <utime.h> header file, shown on the next page.

The external long variable __timezone__  is always zero.
### EXAMPLE

    To print the current time:

    long curr_time;
    curr_time = time ((long *)0);
    printf ("The time is: %s", ctime(&curr_time));

### BUGS

The return values point to static data whose content is overwritten by each call.
### SEE ALSO

    time(), o2utime(), u2otime()
    /*
    **      Utime.h
    */

    struct tm {
          int   tm_sec;       /* seconds (0 - 59)         */
          int   tm_min;       /* minutes (0 - 59)         */
          int   tm_hour;      /* hours   (0 - 23)         */
          int   tm_mday;      /* day of month (1 - 31)    */
          int   tm_mon;       /* month of year (0 - 11)   */
          int   tm_year;      /* year ( year - 1900)      */
          int   tm_wday;      /* day of week (Sunday = 0) */
          int   tm_yday;      /* day of year (0 - 365)    */
          int   tm_isdst;     /* NOT USED                 */
          };

    long        time();       /* Same as UNIX */
    struct tm   *localtime(); /* Same as UNIX */
    char        *asctime();   /* Same as UNIX */
    char        *ctime();     /* Same as UNIX */

    long        o2utime();    /* Convert OS9 style buf to UNIX long */
    /* void */  u2otime();    /* Convert 'tm' to OS9 char *buf */


* * *
<a name="ctype"></a>
## CTYPE

### NAME

    isalpha, isupper, islower, isdigit, isalnum, isspace, ispunct,
    isprint, iscntrl, isascii, - character classification macros

### SYNOPSIS

    #include <ctype.h>

    isalpha(c)

    etc....

### DESCRIPTION

These macros classify character-coded integer values according to their ascii value using fast table look-up.

All macros return non-zero for true and zero for false.

The macro `ISASCII`  provides a correct result for all integer values. The rest provide a result for EOF and values in the character range outlined in the table below, however, the result will be unpredictable for characters outside the range -1 to 127.     isalpha     c is a letter

    isupper     c is an uppercase letter

    islower     c is a lowercase letter

    isdigit     c is a digit

    isalnum     c is an alphanumeric character

    isspace     c is a space, tab, carriage return, new line,
                  or formfeed

    ispunct     c is a punctuation character (neither control,
                  alphanumeric, nor a space)

    isprint     c is a printable character, code 32 (space)
                  through 126 (tilde)

    iscntrl     c is a delete character (127) or ordinary
                  control character (less than 32) except
                  for space characters

    isascii     c is an ASCII character, code less than 128


### SEE ALSO

    toascii(), toupper(), tolower(), _toupper(), _tolower()


* * *
<a name="data-modules"></a>
## DATA MODULES

### NAME

    datlink, dunlink, lockdata, unlkdata -- Data module operations.

### SYNOPSIS

    int datlink(name, datptr, space)
    char *name, *datptr;
    int *space;

    int dunlink(datptr)
    char *datptr;

    int lockdata(datptr)
    char *datprt;

    int unlkdata(datptr)
    char *datptr;

### DESCRIPTION

`DATLINK`  loads (if necessary) and links the file __name.__  __Datptr__  is set to the address of the data section. __Space__  is set to the free space available. `DATLINK`  returns (-1) if an error, __null__  for a successful link, and 1 if a load was required. If a 1 is returned, that means you are the first user of  that data module.

`DUNLINK`  unlinks the module belonging to __DATPTR.__  A (-1) is returned if an error occurs, or a __null__  if no error.

`LOCKDATA`  attempts to lock the data module __(datptr__  is considered to be the lock byte) by changing the lock byte, which is normally -1, to a __null.__  `LOCKDATA`  returns a process stack level on failure, or a __null.__  ERRNO is not set.

`UNLKDATA`  unlocks the data module. It returns a (-1) on any attempt to unlock a module that has not already been locked.

A __null__  is returned upon success.
### NOTE

A data module is considered locked when it is loaded. It must be set for use by a call to `UNLKDATA`  after the original loader is finished with any initialization required. A user can determine if they are the original owner by the value returned during the `DATLINK`  call.

In all cases, __datptr__  points to the lock byte. User free space begins at __datptr__  + 1.

* * *
<a name="devtyp"></a>
## DEVTYP

### NAME

    devtyp, isatty - check the type of a device

### SYNOPSIS

    devtyp(pn)
    int pn;

    isatty(pn)
    int pn;

### DESCRIPTION

`DEVTYP`  returns an integer number corresponding to the device type as defined by OS9. __PN__  is the OS9 path number opened to the device to check.

The following are the device types and returned values:

    0 = SCF     1 = RBF     2 = PIPE     3 = SBF

`ISATTY`  functions in the same manner as __devtype,__  but returns __TRUE__  if the device is an `SCF`  type and __FALSE__  if it is not.
### NOTE

`FOR COCO USERS:`  These functions do not return any different values for a Level II device window since they are defined as SCF type devices.

* * *
<a name="dir"></a>
## DIR

### NAME

    opendir, readdir, telldir, rewinddir, seekdir, closedir

    Directory operations

### SYNOPSIS

    #include <dir.h>

    *opendir(dirname)
    char *dirname;

    *readdir(dirp)
    DIR *dirp;

    telldir(dirp)
    DIR *dirp;

    rewinddir(dirp)
    DIR *dirp;

    seekdir(dirp, loc)
    DIR *dirp;
    long loc;

    closedir(dirp)
    DIR *dirp;

### DESCRIPTION

`OPENDIR`  opens the specified directory and associates a directory stream with it. `OPENDIR`  returns a pointer to be used to identify the directory stream in subsequent operations. The pointer __null__  is returned if __dirname__  can not be accessed or of it can not "malloc" enough memory to hold the whole thing. Directory sectors are NOT buffered.

`READDIR`  returns a pointer to a structure containing the next directory entry, unless the entry is a deleted file in which case the next entry is returned. It returns __null__  upon reaching the end of the directory or detecting an invalid `SEEKDIR`  operation.

`TELLDIR`  returns the current location associated with the named directory stream. Values returned by `TELLDIR`  are valid only for the lifetime of the associated dir pointer. If the directory is closed and then reopened, the `TELLDIR`  value may be invalidated. It is safe to use a previous `TELLDIR`  value immediately after a call to `OPENDIR`  and before any calls to `READDIR.`

`REWINDDIR`  resets the position of the named directory stream to the beginning of the directory.

This function is implemented as a macro in `DIR.H.`

`SEEKDIR`  sets the position of the next `READDIR`  operation in the directory stream. The new position reverts to the one associated with the directory stream when the `TELLDIR`  operation was performed. `CLOSEDIR`  closes the named directory stream and frees the structure associated with __dirp.__
### NOTE

For user convinence, function declarations are made in the header `DIR.H`  below.


    /*
    **      Dir.h
    /*

    struct direct {
            long d_addr;       /* file descriptor address */
            char d_name[30];   /* directory entry name    */
            };

    typedef struct {
            int   dd_fd;       /* fd for open directory   */
            char  dd_buf[32];  /* a one entry buffer      */
            } DIR;

    #define DIRECT        struct direct
    #define rewinddir(a)  seekdir(a, 0L)

    extern DIR            *opendir();
    extern DIRECT         *readdir();
    extern long           telldir();
    extern  /* void */    seekdir(), closedir();



* * *
<a name="-dump"></a>
## _DUMP

### NAME

    _dump - Dumps memory to standard output.

### SYNOPSIS

    void _dump(s, addr, count)
    int count;
    char *s, *addr;

### DESCRIPTION

`DUMP`  is used mostly as a debugging function. It prints the title __s__  and then, starting at the memory address pointed to by __addr,__  dumps at the most __count__  bytes to standard output.
### NOTE

Care must be taken to insure the variable __count__  is not too large, else the memory dump will take a very long time. Also, the dump is formatted similar to the standard OS9 dump utility.

* * *
<a name="dup"></a>
## DUP

### NAME

    dup - duplicate an open path number

### SYNOPSIS

    dup(pn)
    int pn;

### DESCRIPTION

`DUP`  takes the path number __pn__  as returned from an __open(),__  creat(), or __create()__  call and returns another path number associated with the same file.

`DUP`  is often used to duplicate the standard paths (stdin, stdout, stderr) prior to forking a new process.  The new process will then have these paths for its use.
### EXAMPLE

    To use DUP to copy the standard paths:

    fork (cmd, parms, path)
    char *cmd, *parms;
    int path;

    {
        int i;
        int save[3];

        for (i = 0; i <= 2; i++)
            save[i] = dup (i);

        for (i = 0; i <= 2; i++)
            close (i);

        for (i = 0; i <= 2; i++)
            dup (path);

        close (path);

        os9fork (cmd, strlen(parms), parms, 1, 1, 0);

        for (i = 0; i <= 2; i++) {
            close (i);
            dup (save[i]);
            close (save[i]);
        }

### DIAGNOSTICS

A -1 is returned if the call fails because there are too many opened files or the path number is invalid.
### SEE ALSO

    open(), creat(), create(), close()


* * *
<a name="-errmsg"></a>
## _ERRMSG

### NAME

    _errmsg() - Print an error message

### SYNOPSIS

    int _errmsg(nerr, msg[,arg1, arg2, arg3])
    int nerr;
    char *msg;

### DESCRIPTION

This function displays an error message on the standard error path along with the name of the program. The message string __msg__  is displayed in the following format:
    prog: <message text>
Note: __Prog__  is the module name of the program and `<message text>`  is the string passed as __msg.__

For added flexibility in the message printing, the __msg__  string can be a conversion string suitable for __printf()__  with up to 3 additional arguments of any type. The argument __nerr__  is returned as the value of the functions so ___errmsg__  can be used as a parameter to a function such as __exit()__  or __prerr().__
### EXAMPLE

    Assume the program calling the function is named "foobar":

    Call:   _errmsg(1,"programmed message\n");
    Prints: foobar: programmed message

    Call:   exit(_errmsg(errno,"unknown option '%c'\n",'q'));
    Prints: foobar: unknown option 'q'

    Then exits with the error code in errno.

### SEE ALSO

    printf(), _prgname().


* * *
<a name="exit"></a>
## exit

### NAME

    exit - terminate a process after flushing any pending output

### SYNOPSIS

    exit(status)
    int status;

    _exit(status)
    int status;

### DESCRIPTION

`EXIT`  is the normal means of terminating a task. The `EXIT`  function terminates a process after calling the Standard I/O library function ___cleanup,__  to flush any buffered output.
The `_exit`  function performs the same, but DOES NOT flush any file buffers prior to exiting the task. Neither the `EXIT`  or `_EXIT`  functions ever return.
A process finishing normally, that is, returning from __main(),__  is equivalent to a call to `EXIT.`
The status passed to `EXIT`  is avaiable to the parent process if it is executing a __wait.  An example is:__      static int stat;
    char *status = &stat;
    \.
    \.
    os9fork (cmds, strlen(params), params, 1, 1, 0);
    wait (status);
    \.
    \.


### SEE ALSO

    wait()


* * *
<a name="fclose"></a>
## fclose

### NAME

    fclose, fflush - close or flush a stream (file)

### SYNOPSIS

    #include <stdio.h>

    fclose(fp)
    FILE *fp;

    fflush(fp)
    FILE *fp;

### DESCRIPTION

The `FCLOSE`  routine causes any buffers for the named file pointer __fp__  to be emptied, and the file to be closed. Buffers allocated by the standard input/output system are freed for use by another `FOPEN`  call. `FCLOSE`  should always be called to close access to a file when it is no longer needed. The `FCLOSE`  routine is performed automatically upon calling __exit() .__  The `FFLUSH`  routine causes any buffered data associated with the named output file pointer __fp__  to be cleared and written to that file, but only if the file was opened in the write or update mode.  It is not normally necessary to call `FFLUSH,`  but it can be useful when, for example, normal output is to __stdout,__  and it is wished to send something to __stderr,__  which is unbuffered.  If `FFLUSH`  were not used and __stdout__  was referred to the terminal, the __stderr__  message would appear before large chunks of the __stdout__  message even though the latter was written first.  The file associated with __fp__  remains open after the call.
### DIAGNOSTICS

These routines return __EOF__  if the file pointer __fp__  is not associated with an output file, or if buffered data cannot be written to that file. You should always check the returned status of and `FCLOSE`  call.
### CAVEATS

In cases where `FCLOSE`  is called as a result of an __exit()__  call, the error may be returned, but no process is running to receive it.  In this case, the data in the buffer will not be written to the file and the operator will NOT GET an error message.
### SEE ALSO

    exit(), close(), fopen(), setbuf()


* * *
<a name="ferror"></a>
## ferror

### NAME

    ferror, feof, clearerr, fileno - return status inquiries of files

### SYNOPSIS

    #include <stdio.h>

    feof(fp)
    FILE *fp;

    ferror(fp)
    FILE *fp;

    clearerr(fp)
    FILE *fp;

    fileno(fp)
    FILE *fp;

### DESCRIPTION

The `FERROR`  function returns nonzero when an error has occurred reading or writing the file associated with the file pointer __fp__  has reached its end, otherwise zero is returned.  Unless cleared by `CLEARERR,`  the error indication lasts until the file pointed to by __fp__  is closed, thus preventing any further access to that file.

The `FEOF`  function returns nonzero when end of file is read on the named input __fp,__  otherwise zero.

The `CLEARERR`  function resets both the error and __EOF__  indicators on the named file associated with __fp.__  Note that the file is not "fixed" nor does it prevent the error from occurring again.  It just allows Standard Library functions to at least try to access the file.

The `FILENO`  function returns the integer path descriptor associated with the file pointer __fp,__  for use with Standard Library calls the use path numbers, such as __close(), open(),__  etc.
### CAVEATS

These functions are implemented as macros in `STDIO.H`  so they cannot be redeclared.
### SEE ALSO

    open(), fopen()


* * *
<a name="findstr"></a>
## FINDSTR

### NAME

    findstr, findnstr - string search

### SYNOPSIS

    findstr(pos, string, pattern)
    char *string, *pattern;
    int pos;

    findnstr(pos, string, pattern, len)
    char *string, *pattern;
    int pos, len;

### DESCRIPTION

These functions search the string pointed to by __string__  for the first instance of the pattern pointed to by __pattern__  starting at position __pos__  (where the first position in a string is 1 not 0).  The returned value is the position of the first matched character of the pattern in the string, or zero if a match is not found.

`FINDSTR`  stops searching the string when a null byte is found.

`FINDNSTR`  only stops searching at position __pos + len__  so it may continue past nulls.
### CAVEATS

The current implementation does not use the most efficient algorithm for pattern matching so use on very long strings is likely to be somewhat slow.
### SEE ALSO

    patmatch(), index(), rindex(), strchr(), strrchr()


* * *
<a name="fopen"></a>
## FOPEN

### NAME

    fopen, freopen, fdopen - open a file

### SYNOPSIS

    #include <stdio.h>

    FILE *fopen (filename, type)
    char *filename, *type;

    FILE *freopen (filename, type, stream)
    char *filename, *type;
    FILE *stream;

    FILE *fdopen (fildes, type)
    int fildes;
    char *type;

### DESCRIPTION

`FOPEN`  opens a file and returns a file pointer to the file structure associated with that file.  The pointer __filename__  points to a character string that contains the name of the file to be opened.

The pointer __type__  is a character string having one of the following values:     "r"  - Open for reading

    "w"  - Truncate or create for writing

    "a"  - Append; open for writing at end of file,
           or create for writing

    "r+" - Open for reading and writing (update)

    "w+" - Truncate or create for reading and writing (update)

    "a+" - Append; open or create for reading and writing at
           end-of-file.

    "d"  - Open a directory file for reading ONLY

Any of the above types may have a "x" after the initial letter which indicates to `FOPEN`  that is should look in the current execution directory if a full pathname is not given in __filename.__  The "x" also specifies that the file should have "execute" permissions.

Opening for write will perform a __creat()__  call.  If a file with the same name exists when the file is opened, it will be truncated to zero length. Append means to open for write and position the file pointer to the end of the file.  Writes to the file will then extend the file until __fclose()__  is called.  The file will only be created if it does not already exist. All files created with `FOPEN`  will have file permissions set for user read and write and read only for all others.  To set other combinations of file permissions, use __create().__

Three file pointers are available and considered open as soon as a program is run.  These are:     stdin  -  the standard input path (0)
    stdout -  the standard output path (1)
    stderr -  the standard error output path (2)

All files are automatically buffered except stderr unless it is made unbuffered by a call to __setbuf().__

The `FREOPEN`  routine substitutes the named file in place of the open stream. The original stream is closed, regardless of whether the open ultimately succeeds.  The `FREOPEN`  routine returns a pointer to the __file__  structure associated with pointer __stream.__

The `FREOPEN`  routine is typically used to attach the preopened __streams__  associated with __stdin, stdout,__  and __stderr__  to other files.

The `FDOPEN`  routine associates a __stream__  with a path descriptor.  Path descriptors are obtained from __open(), dup(), creat(),__  or __create(),__  which open files but do not return pointers to a __file__  structure. Streams are necessary input for many of the Section 3s library routines. The __type__  of __stream__  (r,w,a) must agree with the mode of the open file.

When a file is opened for update, both input and output may be done on the resulting __stream.__  However, output may not be directly followed by input without an intervening __fseek()__  or __rewind(),__  and input may not be directly followed by output without an intervening __fseek(), rewind(),__  or an input operation which encounters end-of-file.
All output is written at the end of the file and causes the file pointer to be repositioned at the end of the output regardless of its current position.  If two separate processes open the same file for append, each process may write freely to the file without fear of destroying output being written by the other.  The output from the two processes will be intermixed in the file in the order in which it is written.


### CAVEATS

The __type__  passed as an argument to `FOPEN`  must be a pointer to a string and NOT a character constant.  For example:
    fp = fopen("foo", "r");  is correct     fp = fopen("foo", 'r');  is not

### DIAGNOSTICS

FOPEN returns null (0) if the call was not successful.
### SEE ALSO

    creat(), create(), dup(), open(), fclose(), fseek()


* * *
<a name="fread"></a>
## FREAD

### NAME

    fread, fwrite - read/write binary data

### SYNOPSIS

    fread(ptr, sizeof(item), nitems, fp)
    FILE *fp;

    fwrite(ptr, sizeof(item), nitems, fp)
    FILE *fp;

### DESCRIPTION

The `fread`  function reads into a buffer beginning at __ptr, nitems__  of data of the type __item__  from the input file pointer __fp.__  It returns the number of items actually read.

The `fwrite`  function writes, at most, __nitems__  of data of the type __item__  beginning at __ptr__  to the named output file __fp.__  It returns the number of items actually written.

In both cases, the type __item__  refers to either a char, int, or unsigned data type.  Care must be taken to insure the correct values are used.  If, for example, 10 bytes of type __char__  are to be written, then this is the same amount of data going to the output stream as 5 bytes of type __int.__
### DIAGNOSTICS

Both functions return a __null__  at end of file or if an error occurs.  To insure the correct data is read or written, the returned number of type __item__  should be compared to what was intended.  If there is a difference, an error has occured.
### SEE ALSO

    read(), write(), fopen(), getc(), putc(), printf(), scanf()


* * *
<a name="fseek"></a>
## FSEEK

### NAME

    fseek, ftell, rewind - reposition a file pointer or report position

### SYNOPSIS

    #include <stdio.h>

    fseek(fp, offset, place)
    FILE *fp;
    long offset;
    int place;

    long ftell(fp)
    FILE *fp;

    rewind(fp)
    FILE *fp;


### DESCRIPTION

The `FSEEK`  function sets the position of the next input or output operation on the already opened file pointed to by __fp.__  The new position is at __offset__  bytes from the beginning, the current position, or the beginning of the file if __place__  has the value 0, the current position if 1, or the end of the file if 2.

The `FSEEK`  function undoes any effects of __ungetc()__  and sorts out the problems associated with buffered I/O.

`NOTE:`  Using __lseek()__  on a buffered file will produce unpredictable results.

The `FTELL`  function returns the current value of the  offset relative to the beginning of the file associated with the file pointer __fp.__  It is measured in bytes and is the only foolproof way to obtain an __offset__  for `FSEEK.`

The `REWIND `  function is equivalent to __fseek(fp, 0L, 0),__  except that no value is returned. It returns the file pointer to the beginning of the file.
### DIAGNOSTICS

`FSEEK`  returns a -1 if the call is invalid, otherwise it returns zero.
### SEE ALSO

    lseek()


* * *
<a name="getc"></a>
## GETC

### NAME

    getc, getchar, getw - get character or word from a file

### SYNOPSIS

    #include <stdio.h>

    getc(fp)
    FILE *fp;

    getchar()

    getw(fp)
    FILE *fp;

### DESCRIPTION

The `GETC`  function returns the next character from the named input __fp.__

The `GETCHAR`  function  is identical to  __getc__  (stdin).

The `GETW`  function returns the next word from the named input __fp.__  It returns the constant EOF upon end of file or error, but since that is a good integer value, __feof()__  and __ferror()__  should be used to check the success of `GETW.`  The `GETW`  assumes no special alignment in the file.
### CAVEATS

Because it is implemented as a macro, `GETC`  treats a __fp__  argument with side effects incorrectly. In particular, __'getc(*f++);'__  doesn't work as expected.
### SPECIAL CONSIDERATIONS

Under OS-9, there is a choice of system calls to use when reading from a file. __Read()__  will get characters up to a specified number in the "raw" mode, i.e., no editing will take place on the input stream and the characters will appear to the program exactly as in the file. __Readln()__  on the other hand, will honor the various mapping of characters associated with a serial device such as a terminal and will return as soon as a carriage return is seen on the input.

In the vast majority of cases, it is preferable to use __readln()__  for accessing serial character devices and __read()__  for any other file input. `GETC`  uses this strategy and as all file input using the Standard Library functions is routed through `GETC(),`  so do all the other input functions.  The choice is made when the first call to `GETC()`  is made after the file has been opened.  The system is consulted for the status of the file and a flag bit is set in the file structure accordingly.  The choice may be forced by the programmer by setting the relevant bit before a call to `GETC().`  The flag bits are defined in `STDIO.H`  as ___SCF__  and ___RBF__  and the method used is as follows:

Assuming that the file pointer for the file as returned by __fopen()__  is __f,__      f->_flag |= _SCF

will force the use of __readln()__  on input, and     f->flag |= _RBF

will force the use of __read().__  This trick may be played on the standard input, output, and error files without the need to call __fopen()__  but must be made before any input is requested from these files.
### DIAGNOSTICS

These functions return the integer constant EOF (-1) at end of file or upon read error.
### SEE ALSO

    fopen(), fread(), gets(), putc(), scanf(), ungetc()


* * *
<a name="getopt"></a>
## GETOPT

### NAME

    getopt - Get an option letter from argument vector

### SYNOPSIS

    int getopt (argc, argv, optstring)
    int argc;
    char **argv, *optstring;

    extern char *optarg;
    extern int optind, opterr;

### DESCRIPTION

`GETOPT`  returns the next option letter in __argv__  that matches a letter in __optstring.  Optstring__  is a string of recognized option letters; if a letter is followed by a colon, the option is expected to have an argument that may or may not be separated from it by white space. __Optarg__  is set to point to the start of the option argument on return from `GETOPT.`

`GETOPT`  places in __optind__  the __argv__  index of the next argument to be processed. Because __optind__  is external, it is normally initialized to zero automatically before the first call to `GETOPT.`

When all options have been processed (i.e., up to the first non-option argument), `GETOPT`  returns __EOF.__  The special option -- may be used to delimit the end of the options; __EOF__  will be returned, and -- will be skipped.
### DIAGNOSTICS

`GETOPT`  prints an error message on the stderr path and returns a question mark (?) when it encounters an option letter not included in __optstring.__  This error message may be disabled by setting __opterr__  to a non-zero value.
### EXAMPLE

The following code fragment shows how one might process the arguments for a command that can take the mutually exclusive options a and b, and the options f and o, both of which require arguments:

	main (argc, argv)
    int argc;
    char **argv;
    {
    	int c;
    	extern char *optarg;
    	extern int optind;
    	.
    	.
    	.
    	.
    	while ((c = getopt(argc, argv, "abf:o:")) != EOF)
    		switch (c) {
    		case 'a':
    			if (bflg)
    				errflg++;
				else
    				aflg++;
				break;
			case 'b':
  				if (aflg)
   					errflg++;
				else
    				bproc();
				break;
			case 'f':
				ifile = optarg;
				break;
			case 'o':
				ofile = optarg;
				break;
			case '?':
				errflg++;
		}
		if (errflg) {
			fprintf(stderr, "Usage: . . . ");
			exit (2);
	}

	for ( ; optind < argc; optind++) {
		if (access(argv[optind], 4)) {
		.
		.
		.
	}



* * *
<a name="getpid"></a>
## getpid

### NAME

    getpid - get a process ID

### SYNOPSIS

    getpid()

### DESCRIPTION

A number unique to the currently running process is often useful in creating names for temporary files and many other uses.  This call returns the process' system ID number as returned to its parent by __os9fork().__
### SEE ALSO

    os9fork()


* * *
<a name="gets"></a>
## GETS

### NAME

    gets, fgets - get a string from a file

### SYNOPSIS

    #include <stdio.h>

    char *gets(s)
    char *s;

    char *fgets(s, n, fp)
    FILE *fp;
    char *s;
    int n;

### DESCRIPTION

The `GETS`  routine reads a string into __s__  from the standard input path __stdin .__  The string is terminated by a newline character, which is replaced in __s__  by a null character. The `GETS`  routine returns its argument.

`FGETS`  routine reads  __n-1__  characters, or up to a newline character, whichever comes first, from the file pointed to by __fp__  into the string __s.__  The last character read into __s__  is followed by a null character. `FGETS`  routine returns its first argument.
### CAVEATS

The different treatment of the newline ("\\n") character by these functions is retained here for portability reasons.
### DIAGNOSTICS

Both functions return __null__  on end-of-file or if an error occurs.
### SEE ALSO

    ferror(), fread(), getc(), puts(), scanf()


* * *
<a name="getstat"></a>
## GETSTAT

### NAME

    SS_OPT, SS_READY, SS_SIZE, SS_POS, SS_EOF, SS_DEVNAM, SS_FD

    OS-9 get status system calls.

### SYNOPSIS

    #include <sgstat.h>

    getstat(SS_OPT, filenum, buffer)
    int code, filenum;
    struct sgbuf *buffer;

    getstat(SS_READY, filenum)
    int code, filenum;

    getstat(SS_SIZE, filenum, size)
    int code, filenum;
    long *size;

    getstat(SS_POS, filenum, position)
    int code, filenum;
    long *position;

    getstat(SS_EOF, filenum)
    int code, filenum;

    getstat(SS_DEVNAM, filenum, buffer)
    int code, filenum;
    char *buffer;

    #include <direct.h>

    getstat(SS_FD, filenum, buffer, count)
    int code, filenum;
    struct fildes *buffer;
    int count;

### DESCRIPTION

These calls are the equivalent of the `_GS_XXX`  calls described elsewhere in these documents. While the `_GS_XXX`  calls are provided for compatibility with source code generated for OSK and UNIX systems, the calls listed below are those normally used with 6809/OS-9.

The following descriptions do not include the complete syntax of each function call. See the list above under Synopsis.

`GETSTAT(ss_opt)`  copies the options section of the path descriptor opened on __path__  into the buffer pointer to by __buffer.__  The structure __sgbuf__  in `SGSTAT.H`  provides a convenient means to access the individual option values.
Be sure the buffer is large enough to hold all the options. Declaring the buffer as a type __struct sgbuf__  is perfectly safe as this structure is predefined to be large enough for all the device descriptor options.

This call works only on `RBF`  devices.

`GETSTAT(ss_ready)`  checks an `SCF`  device opened on __path__  to see if data is waiting to be read. Read requests to OS9 will wait until enough bytes have been read to satisfy the bytecount given thereby suspending the program until the read is finished.

A program can use this function to determine the number of bytes, if any, are waiting to be read, and then issue a read request for only the number of bytes actually received.

If no data is available to be read, or the device is not an `SCF`  device, a -1 is returned and the appropriate error code is placed in __errno.__  Otherwise, the number of bytes available to be read is returned.

This call is effective only on `SCF`  devices. This function is not intended for use with buffered I/O calls (like __getc()),__  and unpredictable results will likely occur. This call works best with low-level I/O functions.

`GETSTAT(ss_size)`  returns the size of the file pointed to in filenum.  The size is returned in the long variable 'size'.

`GETSTAT(ss_pos)`  returns the value of the file pointer for the file opened on __filenum.__

If an error occurs, this function returns -1 as its value and the error code is placed in the global variable __errno.__

This call works only on `RBF`  devices. It is unique to OS-9 and the only equivalent portable call is __lseek().__  DO NOT use this call if buffered I/O is being performed on the path. Use __ftell()__  instead.

`GETSTAT(ss_eof)`  determines if the file opened is at the end-of-file. If it is, the value 1 is returned -- if not, 0 is returned.

If an error occurs, this function returns -1 as its value and the error code is placed in the global variable __errno.__

This function cannot determine the end-of-file on an `SCF`  device. `SCF`  devices return an __e$eof__  error when the __EOF__  character is read. DO NOT use this call if using buffered I/O on PATH. Instead, use the function __feof().__

`GETSTAT(ss_devnam)`  determines the name of the device opened on a path. The argument __filenum__  is the OS-9 path number of the opened path and __buffer__  is a pointer to a character array into which the null-terminated device name will be placed.

If an error occurs, this function returns -1 as its value and the error code is placed in the global variable __errno.__

Be sure to reserve at least 32 characters to receive the device name.

`GETSTAT(ss_fd)`  places a copy of the `RBF`  file descriptor sector of the file opened into the buffer pointed to by __buffer.__  A maximum of __count__  bytes are copied. The structure __FILDES,__  declared in `DIRECT.H,`  provides a convenient method to access the file descriptor information.

If and error occurs, this function returns -1 as its value and the error code is placed in the global variable __errno.__

Be sure the buffer is large enough to hold all the options, or at least __count__  bytes. This call is effective only on `RBF`  devices. Declaring the buffer as type __struct fildes__  is perfectly safe as this structure is predefined to be large enough to hold all the file descriptor information.
### NOTE

All the above calls require an OS-9 path number for __filenum, and NOT a__  C iob file descriptor pointer.
### SEE ALSO

    I$GetStt system call - Microware Manual, _gs_xxx calls


* * *
<a name="getuid"></a>
## getuid

### NAME

    getuid - get a user ID

### SYNOPSIS

    getuid()

### DESCRIPTION

`GETUID`  returns the real user ID if the currently executing process as maintained in the password file __/dd/sys/password.__
### SEE ALSO

    setuid(), asetuid()


* * *
<a name="gs-devn"></a>
## GS_DEVN

### NAME

    _gs_devn - get device name

### SYNOPSIS

    int _gs_devn(path, buffer)
    int path;
    char *buffer;

### DESCRIPTION

This function determines the name of the device opened on a path. The argument __path__  is the OS-9 path number of the opened path and __buffer__  is a pointer to a character array into which the null-terminated device name will be placed.

The device name returned is in "OS9 format", that is, the last byte of the name will have the high bit set. Also, there is no NULL terminator on the string. The best method to handle this returned value is:             _gs_devn(path, buffer);
            strhcpy(newbuff, buffer);

If PATH is invalid, this function returns -1 as its value and the error code is placed in the global variable ERRNO.
### NOTE

Be sure to reserve at least 32 characters to receive the device name.
### SEE ALSO

    I$GetStt system call - Microware Manual, fopen(), open().


* * *
<a name="gs-eof"></a>
## GS_EOF

### NAME

    _gs_eof - get end-of-file status

### SYNOPSIS

    int _gs_eof(path)
    int path;

### DESCRIPTION

This function determines if the file opened on __path__  is at the end-of-file.  If it is, the value 1 is returned -- if not, 0 is returned.

If __path is invalid, a -1 is returned and the appropriate error code is placed__  in the global variable __errno.__
### NOTE

This function cannot determine the end-of-file on an SCF device. SCF devices return an E$EOF error when the EOF character is read. DO NOT use this call if using buffered I/O on PATH. Instead, use the function feof().
### SEE ALSO

    I$GetStt system call - Microware Manual, feof().


* * *
<a name="gs-gfd"></a>
## GS_GFD

### NAME

    _gs_gfd - get file descriptor

### SYNOPSIS

    #include <direct.h>

    int _gs_gfd(path, buffer, count)
    int path;
    struct fildes *buffer;
    int count;

### DESCRIPTION

This function will place a copy of the `RBF`  file descriptor sector of the file opened on PATH into the buffer pointed to by __buffer.__  A maximum of __count__  bytes are copied. The structure `FILDES,`  declared in `DIRECT.H,`  provides a convenient method to access the file descriptor information.

If and error occurs, this function returns -1 as its value and the error code is placed in the global variable __errno.__
### NOTE

Be sure the buffer is large enough to hold all the options, or at least __count__  bytes. This call is effective only on `RBF`  devices. Declaring the buffer as type "struct fildes" is perfectly safe as this structure is predefined to be large enough to hold all the file descriptor information.
### SEE ALSO

    I$GetStt system call - Microware Manual, _ss_pfd().


* * *
<a name="gs-opt"></a>
## GS_OPT

### NAME

    _gs_opt - get file descriptor options

### SYNOPSIS

    #include <sgstat.h>

    int _gs_opt(path, buffer)
    int path;
    struct sgbuf *buffer;

### DESCRIPTION

This function copies the options section of the path descriptor opened on __path__  into the buffer pointer to by __buffer.__  The structure `SGBUF`  in `SGSTAT.H`  provides a convenient means to access the individual option values.

If __path__  is invalid, this function returns -1 as its value and the error code is placed in the global variable __errno.__
### NOTE

Be sure the buffer is large enough to hold all the options. Declaring the buffer as a type "struct sgbuf" is perfectly safe as this structure is predefined to be large enough for all the device descriptor options.
### SEE ALSO

    I$GetStt system call - Microware Manual, getstat(), _ss_opt().


* * *
<a name="gs-pos"></a>
## GS_POS

### NAME

    _gs_pos - get file position pointer

### SYNOPSIS

    long _gs_pos(path)
    int path;

### DESCRIPTION

This function returns the value of the file pointer for the file opened on __path.__

If __path__  is invalid, this function returns -1 as its value and the error code is placed in the global variable __errno.__
### NOTE

This call works only on `RBF`  devices. It is unique to OS-9 and the only equivalent portable call is __lseek().__  DO NOT use this call if buffered I/O is being performed on the path. Use __ftell()__  instead.
### SEE ALSO

    I$GetStt system call - Microware Manual, lseek(), ftell()


* * *
<a name="gs-rdy"></a>
## GS_RDY

### NAME

    _gs_rdy - get path status

### SYNOPSIS

    int _gs_rdy(path)
    int path;

### DESCRIPTION

This function checks an `SCF`  device opened on __path__  to see if data is waiting to be read. Read requests to OS9 will wait until enough bytes have been read to satisfy the bytecount given, thereby suspending the program until the read is finished.
A program can use this function to determine the number of bytes, if any, are waiting to be read, and then issue a read request for only the number of bytes actually received.
If __path__  is invalid, no data is available to be read, or the device is not an `SCF`  device, a -1 is returned and the appropriate error code is placed in __errno.__  Otherwise, the number of bytes available to be read is returned.
### NOTE

This call is effective only on __SCF__  devices. This function is not intended for use with buffered I/O calls (like __getc())__, and unpredictable results will likely occur. This call works best with low-level I/O functions.
### SEE ALSO

    I$GetStt system call - Microware Manual, getstat(), read(), readln().


* * *
<a name="gs-size"></a>
## GS_SIZE

### NAME

    _gs_size - get file size

### SYNOPSIS

    long _gs_size(path)
    int path;

### DESCRIPTION

This function is used to determine the current size of the file opened on PATH, and returns this value to the calling function.

If __path__  is invalid, this function returns -1 as its value and the error code is placed in the global variable __errno.__
### NOTE

This call works only on `RBF`  devices.
### SEE ALSO

    I$GetStt system call - Microware Manual, getstat()


* * *
<a name="htoi"></a>
## HTOI

### NAME

    htoi, htol, itoa, utoa, ltoa -- type conversions

### SYNOPSIS

    int htoi(s)
    char *s;

    long htol(s)
    char *s;

    char *itoa(n, s)
    int n;
    char *s,

    char utoa(n, s)
    int n;
    char *s;

    char *ltoa(n, s)
    long n;
    char *s;

### DESCRIPTION

`HTOI`  converts a string representing a hexadecimal number into an integer.

`HTOL`  converts a string representing a hexadecimal number into a long integer.

`ITOA`  converts an integer number N to the corresponding `ASCII`  characters and returns a pointer to the string __s.__

`UTOA`  converts an unsigned integer number __n__  to the corresponding `ASCII`  characters and returns a pointer to the string __s.__

`LTOA`  converts a long number __n__  to the corresponding `ASCII`  characters and returns a pointer to the string __s.__
### NOTE

These functions are extensions to the __ATOF__, __ATOL__, and __ATOI__ functions. They perform in the same manner, except for the type of conversion.
### SEE ALSO

    atof(), atoi(), atol()


* * *
<a name="intercept"></a>
## INTERCEPT

### NAME

    intercept - set a function for interrupt processing

### SYNOPSIS

    intercept(func)
    int (*func)();

### DESCRIPTION

`INTERCEPT`  instructs OS-9 to pass control of the process to the function __func__  when an interrupt (signal) is received. If the interrupt processing function has an argument, it will contain the value of the signal received.  On return from __func,__  the process resumes at the point in the program where it was interrupted by the signal. `INTERRUPT`  is an alternate to the use of __signal()__  to process interrupts.

As an example, suppose we wish to ensure that a partially completed output file is deleted if an interrupt is received.  The body of the program might include:     char *temp_file = "temp";
    int pn = 0;
    int intrupt();

    intercept(intrupt);
    pn = creat(temp_file, 3);
    write(pn, string, count);
    close(pn);
    pn = 0;

    The interrupt routine might be:

    intrupt(sig)
    {
        if (pn) {
            close(pn);
            unlink(temp_file);
        }
        exit(sig);
    }


### CAVEATS

`Intercept()`  and __signal()__  are mutually incompatible so that calls to both must not appear in the same program.  The linker guards against this by giving an "entry name clash - sigint" error if it is attempted.

* * *
<a name="kill"></a>
## KILL

### NAME

    kill - send an interrupt to a process

### SYNOPSIS

    #include <signal.h>

    kill(tid, interrupt)
    int tid, interrupt;

### DESCRIPTION

`KILL` sends the signal type  __interrupt__  to the process with id __tid.__  Both tasks, sender and receiver, must have the same user ID unless the users or sender is the super user.

The include file contains definitions of the defined signals as follows:

	#define  SIGKILL  0   /* system abort cannot be */
                          /* caught or ignored */

    #define  SIGWAKE  1   /* wake up signal */
    #define  SIGQUIT  2   /* keyboard abort signal */
    #define  SIGINT   3   /* keyboard interrupt signal */

Other user-define signals my also be sent.
### DIAGNOSTICS

`KILL`  returns 0 from a successful call and -1 if the process does not exist, the effective user IDs do not match, or the user is not the super user.
### SEE ALSO

    signal(), OS-9 Shell command "kill"


* * *
<a name="l3tol"></a>
## L3TOL

### NAME

    l3tol, ltol3 - convert between 3-byte integers and long integers

### SYNOPSIS

    void l3tol (lp, cp, n)
    long *lp;
    char *cp;
    int n;

    void ltol3 (cp, lp, n)
    char *cp;
    long *lp;
    int n;

### DESCRIPTION

The `L3TOL`  subroutine converts a list of __n__  three-byte integers packed into a character string pointed to by  __cp__  into a list of long integers pointed to by __lp .__

The `LTOL3`  performs the reverse conversion from long integers __lp__  to three-byte integers __cp.__

These functions are useful for file-system maintenance where the block numbers are three bytes long.  Certain disc addresses are maintained in three-byte form rather than four-bytes.
### CAVEATS

Because of possible differences in byte ordering, the numerical values of the long integers are machine-dependent.

* * *
<a name="lseek"></a>
## LSEEK

### NAME

    lseek - seek to a position within a file

### SYNOPSIS

    long lseek(pn, position, type)
    int pn;
    long position;
    int type;

### DESCRIPTION

The read or write pointer for the opened file with the path number __pn__  is positioned by `LSEEK`  to the specified place in the file. The __type__  indicates from where __position__  is to be measured: if 0, from the beginning of the file, if 1, from the current pointer location, and if 2, from the end of the file.
Seeking to a location beyond the end of a file opened for writing and then writing to it creates a "hole" in the file which appears to be filled with zeros from the previous end to the position desired.
The returned value is the resulting position in the file unless there is an error, so to find the current position use:     lseek (pn, 0l, 1);


### CAVEATS

The argument __position__  MUST be a long integer.  Constants should be explicitly made long by appending an "l" (el - lower case L), as above, any other type should be converted using a cast:     lseek (pn, (long)pos, 1);

Notice also that the returned value from `LSEEK`  is itself a long integer.
### DIAGNOSTICS

A -1 is returned if __pn__  is a bad path number, or attempting to seek to a position before the beginning of the file.
### SEE ALSO

    open(), creat(), create(), fseek()


* * *
<a name="malloc"></a>
## MALLOC

### NAME

    malloc, free, realloc, calloc - memory allocation

### SYNOPSIS

    char *malloc(size)
    unsigned size;

    free(ptr)
    char *ptr;

    char *realloc(ptr, size)
    char *ptr;
    unsigned size;

    char *calloc(nelem, elsize)
    unsigned nelem, elsize;

### DESCRIPTION

The `MALLOC`  and `FREE`  subroutines provide a simple general-purpose memory allocation package. The `MALLOC`  subroutine returns a pointer to a block of at least __size__  bytes beginning on a word boundary.
The argument to `FREE`  is a pointer to a block previously allocated by `MALLOC.`  This space is made available for further allocation, but its contents are left undisturbed.
Needless to say, grave disorder will result if the space assigned by `MALLOC`  is overrun or if some random number is handed to `FREE.`
The `MALLOC`  subroutine maintains multiple lists of free blocks according to size, allocating space from the appropriate list. It calls __sbrk__  to get more memory from the system when there is no suitable space already free. For further information, see  __brk().__
The `REALLOC`  subroutine changes the size of the block pointed to by __ptr__  to __size__  bytes and returns a pointer to the (possibly moved) block. The contents will be unchanged up to the lesser of the new and old sizes.
If the pointer arguement __ptr__  is zero, then `REALLOC`  degenerates into a `MALLOC.`
In order to be compatible with older versions, __REALLOC__  also works if __ptr__  points to a block freed since the last call of `MALLOC, REALLOC,`  or __CALLOC.__  Sequences of `FREE, MALLOC, `  and `REALLOC`  were previously used to attempt storage compaction. This procedure is no longer recommended.
The `CALLOC`  subroutine allocates space for an array of __nelem__  elements of size __elsize.__  The space is initialized to zeros.
### CAVEATS

When `REALLOC`  returns 0, the block pointed to by __ptr__  may be destroyed.
### DIAGNOSTICS

`MALLOC, FREE,`  and `CALLOC`  return a __null__  if no free memory can be found, or if there was an error.

* * *
<a name="math"></a>
## MATH

### NAME

    rand, srand, unmin, unmax, max, min - Math functions

### SYNOPSIS

    long rand()

    /* void */ srand(n)
    unsigned n;

    int max(v1, v2)
    int min(v1, v2)
    int v1, v2;

    int unmax(v1, v2)
    int unmin(v1, v2)
    unsigned v1, v2;

### DESCRIPTION

`RAND`  returns a random number in the range of 0 -> 32767. `SRAND`  seeds the random number generator and returns nothing. `SRAND`  uses the dual table method proposed by Knuth.
`MAX`  and `MIN`  select either the larger of the smaller of variables __v1__  and __v2.__  `UNMAX`  and `UNMIN`  perform the same function, but on unsigned numbers. Each of these functions returns a type INTEGER number.
### EXAMPLE

    To seed the random number generator, use the value returned from
`    TIME():`

        long time();

        srand ((unsigned) time(0));

### SEE ALSO

    clibt.l Transentental Math library.


* * *
<a name="memory"></a>
## MEMORY

### NAME

    memccpy, memchr, memcmp, memcpy, memset -- memory operations

### SYNOPSIS

    #include <memory.h>

    char *memccpy (s1, s2, c, n)
    char *s1, *s2;
    int c, n;

    char *memchr (s, c, n)
    char *s;
    int c, n;

    int memcmp (s1, s2, n)
    char *s1, *s2;
    int n;

    char *memcpy (s1, s2, n)
    char *s1, *s2;
    int n;

    char *memset (s, c, n)
    char *s;
    int c, n;

### DESCRIPTION

These functions operate as efficiently as possible on memory areas (arrays of characters bounded by a count, not terminated by a null character). They do not check for the overflow of any receiving memory area.
`MEMCCPY`  copies characters from memory area __S2__  into __s1,__  stopping after the first occurrence of character __c__  has been copied, or after __n__  characters have been copied, whichever comes first. It returns a pointer to the character after the copy of __c__  in __s1,__  or a __null__  pointer if __c__  was not found in the first __n__  characters of __s2.__
`MEMCHR`  returns a pointer to the first occurrence of character __c__  in the first __n__  characters of memory area __s,__  or a __null__  pointer if __c__  does not occur.
`MEMCMP`  compares its arguments, looking at the first __n__  characters only, and returns an integer less than, equal to, or greater than 0, according as __s1__  is lexicographically less than, equal to, or greater than __s2.__
`MEMCPY`  copies __n__  characters from memory area __s2__  to __s1.__  It returns __s1.__
`MEMSET`  sets the first __n__  characters in memory area __s__  to the value of character __c.__  It returns __s.__
### NOTE

For user convenience, all these functions are declared in the optional `MEMORY.H` header file.
### BUGS

`MEMCMP`  uses native character comparison, which is unsigned on some machines. Thus, the sign of the value returned when one of the characters has its high order bit set is implementation-dependent.
Character movement is performed differently in different implementations. Thus, overlapping moves may yield surprises.

* * *
<a name="mknod"></a>
## MKNOD

### NAME

    mknod - create a directory

### SYNOPSIS

    #include <modes.h>

    mknod(fname, desc)
    char *fname;
    int desc;

### DESCRIPTION

`MKNOD`  may be used to create a new directory. __Fname__  should be a pointer to a string containing the desired directory name. __Desc__  is a descriptor specifying the desired modes (file type) and the permissions of the new file.
The include file defines possible values for __desc__  as follows:

	/* permissions */

    #define  S_IREAD   0x01      /* owner read */
    #define  S_IWRITE  0x02      /* owner write */
    #define  S_IEXEC   0x04      /* owner execute */
    #define  S_IOREAD  0x08      /* public read */
    #define  S_IOWRITE 0x10      /* public write */
    #define  S_IOEXEC  0x20      /* public execute */
    #define  S_ISHARE  0x40      /* sharable */


### DIAGNOSTICS

Zero is returned if the directory has been successfully made, -1 if the file already exists.
### SEE ALSO

    OS-9 command "makdir"


* * *
<a name="mktemp"></a>
## MKTEMP

### NAME

    mktemp - make a unique file name

### SYNOPSIS

    char *mktemp(name)
    char *name;

### DESCRIPTION

The `MKTEMP`  subroutine replaces __name__  by a unique file name, and returns the address of the name. The name should look like a file name with five trailing X's, which will be replaced with the current process ID.
### EXAMPLE

If instance, if __name__  points to "foo.XXXXX", and the process ID is 351, the returned value points at the same place as __name,__  but it is now "foo.351".
### SEE ALSO

    getpid()


* * *
<a name="modload"></a>
## MODLOAD

### NAME

    modload, modlink - return a pointer to a module structure

### SYNOPSIS

    #include <module.h>

    mod_exec *modload(filename, type, language)
    char *filename
    int type, language;

    mod_exec *modlink(modname, type, language)
    char *modname;
    int type, language;

### DESCRIPTION

Each of these calls returns a pointer to an OS-9 memory module.
`MODLOAD`  will open a file which has the pathlist specified by __filename__  and loads modules from the file adding them to the module directory. The returned value is a pointer to the first module loaded.
`MODLINK`  will search the module directory for a module with the same name as __modname__  and, if found, increment its link count.
In the synopsis above, each call is shown as returning a pointer to an executable module, but it will return a pointer to whatever type of module is found.
### DIAGNOSTICS

A -1 is returned on any error.
### SEE ALSO

    munlink()


* * *
<a name="munlink"></a>
## MUNLINK

### NAME

    munlink - unlink a memory module

### SYNOPSIS

    #include <module.h>

    munlink(mod)
    mod_exec *mod;

### DESCRIPTION

This call informs the system that the memory module pointed to by __mod__  is no longer required by the current process.  Its link count is decremented, and the module is removed from the module directory if the link count reaches zero.
### SEE ALSO

    modlink(), modload()


* * *
<a name="open"></a>
## OPEN

### NAME

    open - open a file for read/write access

### SYNOPSIS

    open(fname, mode)
    char *fname;
    int mode;

### DESCRIPTION

`OPEN`  opens an already existing file for reading if __mode__  is 1, for writing if __mode__  is 2, or reading and writing if __mode__  is 3. `NOTE`  that these values are OS-9 specific and are not compatible with other systems. __Fname__  should point to a string representing the pathname of the file to be opened.
`OPEN`  returns an integer as the "path number" which should be used by I/O system calls referring to the file.
The position where reads or writes start is at the beginning of the file.
### DIAGNOSTICS

A -1 is returned if the file does not exist, if the pathname cannot be searched, if too many files are already open, or if the file permissions deny the requested mode.
### SEE ALSO

    creat(), create(), read(), write(), dup(), close()


* * *
<a name="-os9"></a>
## _OS9

### NAME

    _os9 - system call interface from C programs

### SYNOPSIS

    #include <os9.h>

    _os9(code, reg)
    char code;
    struct registers *reg;

### DESCRIPTION

`_OS9`  enables the programmer to access virtually any OS-9 system call directly from a C program without having to resort to assembly language routines.
__Code__  is one of the codes that are define in `OS9.H.  OS9.H`  contains codes for the F$ and I$ function/service requests, and also contains getstt, setstt, and error codes.
The input registers __(reg)__  for the system calls are accessed by the following structure that is defined in os9.h:

	struct registers {
        char rg_cc, rg_a, rg_b, rg_dp;
        unsigned rg_x, rg_y, rg_u;
    };


An example program that uses _os9 is presented on the following page.
### DIAGNOSTICS

A -1 is returned if the OS-9 call fails.  0 (zero) is returned on success.
Program example:

	#include <os9.h>
    #include <modes.h>

    /* This program does an I$GETSTT call to get file size */

    main (argc, argv)
    int argc;
    char **argv;
    {
        struct registers reg;
        int path;

    /* Tell linker we need longs */

        pflinit();

    /* low level open - filename is first command line param */

        path = open (*++argv, S_IREAD);

    /* set up regs for call to OS-9 */

        reg.rg_a = path;
        reg.rg_b = SS_SIZE;

        if (_os9(I_GETSTT, &reg) == 0)
            printf ("filesize = %1x\n",
            (long) (reg.rg_x << 16) + reg.rg_u);
        else
            printf (OS9 error #%d\n, reg.rg_b & 0xff);

        dumpregs (&reg);
    }

    dumpregs(r)
    register struct registers *r;
    {
        printf("cc = %02x\n", r->rg_cc &0xff);
        printf(" a = %02x\n", r->rg_a &0xff);
        printf(" b = %02x\n", r->rg_b &0xff);
        printf("dp = %04x\n", r->rg_dp &0xff);
        printf(" x = %04x\n", r->rg_x);
        printf(" y = %04x\n", r->rg_y);
        printf(" u = %04x\n", r->rg_u);
    }


* * *
<a name="os9fork"></a>
## OS9FORK

### NAME

    os9fork - create a new process

### SYNOPSIS

    os9fork(modname, paramsize, parmamptr, type, lang, datasize)
    char *modname, paramptr;
    int paramsize, type, lang, datasize;

### DESCRIPTION

The action of `F$FORK,`  the assembler equivalent of `OS9FORK`  is fully described in the OS-9 System manual. `OS9FORK`  will create a process that runs concurrently with the calling process.  When the forked process terminates, it will return to the calling process and pass back its exit status.
__Modname__  should point to the name of the desired module. __Paramsize__  is the length of the parameter string which should always be terminated with a '\\n', and __paramptr__  points to the parameter string itself. __Type__  is the module type as found in the program header (normally a 1 for "program"), and __lang__  should match the language nibble in the module header (C programs have a 1 for "6809 machine language"). __Datasize__  may be zero or it may contain the number of 256 byte pages to give to the new process as its initial memory allocation.  If it is zero, the new process' memory allocation will be the amount specified in the program header.
### DIAGNOSTICS

A -1 will be returned on an error, or the ID number of the child process will be returned upon success.
### EXAMPLE

An example of typical usage would be:

    static int stat;
    char *status = &stat;

    fork(module, params)
    char *module, *params;
    {
        os9fork (module, strlen(params), params, 1, 1, 0);
        wait (status);
    }


* * *
<a name="password"></a>
## PASSWORD

### NAME

    *getpwent, *getpwuid, *getpwnam, setpwent, endpwent, getpwdlm

    Password file operations

### SYNOPSIS

    #include <password.h>

    PWENT *getpwent()

    PWENT *getpwuid(uid)
    int uid;

    PWENT *getpwnam(name)
    char *name;

    void setpwent()

    void endpwent()

    int getpwdlm()

### DESCRIPTION

Each of the functions described below perform some operation on the `PASSWORD`  file maintained in `/DD/SYS.`
Notice also that three of the functions are declared as pointer functions, and two are of type VOID.
`GETPWENT`  returns a pointer to a structure containing the broken down password entry. It searches for the file `/DD/SYS/PASSWORD,`  opens it on the first call, and reads the first password entry. Any subsequent calls will overwrite the data contained in the structure `PWENT`  defined in `PASSWORD.H`, so that data must  be copied out before the next call is made to preserve it.
This function returns a __null__  upon reaching the end of the password file, and a -1 if an error occurs.
`GETPWUID`  performs the same function as `GETPWENT`  above, but it searches the password file until a given user ID, as defined by UID, is found.
`GETPWNAME`  again performs the same as `GWTPWENT,`  but searches the password file until the entry defined my __name__  is found. The search for __name__  is not case sensitive.
`SETPWENT`  rewinds the password file pointer so additional reads can be made after the end of the file is reached.
`ENDPWENT`  terminates access and closes the password file.
`GETPWDLM`  returns the current password file delimiter character. In an OS9 password file, the field delimiting character is a comma, while in other password utilities and files, a semi-colon is used for the delimiter character. This function is provided as a means to check the current type.
### NOTE

For user convinence, function declarations are made in the header file Password.h provided below.

	/*
    **  Password.h
    **
    **  Definitions for accessing the OS9 password file.
    **  Two different delimiters are accepted, ',' and ':'.
    **  In the second (Unix like) case, an extra field is
    **  defined for comments (ugcos).
    */

    #ifdef TEST
    #define  PASSWORD "/dd/sys/massword"
    #else
    #define  PASSWORD "/dd/sys/password"
    #endif

    #define  PWEMAX   64       /* maximum lines in password file */
    #define  PWSIZ    132  /* maximim size of password file line */
    #define  PWNSIZ   32          /* maximum size of user's name */
    #define  PWPSIZ   32      /* maximum size of user's password */
    #define  UNXDLM   ':'      /* Unix style password file delim */
    #define  OS9DLM   ','       /* OS9 style password file delim */

    typedef struct {
          char  *unam,
                *upw,
                *uid,
                *upri,
                *ugcos,
                *ucmd,
                *udat,
                *ujob;                      /* field pointers */
          } PWENT;


    /* returns a pointer to broken down password entry */
    PWENT    *getpwent();

    /* same, but for the given int uid */
    PWENT    *getpwuid();

    /* same, but for the given char *name */
    PWENT    *getpwnam();

    /* rewinds the password file for another scan */
    /*void*/ setpwent();

    /* terminates password file access (closes) file */
    /*void*/ endpwent();

    /* returns the current password entry delimiter */
    /*void*/ getpwdlm();



* * *
<a name="patmatch"></a>
## PATMATCH

### NAME

    patmatch - Tests one string with another for a match

### SYNOPSIS

    patmatch(pat, s, flag)
    char *pat, *s
    int flag

### DESCRIPTION

`PATMATCH`  searches the string __s__  for the pattern in __pat__  and returns true if there is a match. The pattern __pat__  must contain wildcard characters of '\*' and '?', where '\*' denotes a string of characters of any type and length, and '?' denotes a single character of any type. Expansion of wildcards is performed within the function.
If no match is found, false is returned.
If __flag__  is set as true, `PATMATCH`  will ignore the case of both strings buy calling the function __toupper()__  to make both the pattern and the string all uppercase characters prior to matching. Otherwise, an exact match is required.
### EXAMPLE

    if (patmatch("*.ar", dir_string, TRUE) == TRUE)
       puts("A match has been found");
    else
       puts("No match was found");


* * *
<a name="pause"></a>
## PAUSE

### NAME

    pause - halt and wait for an interrupt/signal

### SYNOPSIS

    pause()

### DESCRIPTION

`PAUSE`  may be used to halt a process until an interrupt or signal is received from `KILL.`  An equivalent function is __tsleep(0).__
### DIAGNOSTICS

 PAUSE always returns a -1.
### SEE ALSO

    kill(), signal(), tsleep()


* * *
<a name="prerr"></a>
## PRERR

### NAME

    prerr - print an error message

### SYNOPSIS

    prerr(filnum, errcode)
    int filnum, errcode;

### DESCRIPTION

`PRERR`  prints an error message on the output path specified by __filenum,__  which must be the path number of an already opened file.  The message depends on __errcode__  which will normally be a standard OS-9 error code. __Filenum__  may also be the standard output or standard error paths which are always opened at program start.
### SEE ALSO

    errmsg()


* * *
<a name="prgname"></a>
## PRGNAME

### NAME

    _prgname() - Get a module name

### SYNOPSIS

    char *_prgname()

### DESCRIPTION

This function returns a pointer to the name of the module being executed. Normally, __argv[0]__  points to the same string, but when __argv[]__  is not available, this function serves the purpose well.
### SEE ALSO

    _errmsg().


* * *
<a name="printf"></a>
## PRINTF

### NAME

    printf, fprintf, sprintf - formatted output conversion

### SYNOPSIS

    #include <stdio.h>

    printf(format [,arg ] ... )
    char *format;

    fprintf(fp, format [,arg ] ... )
    FILE  *fp;
    char *format;

    sprintf(s, format [,arg ] ... )
    char *s, *format;

### DESCRIPTION

These three functions are used to place numbers and strings in the output into formatted, human readable form.

The `PRINTF`  subroutine places output on the standard output stream __stdout.__  The `FPRINTF`  subroutine places output on the named output __fp.__  Note that the file pointer __fp__  may be 0, 1, or 2 corresponding to stdin, stdout, and stderr or any valid pointer as returned by __fopen(), creat(), create(),__  or __dup().__  The `SPRINTF`  subroutine places output in the string __s,__  followed by the character \`\\0' (NULL).  NOTE: It is the programmers responsibility to insure that string __s__  is large enough to hold the output of `SPRINTF.`

Each of these functions converts, formats, and prints its arguments after the first under control of the __format__  argument. The __format__  argument is a character string which contains two types of objects: plain characters, which are simply copied to the output stream, and conversion specifications.  Each of these cause conversion and printing of the next successive __arg.__

Following is the order in which a `PRINTF`  conversion specification is presented:
	% [-] [field_width] [.] [num_to_print] [len] conv_char

This order must be followed.  Any of the optional (enclosed in brackets) conversion specifications may be omitted but, the order must remain the same. A period must appear before the "nbr of chars to print" or `PRINTF`  will interpret the number to be the field width specification.

Each conversion specification is introduced by the percent sign character (%). Following the %, there may be:
    Zero or more flags, which modify the meaning of the conversion specification.     If the character following the '%' is not a conversion character, that     character is printed literally.     The first uninterpretable character ends the conversion string.

An optional minus sign (-) which specifies left adjustment of the      converted value in the indicated field.

An optional digit string specifying a field width.  The field will be at     least this wide and may be wider if the conversion requires it.     If the converted value has fewer characters than the field width,     it is blank-padded on the left (or right,     if the left-adjustment indicator has     been given) to make up the field width.     If the field width digit string begins with a zero,     zero-padding occurs instead of blank-padding.

An optional period (.) which serves to separate the field width from the next digit string.

An optional digit string specifying a precision which specifies the number of digits to appear after the radix character, for __    e__      and __    f__      conversions, or the maximum number of characters to be printed from a string.

The character __    l__      (lowercase 'l' (ell)) specifying that a following __    d, o, x, X,__      or __    u__      corresponds to a long integer __    arg .__

A character which indicates the type of     conversion to be applied.

A field width or precision may be an asterisk (*) instead of a digit string. In this case an integer __arg__  supplies the field width or precision.

The flag characters and their meanings are:

\- : The result of the conversion is left-justified     within the field.

\+ : The result of a signed conversion always begins      with a sign (+ or -).

blank : If the first character of a signed conversion is not     a sign, a blank is prepended to the result.  This     implies that if the blank and plus sign (+) flags both appear, the     blank flag is ignored.

\# : The value is to be converted to an alternative form.  For __    c, d, s,__      and  __    u__      conversions, the flag has no effect.  For __    o__      conversions,     it increases the precision to force the first digit of the     result to be a zero.  For __    x__      or  __    X__      conversions, a non-zero result has 0x or 0X     prepended to it.  For  __    e, E, f, g,__      and __    G__      conversions, the result always contains a decimal point,     even if no digits follow the point.  A decimal point usually     appears in the result of these conversions only if a digit      follows it.  For __    g__      and __    G__      conversions, trailing zeroes     are not removed from the result.

The conversion characters and their meanings are

d, o, x - The integer __    arg__      is converted to decimal, octal, or     hexadecimal notation respectively.

f - The float or double __    arg__      is converted to decimal notation in the style \`[-]ddd.ddd'     where the number of d's after the decimal point     is equal to the precision specification  for the argument.     If the precision is missing, 6 digits are given;     if the precision is explicitly 0, no decimal point and following characters     are printed.

e, E - The float or double __    arg__      is converted in the style     \`[-]d.ddde(+-)dd'     where there is one digit before the decimal point and     the number after is equal to the precision specification for the argument;     when the precision is missing, 6 digits are produced.  When the argument is __    E,__      the results are printed in uppercase characters.

g, G - The float or double     arg     is printed in style     d ,     in style     f ,     or in     style     e.     The style used depends on the value converted and the shortest is printed.     Style __    e__      is used only if the exponent resulting from the conversion is less than 4 or     greater than the precision.  Trailing zeroes are     removed from the result.  A decimal point appears only     if it is followed by a digit.  If the __    G__      form is used, the output is printed in uppercase characters.

c - The character __    arg__      is printed.

s - The __    arg__      is taken to be a string (character pointer)     and characters from the string are printed until     a null character or the number of characters indicated by the precision     specification is reached;  however if the precision is 0 or missing     all characters up to a null are printed.

u - The unsigned integer __    arg__      is converted to decimal and printed. The result is in the     range 0 through 65535 (for 6809/OS-9 only) or whatever the maximum integer     size is on the system.

% - Print a \`%'; no argument is converted.

A non-existent or small field width never causes truncation of a field.  Padding takes place only if the specified  field width exceeds the actual width.  Characters generated by `PRINTF`  are printed by  __putc().__

In the case of double or float conversions, the last digit printed is rounded.
### CAVEATS

In the ULTRIX-32 environment,  `PRINTF `  and  `FPRINTF`  return 0 for success and EOF for failure.   The `SPRINTF`  subroutine returns its first  argument for success and EOF for failure.

In the System V environment,  `PRINTF, FPRINTF,`  and `SPRINTF`  subroutines return the number of characters transmitted,  not including the \\0 in the case of  `SPRINTF `  or a negative value if an output error was encountered.

Within the OS-9 environment, in order to print long integers, the statement __pflinit()__  must occur somewhere in the source code in order for the routines to print longs to be linked from the standard library.  In addition, to print floats or double integers, the statement __pffinit()__  must occur somewhere in the source code.  Normally, either one or both of these statements are placed at the start of the source code file where printing of longs, floats, or doubles is required.
### SEE ALSO

    putc(), scanf()


* * *
<a name="putc"></a>
## PUTC

### NAME

    putc, putchar, putw - put character or word on a stream

### SYNOPSIS

    #include <stdio.h>

    char putc(c, fp)
    char c;
    FILE *fp;

    char putchar(c)

    putw(w, fp)
    FILE *fp;

### DESCRIPTION

The `PUTC`  routine appends the character __c__  to the named output __fp.__  It returns the character written.

The `PUTCHAR(c)`  routine is defined as a macro in the header file `STDIO.H`  and is the same as __putc__  (c, stdout).

The `PUTW`  routine appends word (that is, a two byte word, such as int), __w__  to the output __fp.__  It returns the word written. The `PUTW`  routine neither assumes nor causes special alignment in the file.

Output via `PUTC`  is normally buffered except when buffering is disabled with __setbuf()__  or when the standard error output path is used.
### CAVEATS

Because it is implemented as a macro, `PUTCHAR`  treats its argument with side effects incorrectly. In particular, \`putchar(*c++);' doesn't work as expected.
### DIAGNOSTICS

`PUTC`  and `PUTCHAR`  return the character argument from a successful call or `EOF`  upon error or end-of-file. Since `EOF`  is a good integer, __ferror()__  should be used to detect  `PUTW`  errors.
### SEE ALSO

    fclose(), fopen(), fread(), getc(), printf(), puts()


* * *
<a name="puts"></a>
## PUTS

### NAME

    puts, fputs - put a string on an output stream

### SYNOPSIS

    #include <stdio.h>

    puts(s)
    char *s;

    fputs(s, fp)
    char *s;
    FILE *fp;

### DESCRIPTION

The `PUTS`  subroutine copies the null-terminated string __s__  to the standard output stream __stdout__  and appends a new line character.

The `FPUTS`  subroutine copies the null-terminated string __s__  to the named output __fp.__

Neither routine copies the terminal null character.
### CAVEATS

The `PUTS`  subroutine appends a new line, while `FPUTS`  does not.  This inconsistency of the new-line being appended by `PUTS`  and not by `FPUTS`  is dictated by history and the desire for compatibility.
### SEE ALSO

    fopen(), gets(), putc(), printf(), ferror() fread()


* * *
<a name="qsort"></a>
## QSORT

### NAME

    qsort - quick sort

### SYNOPSIS

    qsort(base, nel, size, compar)
    char *base;
    int (*compar)();

### DESCRIPTION

The `QSORT`  subroutine is an implementation of the quick-sort algorithm. The first argument is a pointer to the base of the data; the second is the number of elements; the third is the size of an element in bytes; the last is the name of the comparison routine to be called with two arguments which are pointers to the elements being compared. The __compar()__  routine must return an integer less than, equal to, or greater than 0 according as the first argument is to be considered less than, equal to, or greater than the second.

* * *
<a name="read"></a>
## READ

### NAME

    read, readln - read from a file

### SYNOPSIS

    read(pn, buffer, count)
    char *buffer;
    int pn, count;

    readln(pn, buffer, count)
    char *buffer;
    int pn, count;

### DESCRIPTION

The path number __pn__  is an integer which is one of the standard path number 0, 1, or 2, or the path number returned from a successful call to __open()__, __creat()__, __create(),__  or __dup()__. Buffer  is a pointer to memory space with at least __count__  bytes of memory into which `READ`  and `READLN`  will put the data from the file.
It is guaranteed that at most __count__  bytes will be read from the file, but often less will be, either because, for `READLN,`  the file represents a terminal and input stops at the end of a line, or for both, the end-of-file marker has been reached.
`READLN`  causes "line editing" such as echoing to take place and returns once the first '\\n' is encountered in the input stream, or the number of bytes requested in __count__  has been reached. `READLN`  is the preferred call for reading from the user's terminal.
`READ`  does not cause any line editing.  See the OS-9 manual for a fuller description of the actions of these call.
### DIAGNOSTICS

`READ`  and `READLN`  return the number of bytes actually read (0 at EOF), or -1 for a physical I/O error, a bad path number, or a ridiculous __count.__  The actual error (physical I/O or otherwise) can be determined by examining the global variable __errno.__
### NOTE:

EOF is not considered an error, and no error indication is returned. Zero is returned on EOF.
SEE ALSO     open(), creat(), create(), dup()


* * *
<a name="realloc"></a>
## REALLOC

### NAME

    realloc - changes memory allocated by malloc()

### SYNOPSIS

    char realloc(p, size)
    char *p;
    int size;

### DESCRIPTION

`REALLOC`  takes a pointer such as that returned by `MALLOC`  and changes the size of the object. If the pointer argument is __null,__  `REALLOC`  degenerates into a `MALLOC.`
### SEE ALSO

    malloc() (Microware Manual)


* * *
<a name="sbrk"></a>
## SBRK

### NAME

    sbrk, ibrk - request additional working memory

### SYNOPSIS

    char *sbrk(increase)
    char *ibrk(increase)

    int increase;

### DESCRIPTION

`SBRK`  requests an allocation from free memory and returns a pointer to its base, if successful.
`SBRK`  requests the system to allocate "new" memory from outside the initial allocation.
`IBRK`  requests memory from inside the initial memory allocation.
Users should read the Memory Management section of the "C" programming Manual for a fuller explanation of the arrangement.
### DIAGNOSTICS

`SBRK`  and `IBRK` return a -1 if the requested amount of contiguous memory is  not available

* * *
<a name="scanf"></a>
## SCANF

### NAME

    scanf, fscanf, sscanf - convert formatted input

### SYNOPSIS

    #include <stdio.h>

    int scanf (format [, pointer...])
    char *format;


    int fscanf (fp, format [, pointer...])
    FILE *fp;
    char *format;

    int sscanf (s, format [, pointer...])
    char *s, *format;

### DESCRIPTION

The `SCANF`  subroutine reads from the standard input stream __stdin.__  The `FSCANF`  subroutine reads from the named input __fp.__  The `SSCANF`  subroutine reads from the character string __s.__  Each function reads characters, interprets them according to a format, and stores the results in its arguments. Each expects, as arguments, a control string __format__  described below, and a set of __pointer__  arguments indicating where the converted input should be stored.

The control string usually contains conversion specifications, which are used to direct interpretation of input sequences. The control string may contain:

White-space characters which, except in two cases described later, cause input to be read up to the next non-white-space character.

An ordinary character (not %), which must match the next character of the input stream.

Conversion specifications, consisting of the character % , an optional assignment suppressing character \(** , an optional numerical maximum field width, an optional l " (ell) or " h indicating the size of the receiving variable, and a conversion code.

A conversion specification directs the conversion of the next input field; the result is placed in the variable pointed to by the corresponding argument, unless assignment suppression was indicated by \(** . The suppression of assignment provides a way of describing an input field which is to be skipped. An input field is defined as a string of non-space characters; it extends to the next inappropriate character or until the field width, if specified, is exhausted. For all descriptors except left-bracket ([) and c, white space leading an input field is ignored.

The conversion code indicates the interpretation of the input field.  The corresponding pointer argument must usually be a restricted type. For a suppressed field, a pointer argument is not given. The following conversion codes are legal:

- % A single % is expected in the input at this point; no assignment is done.
- d A decimal integer is expected; the corresponding argument should be an integer pointer.
- u An unsigned decimal integer is expected; the corresponding argument should be an unsigned integer pointer.
- o An octal integer is expected; the corresponding argument should be an integer pointer.
- x A hexadecimal integer is expected; the corresponding argument should be an integer pointer.
- \\f3e\\fP,\\f3f\fP,\\f3g\\fP A floating point number is expected; the next field is converted accordingly and stored through the corresponding argument, which should be a pointer to a float . The input format for floating point numbers is an optionally signed string of digits, possibly containing a radix character, followed by an optional exponent field consisting of an E or an e , followed by an optional \(pl, \-, or space, followed by an integer.
- s A character string is expected; the corresponding argument should be a character pointer pointing to an array of characters large enough to accept the string and a terminating \e0 , which is added automatically. The input field is terminated by a white-space character.
- c A character is expected; the corresponding argument should be a character pointer. The normal skip over white space is suppressed in this case; to read the next non-space character, use %1s . If a field width is given, the corresponding argument should refer to a character array; the indicated number of characters is read.
- [ Indicates string data and the normal skip over leading white space is suppressed.  The left bracket is followed by a set of characters, which can be called the scanset, and a right bracket. The input field is the maximal sequence of input characters consisting entirely of characters in the scanset.

The circumflex \^, when it appears as the first character in the scanset, serves as a complement operator and redefines the scanset as the set of all characters not contained in the remainder of the scanset string. There are some conventions used in the construction of the scanset. A range of characters may be represented by the construct first\-last , thus [0123456789] may be expressed [0\-9].

Using this convention, first must be lexically less than or equal to last , or else the dash stands for itself.  The dash also stands for itself whenever it is the first or the last character in the scanset. To include the right square bracket as an element of the scanset, it must appear as the first character (possibly preceded by a circumflex) of the scanset, and in this case it is not syntactically interpreted as the closing bracket. The corresponding argument must point to a character array large enough to hold the data field and the terminating \fB\\0\fR, which is added automatically. At least one character must match for this conversion to be considered successful.

The conversion characters __d, u, o,__  and __x__  may be capitalized or preceded by __l__  or __h__  to indicate that a pointer to long or to short, rather than to int, is in the argument list.  Similarly, the conversion characters __e, f,__  and __g__  may be capitalized or preceded by __l__  to indicate that a pointer to double, rather than to float, is in the argument list. The "l" or "h" modifier is ignored for other conversion characters.

The `SCANF`  subroutine conversion terminates at EOF, at the end of the control string, or when an input character conflicts with the control string. In the latter case, the offending character is left unread in the input stream.

The `SCANF`  subroutine returns the number of successfully matched and assigned input items. This number can be zero in the event of an early conflict between an input character and the control string. If the input ends before the first conflict or conversion, EOF is returned.
### EXAMPLE

The call:

	int i, n; float x; char name[50];
    n = scanf("%d%f%s", &i, &x, name);

with the input line: 25 54.32E\-1 thompson

assigns to n the value 3, to i the value 25, to x the value 5.432,
and name will contain thompson.

Or:

    int i; float x; char name[50];
    scanf("%2d%f%\ %[0\-9]", &i, &x, name);

with input: 56789 0123 56a72 will assign 56 to i, 789.0 to x,
skip 0123, and place the string 560 in __name__.

The next call to __getchar()__  will return __a__. For further information, see  __getc__.
### CAVEATS

The success of literal matches and suppressed assignments is not directly determinable.

Trailing white space (including a new-line) is left unread unless matched in the control string.
### DIAGNOSTICS

These functions return EOF on end of input and a short count for missing or illegal data items.
### SEE ALSO

    atof(), getc(), printf()


* * *
<a name="setbuf"></a>
## SETBUF

### NAME

    setbuf - fix file buffer

### SYNOPSIS

    #include <stdio.h>

    setbuf (fp, buffer)
    FILE *fp;
    char buffer;

### DESCRIPTION

When the first character is written to or read from a file after it has been opened by `FOPEN(),`  a buffer is obtained from the system, if required, and assigned to the file pointer __fp.__  `SETBUF`  may be used to forestall this automatic buffer assignment by assigning a user buffer to the file.
`SETBUF`  must be used after the file has been opened and before any I/O has taken place.
The buffer must be of sufficient size and a value for a manifest constant, `BUFSIZ,`  is defined in the header file for use in declaration.
If the __buffer__  argument is __NULL__  (0), the file stream becomes unbuffered and characters are read or written singly.
NOTE that the standard error output defaults to unbuffered while the standard output default to buffered output.
### SEE ALSO

    fopen(), getc(), putc()


* * *
<a name="setime"></a>
## SETIME

### NAME

    setime, getime - set and get system time

### SYNOPSIS

    #include <time.h>

    setime(buffer)
    getime(buffer)

    struct sgtbuf *buffer;      /* defined in time.h */

### DESCRIPTION

`SETIME`  sets the system time depending on the values in the structure __buffer__  as defined in `TIME.H.`  These values must be set prior to calling `SETIME`  or the system time will be set to an unknown state.
`GETIME`  reads the system time and returns the information in the structure __buffer.__  Reading the structure elements will then yield the desired values.
An example to read the time structure might be:     struct sgtbuf timepacket;

    getime(timepacket);
    printf("The year is: %d\n", timepacket.t_year);
    printf("The day is:  %d\n", timepacket.t_day);


### SEE ALSO

    time(), ctime(), time(), o2utime(), u2otime()


* * *
<a name="setjmp"></a>
## SETJMP

### NAME

    setjmp, longjmp - nonlocal goto another function

### SYNOPSIS

    #include <setjmp.h>


    setjmp(env)
    jmp_buf env;


    longjmp(env, val)
    jmp_buf env;

### DESCRIPTION

These routines are useful for dealing with errors and interrupts encountered in a low-level subroutine of a program.

__Goto__  in C has a scope only in the function in which it is used; i.e., the label which is the object of the __goto__  may only be in the same function.  Control can only be transferred elsewhere by means of the function call, which, fo course, returns to the caller. In certain abnormal situations a programmer would perfer to be able to start some section of code again, but this would mean returning up a ladder of function calls with error indications all the way.

`SETJMP`  is used to "mark" a point in the program where a subsequent `LONGJMP`  can reach.  It places in the buffer, defined in the header file `SETJMP.H,`  enough information for the `LONGJMP`  to restore the environment to that existing at the time `SETJMP`  is called.

The `SETJMP `  subroutine saves its stack environment in __env__  for later use by `LONGJMP.`  It returns value 0.

The `LONGJMP`  subroutine restores the environment saved by the last call of `SETJMP .`  It then returns in such a way that execution continues as if the call of `SETJMP`  had just returned the value __val__  to the function that invoked `SETJMP,`  which must not itself have returned in the interim. However,  `LONGJMP`  cannot cause  `SETJMP`  to return the value 0. If  `LONGJMP`  is invoked with a  __val__  of 0,  `SETJMP`  will return 1. All accessible data have values as of the time `LONGJMP`  was called.
### CAVEATS

The `SETJMP`  subroutine does not save current notion of whether the process is executing as a result of a signal.  The result is that a LONGJMP to some place as a result of a signal leaves the signal state incorrect.
In addition, the variable __env__  MUST be globally declared.
### DIAGNOSTICS

`SETJMP`  returns a zero (0) if the call is the the first made in the current program run.  If a one (1) is returned, then it must be a `LONGJMP`  returning from some deeper level in the program.
### SEE ALSO

    signal(), intercept()


* * *
<a name="setmem"></a>
## SETMEM

### NAME

    setmem - Fills memory with a character

### SYNOPSIS

    setmem(start, count, fill)
    char *start
    int count
    char fill

### DESCRIPTION

`SETMEM`  fills __count__  bytes of memory beginning at the location pointed to by __start__  with the `ASCII`  character contained in __fill.__
No value is returned making this a type VOID function.
### EXAMPLE

    /* Initialize an 80 character string to all NULLS */

    count = 80;
    fill = '0x00'

    setmem(start, count, fill)

### SEE ALSO

    memset()


* * *
<a name="setpr"></a>
## SETPR

### NAME

    setpr - set process priority

### SYNOPSIS

    setpr(pid, priority)
    int pid, priority;

### DESCRIPTION

`SETPR`  sets the process identified by __pid__  (process ID) to have a priority of __priority.__  The lowest priority is 0 and the highest is 255.
A currently running process cannot change the priority of another running process if the two process' do not share ownership.  In addition, a process, if not owned by the super user, cannot upgrade its priority to a level higher than the parent process that created it with the OS-9 system call. However, a process owned by the super user, or any system process, can change the priority of any other running process to any level.
### DIAGNOSTICS

A -1 will be returned if the process does not have the same user ID as the calling process.

* * *
<a name="sets"></a>
## SETS

### NAME

    allocset, addc2set, adds2set, rmfmset, smember, union,
    sintersect, sdifference, copyset, dupset

    Set operations

### SYNOPSIS

    char *allocset(s, c)
    char *s, *p;

    char *addc2set(s, c)
    char *s c;

    char *adds2set(s, p)
    char *s p;

    char *rmfrmset(s, c)
    char *s, c;

    smember(s, c)
    char *s, c;

    char *sunion(s1, s2)
    char s1[], s2[];

    char *sintersect(s1, s2)
    char s1[], s2[];

    char *sdifference(s1, s2)
    char s1[], s2[];

    char *copyset(s1, s2)
    char s1[], s2[];

    char *dupset(s)
    char s[];

### DESCRIPTION

`ALLOCSET`  allocates memory for a set consisting of an array of 32 bytes (256 bits). If successful, it returns a pointer to the set, or __null__  if not successful. This array is then operated on with the following functions.
`ADDC2SET`  adds the character __c__  to the set __s.__  No error is possible. Adding a single character or any value in the range 0 - 255 decimal is the same as ORing the bit that corresponds to the numeric value of that character, i.e., adding a character 'A' to the set will set bit number $41, 65 decimal.
`ADDS2SET`  adds the string __p__  to the set __s.__  No error is possible. The string __p__  is added to the set in that same manner as `ADDC2SET`  above, but the entire string of bits is added in a bit-by-bit progression.
`RMFMSET`  removes character __c__  from the set __s.__  Again, no error is possible. Removing a character from the set amounts to ANDing the bit at the position corresponding to the numeric value of the character as in `ADDC2SET`  above, but is the reverse procedure.
`SMEMBER`  returns TRUE if character __c__  is a member of set __s,__  or returns FALSE if it is not a member.
`SUNION`  merges a second set __s2__  into the first set __s1.__
`SINTERSECT`  returns any elements that only exist in both sets __s1__  and __s2.__
`SDIFFERENCE`  returns unigue elements of both sets that are in the first set, __s1.__
`COPYSET`  duplicates the second set, __s2,__  into the first set, __s1.__
`DUPSET`  allocates memory for a new set, and then copies set __s__  into that memory area.

* * *
<a name="setstat"></a>
## SETSTAT

### NAME

    OS-9 set status system calls.

### SYNOPSIS

    #include <os9.h>
    #include <sgstat.h>

    setstat(SS_OPT, filenum, buffer)
    int code, filenum;
    struct sgbuf *buffer;

    setstat(SS_SIZE, filenum, size)
    int code, filenum;
    long *size;

    setstat(SS_RESET, filenum, code)
    int code, filenum, code;

    setstat(SS_WTRK, filenum, buffer, track_number, side/density)
    int code, filenum;
    char *buffer;
    int track_number, side/density;

    setstat(SS_FRZ, filenum)
    int code, filenum;

    setstat(SS_SQD, filenum)
    int code, filenum;

    setstat(SS_DCMD, code, filenum, parm1, parm2, parm3)
    int code, code, filenum, parm1, parm2, parm3;

    #include <direct.h>
    setstat(SS_FD, filenum, buffer)
    int code, filenum;
    struct fildes *buffer;

    setstat(SS_TICK, filenum, count)
    int code, filenum, count;

    setstat(SS_LOCK, filenum, position)
    int code, filenum;
    long position;

    setstat(SS_RELEA, filenum)
    int code, filenum;

    setstat(SS_BLKRD, filenum, buffer, track_sector, track_den)
    int code, filenum;
    char *buffer;
    int track_sector, track_den/side/density;

    setstat(SS_BLKWR, filenum, buffer, track_sector, track_den)
    int code, filenum;
    char *buffer;
    int track_sector, track_den/side/density;

    setstat(SS_SSIG, filenum, code)
    int code, filenum, code;

### DESCRIPTION

Most of these calls are equivalent to the `_SS_XXX`  calls described elsewhere in these documents. While the `_SS_XXX`  calls are provided for compatibility with source code generated for OSK systems, the calls listed below are those normally used with 6809/OS-9.
The following descriptions do not include the full syntax for each function call. See the list above under Synopsis.
`SETSTAT(SS_OPT)`  copies the buffer pointed to be __buffer__  into the options section of the path descriptor opened.
Generally, a program will fetch the options with the `GETSTAT(SS_OPT)`  function, change the desired values, and then update the path options with the `SETSTAT(SS_OPT)`  function. The structures `SGBUF` declared in  __SGSTAT.H__  provides a convenient means to access the individual option values.
If an error occurs, a -1 is returned and the appropriate error code is placed in __errno.__
It is a common practice to preserve a copy of the original path descriptor options so a program can restore them prior to exiting. The option changes take effect on the currently open path and any path created with the `I$DUP`  system call.
`SETSTAT(SS_SIZE)`  is used to change the size of a file opened on __filenum.__  The size change is immediate.
If the size of the file is decreased, the freed sectors are returned to the system. If the size is increased, sectors are added to the file with the contents of those sectors being undefined.
If an error occurs, this function returns the value -1 and the error code is placed in the global variable __errno.__
This function works only on `RBF`  devices.
`GETSTAT(SS_RESET)`  restores the disk drive head to Track 00 in preparation for formatting and error recovery.
If an error occurs, this function returns -1 as its value and the error code is placed in the global variable __errno.__
This call works only on `RBF`  devices.
`SETSTAT(SS_WRTK)`  performs a write-track operation on a disk drive. It is essentially a direct hook into the driver's write-track entry point.
__track_number__  is the desired track number to write, and __side/density__  is the desired side of the disk upon which to write. When the write is performed, the image contained in and pointed to by __buffer__  is written out to the disk.
If an error occurs, the value -1 is returned and the error code is placed in the global variable __errno.__
This function works only on `RBF`  devices. Additional information on how it works can be obtained from examining the FORMAT utility or a device driver.
__WARNING__!  If __track_number__  is set to zero when this function is called, the entire disk, floppy or hard disk, will be formatted.
`SETSTAT(SS_FRZ)`  inhibits the reading of LSN 0 variables which define the disk format. This enables the reading of non-standard disks.
This is a very little used function that has been deleted from most new documentation and, in fact, is not supported by Microware any more. It is included in this library solely for compatibility with older programs that may call it. Consult your manuals for an explanation of its use.
`SETSTAT(SS_SPT)`  sets a different number of tracks so that non-standard disks can be read. This is not an often used call, as with `SS_FRZ`  above. Consult your manual for more details.
This call does not return any information.
`SETSTAT(SS_SQD)`  starts the power down sequence for hard drives that have this feature. Since this sequence is hardware dependent, consult your user documents for more details. The device that is opened with __filenum__  will be the device the sequence works on.
This call does not return any information.
`SETSTAT(SS_DCMD)`  sends direct commands to the disk controller for specific instructions. Since parameters and commands are also hardware dependent, consult your disk controller's documentation and the specifications for the disk controller chip.
The exit conditions of this call vary depending on the hardware device.
`SETSTAT(SS_FD)`  places a copy of the `RBF`  file descriptor sector of the file opened into the buffer pointed to by __buffer.__  A maximum of __count__  bytes are copied. The structure `FILDES,`  declared in `DIRECT.H,`  provides a convenient method to access the file descriptor information.
If and error occurs, this function returns -1 as its value and the error code is placed in the global variable __errno.__   Be sure the buffer is large enough to hold all the options, or at least __count__  bytes. This call is effective only on `RBF`  devices. Declaring the buffer as type "struct fildes" is perfectly safe as this structure is predefined to be large enough to hold all the file descriptor information.
`SETSTAT(SS_TICK)`  may be used to cause an error (E$LOCK) to be returned to the process if the conflict still exists after a specific number of clock ticks have elapsed.
The argument __count__  specifies the number of ticks to wait if the record-lock conflict occurs with the file open on __path.__  A tick count of zero (the default on `RBF`  devices), causes a sleep until the record is released. A tick count of one means if the record is not released immediately, an error is to be returned.
If an error occurs, the value -1 is returned and the error code is placed in the global variable __errno.__
`SETSTAT(SS_LOCK)`  locks out a file open on __filenum__  at the offset from the file beginning at offset __position,__  so another process cannot read past that point.
If an error occurs, the function returns the value -1 and the error code is placed in the global variable __errno.__
`SETSTAT(SS_RELEA)`  releases a file that was locked using `SS_LOCK`  above.
`SETSTAT(SS_BLKRD)`  reads one block of data from a disk file opened on __filenum.__  The parameters passed determine the actual sector number and side of the disk. The data is read into a buffer pointed to by __buffer.__
This function is VERY hardware dependent and the user should know the size of a disk block on his/her system before using it. Typically, on an 8-bit machine, the block size will be 256 bytes while a 16-bit machine will usually have a block size of 512 bytes. UNIX hardware has a block size of 1024 bytes. In addition, not all device drivers support this call. Again, be sure before you use it.
Consult your hardware documentation for more details.
`SETSTAT(SS_BLKWR)`  is the reverse of `SS_BLKRD`  above, writing out one block of data.
`SETSTAT(SS_SSIG)`  sets up a signal to be sent to the calling process when an interactive device has data ready. When data is received on the device indicates by __filenum,__  the signal __code__  is sent to the calling process.
`SS_SSIG`  must be called each time the signal is sent if it is to be used again.
The device is considered busy, and will return an error, if any read request arrives before the signal is sent. Write requests are allowed to the device while in this state.
If an error occurs, the function returns the value -1 and the error code is placed in the global variable __errno.__
### NOTE

All the above calls require an OS-9 path number for __filenum, and NOT a__  C iob file descriptor pointer.
### SEE ALSO

    I$GetStt system call - Microware Manual, _gs_xxx calls


* * *
<a name="setuid"></a>
## SETUID

### NAME

    setuid - set user ID

### SYNOPSIS

    setuid(uid)
    int uid;

### DESCRIPTION

This call is used to set the user ID for the current process. `SETUID` only works if the caller is the super user.
### DIAGNOSTICS

A zero is returned from a successful call, and -1 on error.
### SEE ALSO

    getuid()


* * *
<a name="signal"></a>
## SIGNAL

### NAME

    signal - catch or ignore interrupts

### SYNOPSIS

    #include <signal.h>

    (*signal(interrupt, address))()
    (*address)();

### DESCRIPTION

This call is a comprehensive method of catching or ignoring signals sent to the current process.  Notice that `KILL`  does the sending of signals and `SIGNAL`  does the catching.
Normally, a signal sent to a process causes it to terminate with the status of the signal.  If, in advance of the signal, this system call is used, the program has the choise of ignoring the signal or designating a function to be executed when the signal is received.  Different functions may be designated for different signals.
The values for __address__  have the following meanings:

	0 = reset to the default, i.e., abort when received
    1 = ignore - this applies until reset to another value

Otherwise: taken to be the address of a C function which is to be executed upon receipt of the signal.

If the latter case is chosen, when the signal is received by the process the __address__  is reset to 0, the default, before the function is executed.  This means that is the next signal received should be caught then another call to `SIGNAL`  must be made immediately.  This is normally the first action taken by the `INTERRUPT`  function.  The function may access the signal number which caused its execution by looking at its argument.  On completion fo this function the program resumes execution at the point where it was interrupted by the signal.
### EXAMPLE

Suppose a program needs to create a temporary file which should be deleted before exiting.  The body of the program might contain fragments like this:

	pn = creat("temp",3);
    signal(2,intrupt);
    signal(3,intrupt);
    write(pn,string,count);
    close(pn);
    unlink("temp");
    exit(0);

The call to __signal()__  will insure that if a keyboard or quit signal is received then the function __intrupt()__  will be executed and this might written as:

	intrupt(sig)
    {
        close(pn);
        unlink("temp");
        exit(sig);
    }

In this case, as the function will be exiting before another signal is receive, it is unnecessary to call __signal()__  again to reset its pointer. Note that either the function __intrupt()__  should appear in the source code before the call to __signal(),__  or it should be pre-declared.
The signals used by OS-9 are define in the header file `SIGNAL.H`  as follows:

	/* OS-9 Signals

    #define SIGKILL 0
    #define SIGWAKE 1
    #define SIGQUIT 2
    #define SIGINT  3

    /* special addresses */

    #define SIG_DFL 0
    #define SIG_IGN 1

Please note that there is another method of trapping signals, namely __intercept().__  However, since __signal()__  and __intercept()__  are mutually incompatible, calls to both of them must not appear in the same program.  The linker will prevent the creation of an executable program in which both are called by aborting with an __entry name clash__  error for ___sigint.__
### SEE ALSO

    intercept(), kill(), OS-9 Shell command "kill"


* * *
<a name="skipbl"></a>
## SKIPBL

### NAME

    skipbl - Skips spaces and tabs within a string

### SYNOPSIS

    char *skipbl(s)
    char *s

### DESCRIPTION

`SKIPBL`  skips over all spaces (0x20) and tabs (0x09) in a string and returns an updated pointer to the next non-blank character.
Since the function returns a pointer, is must be declared prior to calling as a type CHAR function.
### EXAMPLE

    Before entering, the pointer is positioned as:

    Now    is    the    time
       ^

skipbl("Now    is    the    time")

returns the pointer as:

    Now    is    the    time
           ^

### SEE ALSO

    skipwd()


* * *
<a name="skipwd"></a>
## SKIPWD

### NAME

    skipwd - Skips non-blank characters in a string

### SYNOPSIS

    char *skipwd(s)
    char *s

### DESCRIPTION

`SKIPWD`  skips over all characters that are not spaces (0x20) and tabs (0x09) in a string and returns an pointer to the next character.
Since the function returns a pointer, it must be declared prior to calling as a type CHAR function.
### EXAMPLE

    Before entering, the pointer is positioned as:

    Now    is    the    time
    ^

skipbl("Now    is    the    time")

returns the pointer as:

    Now    is    the    time
    ^

### SEE ALSO

    skipbl()


* * *
<a name="ss-attr"></a>
## SS_ATTR

### NAME

    _ss_attr - set file attributes

### SYNOPSIS

    #include <modes.h>

    int _ss_attr(path, attr)
    int path;
    short attr;

### DESCRIPTION

`SS_ATTR`  changes a disk file's attributes. The current attributes of a file can be determined with the `_GS_GFD`  function. The attributes of a file can be changed only by the owner of the file or the super user.
The attributes as selected in the word __attr__  are set in the file opened on __path.__  The header file `MODES.H`  defines the valid mode values used in __attr.__
If an error occurs, the function returns the value -1 and the error code is placed in the global variable __errno.__
### NOTE

This function is effective even if the owner or super user does not have write permission to the file. It is not permitted to set the directory bit of a non-directory file, or to clear the directory bit of a directory that is not empty.
### SEE ALSO

    I$SetStt system call, Microware manual.


* * *
<a name="ss-lock"></a>
## SS_LOCK

### NAME

    _ss_lock - set file lock status

### SYNOPSIS

    int _ss_lock(path, locksize)
    int path;
    long locksize;

### DESCRIPTION

`SS_LOCK`  locks out a section of a file open on __path__  from the current file position up to the number of bytes specified by __locksize.__
If the locksize is zero, all locks (record lock, EOF lock, and file lock) are removed. If a locksize of 0xFFFFFFFF is requested, the entire file is locked regardless of where in the file the file pointer is. This is a special type of file lock that remains in effect until released by ___ss_lock(path,0),__  a read or write of zero or more bytes, or the file is closed.
If an error occurs, the function returns the value -1 and the error code is placed in the global variable __errno.__
### SEE ALSO

    I$SetStt system call, Microware manual.


* * *
<a name="ss-opt"></a>
## SS_OPT

### NAME

    _ss_opt - set file descriptor options

### SYNOPSIS

    #include <sgstat.h>

    int _ss_opt(path, buffer)
    int path;
    struct sgbuf *buffer;

### DESCRIPTION

`SS_OPT`  copies the buffer pointed to be __buffer__  into the options section of the path descriptor opened on __path.__
Generally, a program will fetch the options with the `GS_OPT`  function, change the desired values, and then update the path options with the `SS_OPT`  function. The structure __sgbuf__  declared in `SGSTAT.H`  provides a convenient means to access the individual option values.
If the path is invalid, _ss_opt returns -1 and the appropriate error code is placed in __errno.__
### NOTE

It is a common practice to preserve a copy of the original path descriptor options so a program can restore them prior to exiting. The option changes take effect on the currently open path and any path created with the I$DUP system call.
### SEE ALSO

    I$SetStt system call - Microware Manual, _gs_opt().


* * *
<a name="ss-pfd"></a>
## SS_PFD

### NAME

    _ss_pfd -- set and write file descriptor

### SYNOPSIS

    #include <direct.h>

    int _ss_pfd(path, buffer)
    int path;
    struct fildes *buffer;

### DESCRIPTION

`SS_PFD`  will copy certain bytes from the buffer pointed to by __buffer__  into the file descriptor sector of the file opened on __path.__  The buffer is usually obtained from the `GS_GFD`  function. Only the owner ID, the modification date, and the creation date is changed.
The structure __FILDES__  declared in `DIRECT.H`  provides a convenient means to access the file descriptor information.
### NOTE

The buffer must be at least 16 bytes long or garbage could be written into the file descriptor sector. The owner ID field can be changed only by the super-user. It is impossible to change the file attributes with the call. Instead, use the `SS_ATTR`  function.
### SEE ALSO

    I$SetStt system call, Microware Manual, _gs_pfd().


* * *
<a name="ss-rel"></a>
## SS_REL

### NAME

    _ss_rel - release a pending signal

### SYNOPSIS

    int _ss_rel(path)
    int path;

### DESCRIPTION

`SS_REL`  cancels the signal to be sent from a device on data ready. The function `SS_SSIG`  enables a device to send a signal to a process when data is available on the device. If an error occurs, the function returns the value -1 and the appropriate error value is placed in the global variable __errno.__
### NOTE

The signal request is also canceled when the issuing process dies or closes the path to the device. This feature exists only on `SCF`  devices.
### SEE ALSO

    I$SetStt system call, Microware manual, _ss_ssig().


* * *
<a name="ss-rest"></a>
## SS_REST

### NAME

    _ss_rest - restore disk drive head to track zero

### SYNOPSIS

    int _ss_rest(path)
    int path;

### DESCRIPTION

`SS_REST`  causes an `RBF`  device to restore the disk head to track zero. It is usually used prior to disk formatting and for error recovery.
If an error occurs, the function returns -1 and the appropriate error code is placed in the global variable __errno.__
### SEE ALSO

    I$SetStt system call - Microware manual.


* * *
<a name="ss-size"></a>
## SS_SIZE

### NAME

    _ss_size - change file size

### SYNOPSIS

    int _ss_size(path, size)
    int path;
    long size;

### DESCRIPTION

`SS_SIZE`  is used to change the size of a file opened on __path.__  The size change is immediate.
If the size of the file is decreased, the freed sectors are returned to the system. If the size is increased, sectors are added to the file with the contents of those sectors being undefined.
If an error occurs, _ss_size returns the value -1 and the error code is placed in the global variable __errno.__
### NOTE

This function works only on `RBF`  devices.
### SEE ALSO

    I$SetStt system call, Microware manual.


* * *
<a name="ss-ssig"></a>
## SS_SSIG

### NAME

    _ss_ssig - set a signal

### SYNOPSIS

    int _ss_ssig(path, sigcode)
    int path;
    short sigcode;

### DESCRIPTION

`SS_SSIG`  sets up a signal to be sent to the calling process when an interactive device has data ready. When data is received on the device indicates by __path,__  the signal __sigcode__  is sent to the calling process.
`SS_SSIG`  must be called each time the signal is sent if it is to be used again.
The device is considered busy, and will return an error, if any read request arrives before the signal is sent. Write requests are allowed to the device while in this state.
If an error occurs, the function returns the value -1 and the error code is placed in the global variable __errno.__
### NOTE

This feature exists only on `SCF`  devices.
### SEE ALSO

    I$SetStt system call, Microware manual, _ss_rel().


* * *
<a name="ss-tiks"></a>
## SS_TIKS

### NAME

    _ss_tiks - set timeout tick count

### SYNOPSIS

    int _ss_tiks(path, tickcnt)
    int path;
    int tickcnt;

### DESCRIPTION

If a read or write request is made for a part of a file that is locked out by another user, `RBF`  normally sleeps indefinitely until the conflict is removed. `SS_TIKS`  may be used to cause an error (E$Lock) to be returned to the process if the conflict still exists after a specific number of clock ticks have elapsed.
The argument __tickcnt__  specifies the number of ticks to wait if the record-lock conflict occurs with the file open on __path.__  A tick count of zero (the default on `RBF`  devices), causes a sleep until the record is released. A tick count of one means if the record is not released immediately, an error is to be returned.
If an error occurs, `_SS_TIKS`  returns the value -1 and the error code is placed in the global variable __errno.__
### NOTE

This feature exists only on `RBF`  devices.
### SEE ALSO

    I$SetStt system call, Microware manual, _ss_rel().


* * *
<a name="ss-wtrk"></a>
## SS_WTRK

### NAME

    _ss_wtrk - write a disk drive track

### SYNOPSIS

    int _ss_wtrk(path, trkno, siden, trkbuf)
    int path;
    int trkno, siden
    char *trkbuf

### DESCRIPTION

`SS_WRTK`  performs a write-track operation on a disk drive. It is essentially a direct hook into the driver's write-track entry point.
The argument __path__  is the path on which the device is opened. __Trkno__  is the desired track number to write, and __siden__  is the desired side of the disk on which to write. When the write is performed, the image contained in and pointed to by __trkbuf__  is written out to the disk.
If an error occurs, `_SS_WTRK`  returns the value -1 and the error code is placed in the global variable __errno.__
### NOTE

This function works only on `RBF`  devices. Additional information on how it works can be obtained from examining the `FORMAT`  utility or a device driver. Also, note there is a difference in the syntax of this call from that used in OSK systems.

#### >>>>  W A R N I N G  <<<<
If the variable __trkno__  is set to zero when this function is called, the `ENTIRE`  disk, floppy or hard disk, will be formatted.  Care should be taken to insure that __trkno__  has a non-zero value prior to entering this function.
### SEE ALSO

    I$SetStt system call, Microware manual.


* * *
<a name="stacksize"></a>
## STACKSIZE

### NAME

    stacksize, freemem - get stack reservation size

### SYNOPSIS

    stacksize()
    freemem()

### DESCRIPTION

The stack area is the currently reserved memory for exclusive use of the stack.  As each C function is entered, a routine in the system interface is called to reserve enough stack space for the use of the function with an additional 64 bytes.  The 64 bytes are for the use of user-written assembly language code functions and/or the system interface and/or arithmetic routines.  A record is kept of the lowest address so far granted for the stack.  If the area requested would not bring this lower, then the C function allowed to proceed.  If the new lower limit would mean that the stack area would overlap the data area, then the program stops with the message     ****  STACK OVERFLOW  ****

on the standard error outpath.  Otherwise, the new lower limit is set, and the C function resumes as before.
If the stack check code is in effect, then a call to `STACKSIZE`  will return the maximum number of bytes of stack used at the time of the call. This call can be used to determine the stack size required by the program.
`FREEMEM`  will return the number of bytes of the stack that has not been used.
### CAVEATS

Of course, all this depends on if the program was compiled with stack checking enabled.  If stack checking was disabled (cc -s code.c), then no stack checking occurs.
### SEE ALSO

ibrk(), sbrk(), variables __memend__  and value __end.__

* * *
<a name="strass"></a>
## STRASS

### NAME

    strass - byte by byte copy

### SYNOPSIS

    _strass(s1, s2, count)
    char *s1, *s2;
    int count;

### DESCRIPTION

Until such time as the compiler can deal with structure assignment, this function is useful for copying one structure to another.
__Count__  bytes are copied from memory location __s2__  to memory location __s1__  regardless of the contents.
* * *
<a name="strings"></a>
## STRINGS

### NAME

    strcat, strucat, strncat, strcmp, strucmp, strncmp, strnucmp,
    strcpy, strucpy, strncpy, strlen, strchr, strrchr, strpbrk,
    strspn, strcspn, strtok, strclr, strend, reverse, pwcryp
    index, rindex

    String operations

### SYNOPSIS

    #include <string.h>

    char *strcat (s1, s2)
    char *s1, *s2;

    char *strucat (s1, s2, n)
    char *s1, *s2;
    int n;

    char *strncat (s1, s2, n)
    char *s1, *s2
    int n;

    int strcmp (s1, s2)
    char *s1, *s2;

    int strucmp (s1, s2)
    char *s1, *s2;

    int strncmp (s1, s2, n)
    char *s1, *s2;
    int n;

    int strnucmp (s1, s2, n)
    char *s1, s2;
    int n;

    char *strcpy (s1, s2)
    char *s1, *s2;

    char *strucpy (s1, s2)
    char *s1, s2;

    char *strncpy (s1, s2, n)
    char *s1, *s2;
    int n;

    int strlen (s)
    char *s;

    char *strchr (s, c)     /* aka index() */
    char *s1;
    int c;

    char *strrchr (s, c)    /* aka rindex() */
    char *s1;
    int c;

    char *strpbrk (s1, s2)
    char *s1, *s2;

    int strspn (s1, s2)
    char *s1, *s2;

    int strcspn (s1, s2)
    char *s1, *s2;

    char *strtok (s1, s2)
    char *s1, *s2;

    char *strclr (s, c)
    char *s;
    int c;

    char *strend (s)
    char *s;

    char *reverse (s)
    char *s;

    char *pwcryp (s)
    char *s;

    char *index(s, ch)
    char *s, ch;

    char *rindex(s, ch)
    char *s, ch;

### DESCRIPTION

The arguments __s1, s2,__  and __s__  point to strings (arrays of characters terminated by a NULL character). The functions `STRCAT, STRUCAT, STRNCAT, STRCPY, STRUCPY`  and `STRNCPY`  all alter __s1.__  These functions do not check for overflow of the array pointed to by __s1.__
`STRCAT`  appends a copy of string __s2__  to the end of string __s1.__  `STRNCAT`  appends at most __n__  characters. `STRUCAT`  is the same as `STRCAT`  but makes all characters uppercase. Each returns a pointer to the null-terminated result.
`STRCMP`  compares its arguments and returns an integer less than, equal to, or greater than 0, according as __s1__  is lexicographically less than, equal to, or greater than __s2.__  `STRUCMP`  functions in the same way but makes all characters uppercase before comparing. `STRNCMP`  makes the same comparison but looks at at most __N__  characters. `STRNUCMP`  is the same except it makes all characters uppercase prior to the comparison.
`STRCPY`  copies string __s2__  to __s1__, stopping after the null character has been  copied. `STRUCPY`  performs the same except all characters are made uppercase. `STRNCPY`  copies exactly __n__  characters, truncating __s2__  or adding `null`  characters to __s1__  as necessary. The result will not be null-terminated if the length of __s2__  is __n__  or more. Each function returns __s1.__
`STRLEN`  returns the number of characters in __s,__  not including the terminating null characters.
`STRCHR (STRRCHR)`  returns a pointer to the first (last) occurrence of character __c__ in string  __s,__  or a `null`  pointer if __c__  does not occur in the string. The null character terminating a string is considered to be part of the string.
`STRPBRK`  returns a pointer to the first occurrence in string __s1__  of any character from __s2, or a__  `null`  pointer if no character from __s2__  exists in __s1.__
`STRSPN` (`STRCSPN`) returns the length of the initial segment of string  __s1__  which consists entirely of characters from (or not from) string __s2.__
`STRTOK`  considers the string __s1__  to consist of a sequence of zero or more text tokens separated by spans of one or more characters from the separator string __s2.__  The first call (with pointer __s1__  specified) returns a pointer to the first character of the first token, and will have written a null character into __s1__  immediately following the returned token. the function keeps track of its position in the string between separate calls, so that subsequent calls (which must be made with the first argument a NULL pointer) will work through the string __s1__  immediately following that token. In this way, subsequent calls will work through the string __s1__  until no tokens remain. The separator string __s2__ may be different from call to call. When no token remains in  __s1,__  a `null`  pointer is returned.
`STRCLR`  sets at the most __c__  characters in string __s,__  but not including the null-terminator, to SPACES (Ox20).
`STREND`  returns a pointer to the end of string __s.__
`REVERSE`  reverses the characters of string __s__  in memory and then returns __s.__
`PWCRYP`  encrypts and returns string __s.__
`INDEX`  returns a pointer to the first occurance of __ch__  in __s__  or `null`  if not found. `INDEX`  is functionally the same as `STRCHR`  except __ch__  is of type CHAR.
`RINDEX`  returns a pointer to the last occurance of __ch__  in __s__ or NULL if not  found. `RINDEX`  is functionally the same as `STRRCHR`  except __ch__  is of type CHAR.
Both `INDEX`  and `RINDEX`  are maintained for backward compatibility with older UNIX System V releases.
### NOTE

For user convenience, all these functions are declared in the optional <string.h> header file.
### BUGS

`STRCMP`  and `STRNCMP`  use native character comparison, which is unsigned on some machines. Thus, the sign of the value returned when one of the characters has its high order bit set is implementation-dependent.
Character movement is performed differently in different implementations. Thus, overlapping moves may yield surprises.
### CAVEATS

`STRCAT`  and `STRCPY`  have no means of checking that the space provided is large enough.  It is the user's responsibility to ensure that string space does not overflow.
### SEE ALSO

    findstr()


* * *
<a name="time"></a>
## TIME

### NAME

    time - Get the time

### SYNOPSIS

    long time ((char *) 0)
    long time (tloc)
    long *tloc;

### DESCRIPTION

`TIME`  returns the value of time in seconds since 00:00:00 GMT, January 1, 1970.
If __tloc__ (taken as an integer) is non-zero, the return value is also stored in  the location to which __tloc__ points.
Upon successful completion, `TIME`  returns the value of time. No error is possible here as `TIME`  always returns a value.
The value returned is suited for use with the `CTIME`  function.
### EXAMPLES

To get the system time value:

    long curr_time;
    curr_time = time ((char *)0);

or

    long curr_time;
    time (&curr_time);

### SEE ALSO

    ctime(), o2utime(), u2otime().


* * *
<a name="tsleep"></a>
## TSLEEP

### NAME

    tsleep - put process to sleep

### SYNOPSIS

    tsleep(ticks)
    int ticks;

### DESCRIPTION

`TSLEEP` deactivates the calling process for a specified number of system  clock __ticks__  or if __ticks__  is zero indefinitely.  A tick is system dependent, but is usually 100ms for most OS-9 systems except the Color Computer where it is 1/60th of a second.
### SEE ALSO

    sleep()


* * *
<a name="unbrk"></a>
## UNBRK

sh NAME     unbrk - returns memory

### SYNOPSIS

    unbrk(pnt)
    char *pnt;

### DESCRIPTION

`UNBRK`  returns memory that was allocated using `SBRK. SBRK`  requests the system to allocate more memory than was originally allocated. `UNBRK`  simply returns that additional allocation.
This function returns -1 if an error occurs and 0 upon success.
### SEE ALSO

    sbrk()


* * *
<a name="ungetc"></a>
## UNGETC

### NAME

    ungetc - put a character back into the input buffer

### SYNOPSIS

    #include <stdio.h>

    ungetc (ch, fp)
    char ch;
    FILE *fp;

### DESCRIPTION

This function alters the state of the input file buffer such that the next call of `GETC`  returns the character __ch.__
Only one character may be puched back, and at least one character must have been read from the file before a call to `UNGETC`  is made.
`FSEEK`  erases and characters pushed back.
### DIAGNOSTICS

`UNGETC`  returns its character argument unless no pushback could occur, in which case EOF is returned.
### SEE ALSO

    getc(), fseek()


* * *
<a name="unixtime"></a>
## UNIXTIME

### NAME

    o2utime, u2otime - converts date and time from OS9 to UNIX format

### SYNOPSIS

    #include <utime.h>
    #include <time.h>

    long o2utime(tp)
    struct sgtbuf *tp;

    u2otime(tp,tmp)
    struct sgtbuf *tp;
    struct tm     *tmp;

### DESCRIPTION

`O2UTIME`  converts a six character OS9 time into a UNIX style long as in the `TIME`  function.
`U2OTIME`  copies a broken down UNIX style time from structure __tmp__  into the OS9 style __sgtbuf__  structure.
### SEE ALSO

    time(), ctime()


* * *
<a name="unlink"></a>
## UNLINK

### NAME

    unlink - remove a directory entry

### SYNOPSIS

    unlink(fname)
    char *fname;

### DESCRIPTION

`UNLINK` deletes the directory entry whose name is pointed to by  __fname.__  If the entry was the last link to the file, then the file itself is deleted and the disc space occupied made available for re-use.  If, however, the file is open or in any active task, the deletion of the actual file is delayed until the file is closed.
### DIAGNOSTICS

Zero is returned from a successful call, -1 if the file does not exist, if its directory is write-protected, the pathname cannot be searched or if the file itself is a non-empty directory or a device.
### SEE ALSO

    unlinkx(), OS-9 "kill" command


* * *
<a name="unlinkx"></a>
## UNLINKX

### NAME

    unlinkx - deletes a directory entry

### SYNOPSIS

    unlinkx (fname, mode)
    char *fname, mode;

### DESCRIPTION

`UNLINKX`  performs essentially the same function as `UNLINK.`  However, if the attribute of the file to remove from the directory, as described by __mode,__  is an executable file, then the current execution directory is used. If the mode is not executable, then the current data directory is used.
This function returns -1 if an error occurs and 0 upon success.
### SEE ALSO

    unlink()


* * *
<a name="wait"></a>
## WAIT

### NAME

    wait - wait for a process termination

### SYNOPSIS

    wait(status)
    int *status;

    wait(0)

### DESCRIPTION

`WAIT`  is used to halt the current process until a child process has terminated.
`WAIT`  returns the process ID of the terminating process and places the status of that process in the integer pointed to by __status__  unless __status__  is zero.  A `WAIT`  must be executed for each child process spawned.
The status of the terminating child process will contain the argument of the __exit()__  or ___exit()__  call if the child process or the signal number if it was interrupted.  A normally terminating C program with no call to __exit__  or ___exit__  has an implied call of __exit(0).__
### CAVEATS

`NOTE`  that the status is the OS-9 status code and is not compatible with codes from other operating systems.
### DIAGNOSTICS

A -1 is returned if there is no child to be waited for.
### SEE ALSO

    os9fork(), signal(), exit(), _exit()


* * *
<a name="write"></a>
## WRITE

### NAME

    write, writeln - write to a file or device

### SYNOPSIS

    write(pn, buffer, count)
    char *buffer;
    int pn, count;

    writeln(pn, buffer, count)
    char *buffer
    int pn, count;

### DESCRIPTION

`WRITE`  and `WRITELN`  write to the path number __pn__  which must be a value returned by __open()__, __create()__, __creat(),__  or __dup(),__  or should be 0 (stdin), 1 (stdout), or 2 (stderr).
__Buffer__  should point to an area of memory from which __count__  bytes are to be written.  Write returns the actual number of bytes written and if this is different from __count,__  an error has occured.
Writes in multiples of 256 bytes to a file offset boundries of 256 bytes are the most efficient.
`WRITE` causes no "line-editing" to occur on the output.  `WRITELN`  causes line-editing and only writes up to the first "\\n" (newline) in the buffer if this is found before __count__  is exhausted.  For a full description of the actions of these calls, the reader is referred to the OS-9 documentation.
### DIAGNOSTICS

A -1 is returned if __pn__  is a bad path number, if __count__  is ridiculous, or upon a physical I/O error.
### SEE ALSO

    create(), creat(), dup(), open()

