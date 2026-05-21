#ifndef _STDIO_H
#define _STDIO_H

#include <sys/types.h>

#ifndef NULL
#define NULL 0
#endif

/**
 * @file stdio.h
 * @brief Buffered stream I/O for the CMOC OS-9 C Library.
 */

#define BUFSIZ  256
#define _NFILE  16
/**
 * @brief Buffered stream state used by the CMOC OS-9 C Library.
 *
 * `FILE` instances track the active buffer range, stream flags, OS-9 path
 * number, and ungetc/save state for the associated stream.
 */
typedef struct _iobuf {
       char *_ptr,   	/* buffer pointer */
            *_base,  	/* buffer base address */
            *_end;  	/* buffer end address */
       int _flag;      	/* file status */
       int _fd;        	/* file path number */
       char _save;     	/* for 'ungetc' when unbuffered */
       int _bufsiz;    	/* size of data buffer */
} FILE;

/**
 * @brief Global stream table backing `stdin`, `stdout`, and `stderr`.
 */
extern FILE _iob[_NFILE];

#define _READ       1
#define _WRITE      2
#define _UNBUF      4
#define _BIGBUF     8
#define _EOF        0x10
#define _ERR        0x20
#define _SCF        0x40
#define _RBF        0x80
#define _DEVMASK    0xc0
#define _WRITTEN    0x0100    /* buffer written in update mode */
#define _INIT       0x8000    /* _iob initialized */

#define EOF 		(-1)
#define EOL 		13

/** @brief Standard input stream. */
#define stdin 		_iob
/** @brief Standard output stream. */
#define stdout 		(&_iob[1])
/** @brief Standard error stream. */
#define stderr 		(&_iob[2])

#define PMODE  		0xb   /* r/w for owner, r for others */

/**
 * @brief Read the next character from a stream.
 *
 * @param stream Stream to read from.
 * @return The next character, or `EOF` on end-of-file or error.
 */
int getc(FILE *stream);

/**
 * @brief Push a character back onto a stream.
 *
 * @param c Character to push back.
 * @param stream Stream to modify.
 * @return The character pushed back, or `EOF` on failure.
 */
int ungetc(int c, FILE *stream);

/**
 * @brief Read a 16-bit word from a stream.
 *
 * @param stream Stream to read from.
 * @return The word value read, or `EOF` on failure.
 */
int getw(FILE *stream);

/**
 * @brief Write a character to a stream.
 *
 * @param c Character to write.
 * @param stream Destination stream.
 * @return The character written, or `EOF` on failure.
 */
int putc(int c, FILE *stream);

/**
 * @brief Write a 16-bit word to a stream.
 *
 * @param w Word to write.
 * @param stream Destination stream.
 * @return The word written, or `EOF` on failure.
 */
int putw(int w, FILE *stream);

/**
 * @brief Write a string followed by end-of-line to standard output.
 *
 * @param s String to write.
 * @return Non-negative on success, or `EOF` on failure.
 */
int puts(const char *s);

/**
 * @brief Write a string to a stream.
 *
 * @param s String to write.
 * @param stream Destination stream.
 * @return Non-negative on success, or `EOF` on failure.
 */
int fputs(const char *s, FILE *stream);

#define fgetc      	getc
#define putchar(c) 	putc(c,stdout)
#define getchar()  	getc(stdin)
#define ferror(p)  	((p)->_flag&_ERR)
#define feof(p)    	((p)->_flag&_EOF)
#define clearerr(p)	((p)->_flag&=~(_ERR|_EOF))
#define fileno(p)   ((p)->_fd)

/**
 * @brief Print formatted output to standard output.
 *
 * @param fmt Format string.
 * @return Number of characters written, or a negative value on error.
 */
int printf(const char *fmt, ...);

/**
 * @brief Print formatted output to a stream.
 *
 * @param fp Destination stream.
 * @param fmt Format string.
 * @return Number of characters written, or a negative value on error.
 */
int fprintf(FILE *fp, const char *fmt, ...);

/**
 * @brief Format output into a caller-provided string buffer.
 *
 * @param str Destination buffer.
 * @param fmt Format string.
 * @return Number of characters written, or a negative value on error.
 */
int sprintf(char *str, const char *fmt, ...);

/**
 * @brief Print a formatted message prefixed by an OS-9 error string.
 *
 * @param nerr OS-9 or library error code.
 * @param msg Additional formatted message text.
 * @return Number of characters written, or a negative value on error.
 */
int _errmsg(int nerr, const char *msg, ...);

/**
 * @brief Return the current program name string when available.
 *
 * @return Program name string, or a fallback string if unavailable.
 */
char *_prgname(void);

/**
 * @brief Read a line from standard input.
 *
 * @param str Destination buffer.
 * @return `str` on success, or `NULL` on failure or end-of-file.
 */
char *gets(char *str);

/**
 * @brief Read a line from a stream.
 *
 * @param str Destination buffer.
 * @param size Maximum number of bytes to read.
 * @param stream Source stream.
 * @return `str` on success, or `NULL` on failure or end-of-file.
 */
char *fgets(char *str, int size, FILE *stream);

/**
 * @brief Read an array of objects from a stream.
 *
 * @param ptr Destination buffer.
 * @param size Size of each object in bytes.
 * @param nmemb Number of objects to read.
 * @param stream Source stream.
 * @return Number of full objects read.
 */
size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);

/**
 * @brief Write an array of objects to a stream.
 *
 * @param ptr Source buffer.
 * @param size Size of each object in bytes.
 * @param nmemb Number of objects to write.
 * @param stream Destination stream.
 * @return Number of full objects written.
 */
size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);

/**
 * @brief Open a file path as a buffered stream.
 *
 * @param path File path to open.
 * @param mode Mode string such as `"r"`, `"w"`, or `"a"`.
 * @return Stream pointer on success, or `NULL` on failure.
 */
FILE *fopen(const char *path, const char *mode);

/**
 * @brief Associate a buffered stream with an existing file descriptor.
 *
 * @param filedes Existing file descriptor or path.
 * @param mode Mode string.
 * @return Stream pointer on success, or `NULL` on failure.
 */
FILE *fdopen(int filedes, const char *mode);

/**
 * @brief Reopen an existing stream on a new path and mode.
 *
 * @param pathname New file path.
 * @param mode Mode string.
 * @param stream Stream to reuse.
 * @return Stream pointer on success, or `NULL` on failure.
 */
FILE *freopen(const char *pathname, const char *mode, FILE *stream);

/**
 * @brief Open a process pipe as a stream.
 *
 * @param command Command string to execute.
 * @param type Pipe mode string.
 * @return Stream pointer on success, or `NULL` on failure.
 */
FILE *popen(const char *command, const char *type);

/**
 * @brief Close a process pipe stream.
 *
 * @param stream Pipe stream from `popen()`.
 * @return Process status or a negative value on failure.
 */
int pclose(FILE *stream);

/**
 * @brief Close a buffered stream.
 *
 * @param fp Stream to close.
 * @return `0` on success, or `EOF` on failure.
 */
int fclose(FILE *fp);

/**
 * @brief Flush pending buffered output for a stream.
 *
 * @param fp Stream to flush. Implementations may accept `NULL` for all streams.
 * @return `0` on success, or `EOF` on failure.
 */
int fflush(FILE *fp);

/**
 * @brief Set a caller-provided buffer for a stream.
 *
 * @param stream Stream to modify.
 * @param buf Buffer to use, or `NULL` for unbuffered/default behavior.
 */
void setbuf(FILE *stream, char *buf);

/**
 * @brief Reposition the current stream file offset.
 *
 * @param fp Stream to reposition.
 * @param pos Offset value.
 * @param whence Origin selector such as `SEEK_SET`, `SEEK_CUR`, or `SEEK_END`.
 * @return New file position on success, or a negative value on failure.
 */
long fseek(FILE *fp, long pos, int whence);

/**
 * @brief Return the current stream file offset.
 *
 * @param fp Stream to query.
 * @return Current offset, or a negative value on failure.
 */
long ftell(FILE *fp);

/**
 * @brief Rewind a stream to the beginning of the file.
 *
 * @param fp Stream to rewind.
 */
void rewind(FILE *fp);

#define	TRUE		(1)
#define	FALSE		(0)

#endif
